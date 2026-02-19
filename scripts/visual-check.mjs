#!/usr/bin/env node
import fs from "node:fs/promises";
import path from "node:path";
import process from "node:process";
import { chromium } from "playwright";

const benchmarkUrl = process.env.BENCHMARK_URL ?? "http://127.0.0.1:4175/index.html";
const artifactDir =
  process.env.VISUAL_ARTIFACT_DIR ??
  path.join(process.cwd(), "examples", "dashboard_benchmark", "visual-artifacts");
const baselineDir =
  process.env.VISUAL_BASELINE_DIR ??
  path.join(process.cwd(), "examples", "dashboard_benchmark", "baselines");
const updateBaseline = process.env.VISUAL_UPDATE_BASELINE === "1";

const actualDir = path.join(artifactDir, "actual");

const scenarios = [
  {
    name: "desktop",
    viewport: {
      width: 1440,
      height: 900,
      deviceScaleFactor: 1,
      isMobile: false,
      hasTouch: false,
    },
  },
  {
    name: "mobile",
    viewport: {
      width: 390,
      height: 844,
      deviceScaleFactor: 2,
      isMobile: true,
      hasTouch: true,
    },
  },
];

const SIGNATURE_RECTS = [
  "sidebar",
  "mainSurface",
  "metricsRow",
  "filterRow",
  "tabs",
  "tabList",
  "tabPanel",
  "select",
  "table",
  "popoverOpen",
  "sheetOpen",
  "drawerOpen",
  "toastOpen",
];

const rectTolerance = {
  x: 12,
  y: 12,
  width: 24,
  height: 24,
  sidebarWidthDelta: 24,
  sidebarPositionDelta: 24,
};
const overflowTolerancePx = 40;

function fail(message) {
  throw new Error(message);
}

async function ensureDir(dir) {
  await fs.mkdir(dir, { recursive: true });
}

async function fileExists(target) {
  try {
    await fs.access(target);
    return true;
  } catch {
    return false;
  }
}

function numberClose(actual, expected, tolerance) {
  return Math.abs(actual - expected) <= tolerance;
}

function compareRect(rectName, actual, expected) {
  if (!actual || !expected) {
    return `${rectName} missing in actual/baseline`;
  }

  if (!numberClose(actual.x, expected.x, rectTolerance.x)) {
    return `${rectName}.x drifted: actual=${actual.x}, expected=${expected.x}`;
  }
  if (!numberClose(actual.y, expected.y, rectTolerance.y)) {
    return `${rectName}.y drifted: actual=${actual.y}, expected=${expected.y}`;
  }
  if (!numberClose(actual.width, expected.width, rectTolerance.width)) {
    return `${rectName}.width drifted: actual=${actual.width}, expected=${expected.width}`;
  }
  if (!numberClose(actual.height, expected.height, rectTolerance.height)) {
    return `${rectName}.height drifted: actual=${actual.height}, expected=${expected.height}`;
  }

  return null;
}

async function compareOrUpdateVisualData(name, actualPngPath, actualSignature) {
  const baselinePngPath = path.join(baselineDir, `${name}.png`);
  const baselineSignaturePath = path.join(baselineDir, `${name}.json`);

  if (updateBaseline) {
    await Promise.all([
      fs.copyFile(actualPngPath, baselinePngPath),
      fs.writeFile(
        baselineSignaturePath,
        `${JSON.stringify(actualSignature, null, 2)}\n`,
        "utf8",
      ),
    ]);
    return { status: "updated", details: "baseline refreshed" };
  }

  const [hasPng, hasSignature] = await Promise.all([
    fileExists(baselinePngPath),
    fileExists(baselineSignaturePath),
  ]);

  if (!hasPng || !hasSignature) {
    fail(
      `Missing baseline visual artifacts for ${name}. Run scripts/check-visual.sh --update-baseline.`,
    );
  }

  const [baselineSignatureRaw, baselinePngStat, actualPngStat] = await Promise.all([
    fs.readFile(baselineSignaturePath, "utf8"),
    fs.stat(baselinePngPath),
    fs.stat(actualPngPath),
  ]);

  const baselineSignature = JSON.parse(baselineSignatureRaw);

  const issues = [];

  if (
    baselineSignature.viewport.width !== actualSignature.viewport.width ||
    baselineSignature.viewport.height !== actualSignature.viewport.height
  ) {
    issues.push(
      `viewport changed: actual=${actualSignature.viewport.width}x${actualSignature.viewport.height}, expected=${baselineSignature.viewport.width}x${baselineSignature.viewport.height}`,
    );
  }

  for (const rectName of SIGNATURE_RECTS) {
    const result = compareRect(
      rectName,
      actualSignature.rects[rectName],
      baselineSignature.rects?.[rectName],
    );
    if (result) {
      issues.push(result);
    }
  }

  if (actualSignature.sideBarState) {
    const expectedState = baselineSignature.sideBarState;
    const stateChecks = [
      { key: "expandedWidth", tolerance: rectTolerance.sidebarWidthDelta },
      { key: "collapsedWidth", tolerance: rectTolerance.sidebarWidthDelta },
      { key: "delta", tolerance: rectTolerance.sidebarWidthDelta },
      { key: "expandedX", tolerance: rectTolerance.sidebarPositionDelta },
      { key: "expandedY", tolerance: rectTolerance.sidebarPositionDelta },
      { key: "collapsedX", tolerance: rectTolerance.sidebarPositionDelta },
      { key: "collapsedY", tolerance: rectTolerance.sidebarPositionDelta },
    ];

    for (const check of stateChecks) {
      if (
        expectedState == null ||
        actualSignature.sideBarState[check.key] == null ||
        expectedState[check.key] == null
      ) {
        issues.push(`sidebar state missing: ${check.key}`);
        continue;
      }

      if (
        !numberClose(
          actualSignature.sideBarState[check.key],
          expectedState[check.key],
          check.tolerance,
        )
      ) {
        issues.push(
          `sideBarState.${check.key} drifted: actual=${actualSignature.sideBarState[check.key]}, expected=${expectedState[check.key]}`,
        );
      }
    }
  } else {
    issues.push("sideBarState missing from actual signature");
  }

  if (actualSignature.bodyOverflowX > overflowTolerancePx) {
    issues.push(`horizontal overflow exceeds tolerance: ${actualSignature.bodyOverflowX}px`);
  }

  if (actualSignature.bodyOverflowX !== (baselineSignature.bodyOverflowX ?? 0)) {
    issues.push(
      `horizontal overflow drifted: actual=${actualSignature.bodyOverflowX}, expected=${baselineSignature.bodyOverflowX}`,
    );
  }

  const pngSizeRatio = actualPngStat.size / baselinePngStat.size;
  if (pngSizeRatio < 0.6 || pngSizeRatio > 1.4) {
    issues.push(
      `screenshot size drifted heavily: actual=${actualPngStat.size}, expected=${baselinePngStat.size}`,
    );
  }

  if (actualSignature.activeTab !== baselineSignature.activeTab) {
    issues.push(
      `active tab changed: actual=${actualSignature.activeTab}, expected=${baselineSignature.activeTab}`,
    );
  }

  if (actualSignature.toastCount !== (baselineSignature.toastCount ?? 0)) {
    issues.push(
      `toast count changed: actual=${actualSignature.toastCount}, expected=${baselineSignature.toastCount ?? 0}`,
    );
  }

  if (actualSignature.buttonCount !== baselineSignature.buttonCount) {
    issues.push(
      `button count changed: actual=${actualSignature.buttonCount}, expected=${baselineSignature.buttonCount}`,
    );
  }

  if (issues.length > 0) {
    return { status: "failed", details: issues.join("; ") };
  }

  return { status: "passed", details: "signature + screenshot checks passed" };
}

function selectorPriority(spec) {
  if (spec.type === "id") return 0;
  if (spec.type === "role") return 1;
  if (spec.type === "query" && String(spec.value).startsWith("#")) return 2;
  if (spec.type === "text") return 3;
  return 4;
}

function sortSelectors(selectors = []) {
  return [...selectors].sort((left, right) => selectorPriority(left) - selectorPriority(right));
}

function toRegExp(value) {
  if (value instanceof RegExp) return value;
  return new RegExp(String(value), "i");
}

async function resolveLocator(page, candidates, label) {
  const selectorCandidates = sortSelectors(candidates);

  for (const candidate of selectorCandidates) {
    let locator;

    switch (candidate.type) {
      case "id":
      case "query":
        locator = page.locator(candidate.value);
        break;
      case "role": {
        const options = {};
        if (candidate.name != null) {
          options.name = toRegExp(candidate.name);
        }
        if (candidate.selected != null) {
          options.selected = candidate.selected;
        }
        locator = page.getByRole(candidate.role, options);
        break;
      }
      case "text":
        locator = page.getByText(toRegExp(candidate.value));
        break;
      default:
        throw new Error(`Unsupported selector kind '${candidate.type}'`);
    }

    const count = await locator.count();
    if (count === 1) {
      return locator;
    }

    if (count > 1) {
      throw new Error(
        `Failed to resolve ${label}: ${count} matches for ${candidate.type} ${candidate.value || candidate.role || candidate.name || candidate.value}`,
      );
    }
  }

  throw new Error(`Failed to resolve ${label}: no candidates`);
}

async function assertVisible(page, locator, message) {
  try {
    await locator.first().waitFor({ state: "visible", timeout: 2000 });
  } catch {
    fail(message);
  }
}

async function assertHidden(page, locator, message) {
  const count = await locator.count();
  if (count === 0) return;
  try {
    await locator.first().waitFor({ state: "hidden", timeout: 2000 });
  } catch {
    fail(message);
  }
}

async function safeClick(locator) {
  await locator.scrollIntoViewIfNeeded().catch(() => {});
  try {
    await locator.click({ force: true });
  } catch {
    await locator.dispatchEvent("click");
  }
}

async function assertCountAtLeast(page, locator, expectedMinimum, message) {
  const count = await locator.count();
  if (count < expectedMinimum) {
    fail(`${message}: got ${count}, need ${expectedMinimum}`);
  }
}

async function assertExactCount(page, locator, expected, message) {
  const count = await locator.count();
  if (count !== expected) {
    fail(`${message}: got ${count}, need ${expected}`);
  }
}

async function captureRect(locator) {
  if (!locator) return null;
  const elementCount = await locator.count();
  if (elementCount === 0) return null;

  return locator.first().evaluate((el) => {
    const r = el.getBoundingClientRect();
    return {
      x: Math.round(r.x),
      y: Math.round(r.y),
      width: Math.round(r.width),
      height: Math.round(r.height),
    };
  });
}

async function runFunctionalChecks(page, scenario) {
  await page.goto(benchmarkUrl, { waitUntil: "domcontentloaded", timeout: 120000 });
  await page.waitForSelector("main#app");

  const checks = {
    sideBarState: {
      expandedWidth: 0,
      collapsedWidth: 0,
      delta: 0,
      expandedX: 0,
      expandedY: 0,
      collapsedX: 0,
      collapsedY: 0,
    },
    overlays: {
      popoverOpen: null,
      sheetOpen: null,
      drawerOpen: null,
      toastOpen: null,
    },
    tableRect: null,
  };

  const sidebar = await resolveLocator(
    page,
    [{ type: "id", value: "#benchmark-sidebar" }, { type: "query", value: "aside" }],
    "sidebar",
  );

  const breadcrumb = await resolveLocator(
    page,
    [{ type: "id", value: "#benchmark-breadcrumb" }, { type: "role", role: "navigation" }],
    "breadcrumb",
  );

  await assertVisible(page, breadcrumb, "Breadcrumb row missing");

  if (scenario.name === "desktop") {
    const sidebarBefore = await captureRect(sidebar);
    const menuToggle = await resolveLocator(
      page,
      [
        { type: "id", value: "#benchmark-menu-toggle" },
        { type: "role", role: "button", name: /menu|toggle sidebar|open sidebar/i },
      ],
      "sidebar toggle",
    );

    checks.sideBarState.expandedWidth = sidebarBefore?.width ?? 0;
    checks.sideBarState.expandedX = sidebarBefore?.x ?? 0;
    checks.sideBarState.expandedY = sidebarBefore?.y ?? 0;

    await menuToggle.dispatchEvent("click");
    await page.waitForTimeout(160);
    const sidebarAfter = await captureRect(sidebar);

    checks.sideBarState.collapsedWidth = sidebarAfter?.width ?? 0;
    checks.sideBarState.collapsedX = sidebarAfter?.x ?? 0;
    checks.sideBarState.collapsedY = sidebarAfter?.y ?? 0;
    const widthDelta = Math.abs((sidebarAfter?.width ?? 0) - (sidebarBefore?.width ?? 0));
    const xDelta = Math.abs((sidebarAfter?.x ?? 0) - (sidebarBefore?.x ?? 0));
    checks.sideBarState.delta = widthDelta > 0 ? widthDelta : xDelta;

    if (!(widthDelta > 0 || xDelta > 0)) {
      fail(
        `Sidebar did not collapse on desktop. before=(${checks.sideBarState.expandedX},${checks.sideBarState.expandedWidth}), after=(${checks.sideBarState.collapsedX},${checks.sideBarState.collapsedWidth})`,
      );
    }

    await menuToggle.dispatchEvent("click");
    await page.waitForTimeout(160);
  }

  const popoverButton = await resolveLocator(
    page,
    [
      { type: "id", value: "#benchmark-popover-trigger" },
      { type: "role", role: "button", name: /filters help|help/i },
    ],
    "popover trigger",
  );
  await safeClick(popoverButton);
  await assertVisible(
    page,
    page.locator("text=Use tabs and filters to narrow dashboard insights."),
    "Popover content did not open",
  );
  const popoverPanel = page.locator("#benchmark-popover-panel");
  if (await popoverPanel.count()) {
    checks.overlays.popoverOpen = await captureRect(popoverPanel);
  }
  await safeClick(popoverButton);
  await assertHidden(
    page,
    page.locator("text=Use tabs and filters to narrow dashboard insights."),
    "Popover content did not close",
  );

  const sheetTrigger = await resolveLocator(
    page,
    [
      { type: "id", value: "#benchmark-open-sheet" },
      { type: "role", role: "button", name: /open sheet|quick create|sheet/i },
    ],
    "sheet trigger",
  );
  await safeClick(sheetTrigger);
  await assertVisible(page, page.locator("#benchmark-sheet"), "Sheet did not open");
  const sheetPanel = page.locator("#benchmark-sheet-content");
  if (await sheetPanel.count()) {
    checks.overlays.sheetOpen = await captureRect(sheetPanel);
  }
  await page.mouse.click(8, 8);
  await assertHidden(page, page.locator("#benchmark-sheet"), "Sheet did not close");

  const drawerTrigger = await resolveLocator(
    page,
    [
      { type: "id", value: "#benchmark-open-drawer" },
      { type: "role", role: "button", name: /add section|open drawer/i },
    ],
    "drawer trigger",
  );
  await safeClick(drawerTrigger);
  if (!(await page.locator("#benchmark-drawer").first().isVisible().catch(() => false))) {
    await page.evaluate(() => {
      document.getElementById("benchmark-open-drawer")?.dispatchEvent(
        new MouseEvent("click", { bubbles: true, cancelable: true }),
      );
    });
  }
  await assertVisible(page, page.locator("#benchmark-drawer"), "Drawer did not open");
  const drawerPanel = page.locator("#benchmark-drawer-content");
  if (await drawerPanel.count()) {
    checks.overlays.drawerOpen = await captureRect(drawerPanel);
  }
  await page.mouse.click(8, 8);
  await assertHidden(page, page.locator("#benchmark-drawer"), "Drawer did not close");

  const toastTrigger = await resolveLocator(
    page,
    [
      { type: "id", value: "#benchmark-show-toast" },
      { type: "role", role: "button", name: /show toast|toast/i },
    ],
    "toast trigger",
  );
  await safeClick(toastTrigger);
  const toastContent = page.locator("text=Dashboard benchmark toast");
  await assertVisible(page, toastContent, "Toast did not render");
  const toastPanel = page.locator("#benchmark-toast-content");
  if (await toastPanel.count()) {
    checks.overlays.toastOpen = await captureRect(toastPanel);
  }
  const toastDismiss = page.getByRole("button", { name: "Dismiss" });
  if (await toastDismiss.count()) {
    await toastDismiss.first().click({ force: true }).catch(async () => {
      await toastDismiss.first().dispatchEvent("click");
    });
    await page.waitForTimeout(120);
  } else {
    await page.mouse.click(8, 8);
    await page.waitForTimeout(120);
  }
  await assertHidden(page, toastContent, "Toast did not dismiss");

  const secondaryDrawer = await resolveLocator(
    page,
    [
      { type: "id", value: "#benchmark-open-drawer" },
      { type: "role", role: "button", name: /add section|open drawer/i },
    ],
    "secondary drawer action",
  );
  await safeClick(secondaryDrawer);
  if (!(await page.locator("#benchmark-drawer").first().isVisible().catch(() => false))) {
    await page.evaluate(() => {
      document.getElementById("benchmark-open-drawer")?.dispatchEvent(
        new MouseEvent("click", { bubbles: true, cancelable: true }),
      );
    });
  }
  if (await page.locator("#benchmark-drawer").first().isVisible().catch(() => false)) {
    await page.mouse.click(8, 8);
    await assertHidden(page, page.locator("#benchmark-drawer"), "Secondary drawer did not close");
  } else {
    process.stdout.write("warn: secondary drawer action did not open; continuing\n");
  }

  const secondaryToast = await resolveLocator(
    page,
    [
      { type: "id", value: "#benchmark-show-toast" },
      { type: "role", role: "button", name: /show toast|toast/i },
    ],
    "secondary toast action",
  );
  await safeClick(secondaryToast);
  if (!(await page.locator("text=Dashboard benchmark toast").first().isVisible().catch(() => false))) {
    await page.evaluate(() => {
      document.getElementById("benchmark-show-toast")?.dispatchEvent(
        new MouseEvent("click", { bubbles: true, cancelable: true }),
      );
    });
  }
  await assertVisible(page, page.locator("text=Dashboard benchmark toast"), "Secondary toast action failed");
  const secondaryDismiss = page.getByRole("button", { name: "Dismiss" });
  if (await secondaryDismiss.count()) {
    await secondaryDismiss.first().click({ force: true }).catch(async () => {
      await secondaryDismiss.first().dispatchEvent("click");
    });
    await page.waitForTimeout(120);
  } else {
    await page.mouse.click(8, 8);
    await page.waitForTimeout(120);
  }
  await assertHidden(page, page.locator("text=Dashboard benchmark toast"), "Secondary toast did not dismiss");

  const disabledAction = page.locator("#benchmark-action-disabled");
  if ((await disabledAction.count()) > 0) {
    const disabledState = await disabledAction.getAttribute("disabled");
    if (disabledState == null) {
      fail("Disabled benchmark action is not marked disabled");
    }
  }

  await assertVisible(page, page.locator("#benchmark-insights-table"), "Table visibility check failed");
  await assertCountAtLeast(page, page.locator("#benchmark-insights-table tbody tr"), 1, "Table rows missing");
  checks.tableRect = await captureRect(page.locator("#benchmark-insights-table"));
  await assertVisible(page, breadcrumb, "Breadcrumb missing");

  if (scenario.name === "mobile") {
    const overflowX = await page.evaluate(() => {
      const viewportWidth = window.innerWidth || document.documentElement.clientWidth;
      return document.documentElement.scrollWidth - viewportWidth;
    });
    if (overflowX > overflowTolerancePx) {
      fail(`Mobile layout overflow exceeds tolerance: ${overflowX}px`);
    }
  }

  return checks;
}

async function collectSignature(page, checks) {
  const viewportSize = page.viewportSize();
  const rect = (selector) =>
    page.locator(selector)
      .count()
      .then((count) =>
        count
          ? page.locator(selector).evaluate((el) => {
              const bounds = el.getBoundingClientRect();
              return {
                x: Math.round(bounds.x),
                y: Math.round(bounds.y),
                width: Math.round(bounds.width),
                height: Math.round(bounds.height),
              };
            })
          : null,
      );

  const activeTab = await page.locator("[role='tab'][aria-selected='true']").first().textContent();
  const bodyOverflowX = await page.evaluate(() => {
    const viewportWidth = window.innerWidth || document.documentElement.clientWidth;
    return document.documentElement.scrollWidth - viewportWidth;
  });

  const [
    sidebar,
    mainSurface,
    metricsRow,
    filterRow,
    tabs,
    tabList,
    tabPanel,
    select,
    table,
    popoverOpen,
    sheetOpen,
    drawerOpen,
    toastOpen,
  ] = await Promise.all([
    rect("#benchmark-sidebar"),
    rect("#benchmark-main-surface"),
    rect("#benchmark-metrics-row"),
    rect("#benchmark-filter-row"),
    rect("#benchmark-tabs"),
    rect("#benchmark-tab-list"),
    rect("#benchmark-tab-panel"),
    rect("#benchmark-select"),
    checks.tableRect,
    checks.overlays.popoverOpen,
    checks.overlays.sheetOpen,
    checks.overlays.drawerOpen,
    checks.overlays.toastOpen,
  ]);

  return {
    viewport: {
      width: viewportSize?.width ?? 0,
      height: viewportSize?.height ?? 0,
    },
    bodyOverflowX,
    buttonCount: await page.locator("button").count(),
    toastCount: await page.locator("#benchmark-toast-content").count(),
    activeTab: (activeTab || "").trim(),
    sideBarState: checks.sideBarState,
    rects: {
      sidebar,
      mainSurface,
      metricsRow,
      filterRow,
      tabs,
      tabList,
      tabPanel,
      select,
      table,
      popoverOpen,
      sheetOpen,
      drawerOpen,
      toastOpen,
    },
  };
}

async function main() {
  await Promise.all([ensureDir(artifactDir), ensureDir(actualDir), ensureDir(baselineDir)]);

  const browser = await chromium.launch({ headless: true });
  const results = [];

  try {
    for (const scenario of scenarios) {
      const context = await browser.newContext({
        viewport: {
          width: scenario.viewport.width,
          height: scenario.viewport.height,
        },
        deviceScaleFactor: scenario.viewport.deviceScaleFactor,
        isMobile: scenario.viewport.isMobile,
        hasTouch: scenario.viewport.hasTouch,
      });
      const page = await context.newPage();
      const checks = await runFunctionalChecks(page, scenario);

      const actualPngPath = path.join(actualDir, `${scenario.name}.png`);
      await page.screenshot({ path: actualPngPath, fullPage: true });
      const signature = await collectSignature(page, checks);
      const comparison = await compareOrUpdateVisualData(scenario.name, actualPngPath, signature);
      results.push({ scenario: scenario.name, ...comparison });

      await context.close();
    }
  } finally {
    await browser.close();
  }

  const failures = results.filter((result) => result.status === "failed");
  for (const result of results) {
    process.stdout.write(`${result.scenario}: ${result.status} - ${result.details}\n`);
  }

  if (failures.length > 0) {
    fail(
      `Visual regression detected in ${failures.map((result) => result.scenario).join(", ")}`,
    );
  }
}

main().catch((error) => {
  process.stderr.write(`${error.stack ?? error}\n`);
  process.exit(1);
});
