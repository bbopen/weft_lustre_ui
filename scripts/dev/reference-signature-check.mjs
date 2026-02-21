#!/usr/bin/env node
import fs from "node:fs/promises";
import path from "node:path";
import process from "node:process";
import { chromium } from "playwright";

const benchmarkUrl = process.env.BENCHMARK_URL ?? "http://127.0.0.1:4175/index.html";
const referenceUrl = process.env.REFERENCE_URL ?? "http://127.0.0.1:4180/dashboard";
const artifactDir =
  process.env.SIGNATURE_ARTIFACT_DIR ??
  path.join(process.cwd(), "examples", "dashboard_benchmark", "visual-artifacts");
const debugArtifactPath =
  process.env.SIGNATURE_DEBUG_JSON ?? path.join(artifactDir, "reference-signature-debug.json");

const viewport = { width: 1440, height: 900 };

const SIGNATURE_MATRIX = [
  {
    id: "shell",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-sidebar-shell" }],
      reference: [{ type: "query", value: "[data-slot='sidebar-wrapper']" }],
    },
    checks: [
      { path: "rect.width", tolerance: 1 },
      { path: "rect.height", tolerance: 30 },
      { path: "styles.padding-left", tolerance: 1 },
      { path: "styles.padding-right", tolerance: 1 },
    ],
  },
  {
    id: "sidebar",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-sidebar" }],
      reference: [{ type: "query", value: "[data-slot='sidebar-container']" }],
    },
    checks: [
      { path: "rect.x", tolerance: 2 },
      { path: "rect.width", tolerance: 2 },
      { path: "rect.height", tolerance: 2 },
    ],
  },
  {
    id: "theme_root",
    selectors: {
      benchmark: [{ type: "query", value: "html" }],
      reference: [{ type: "query", value: "html" }],
    },
    checks: [
      { path: "styles.color-scheme" },
      { path: "meta.has_dark_class" },
    ],
  },
  {
    id: "header_title",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-breadcrumb" }],
      reference: [{ type: "role", role: "heading", name: /documents/i }],
    },
    checks: [
      { path: "text" },
      { path: "styles.font-size", tolerance: 0.5 },
      { path: "styles.font-weight", tolerance: 40 },
      { path: "rect.y", tolerance: 4 },
    ],
  },
  {
    id: "header_theme_select",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-select" }],
      reference: [{ type: "role", role: "combobox", name: /theme/i }],
    },
    checks: [
      { path: "rect.width", tolerance: 3 },
      { path: "rect.height", tolerance: 3 },
      { path: "styles.border-radius", tolerance: 1 },
      { path: "meta.tag" },
      { path: "text" },
    ],
  },
  {
    id: "metrics_row",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-metrics-row" }],
      reference: [
        {
          type: "text-ancestor",
          value: "Total Revenue",
          maxDepth: 8,
          minWidth: 900,
          minHeight: 100,
          maxWidth: 1500,
          maxHeight: 320,
        },
      ],
    },
    checks: [
      { path: "rect.width", tolerance: 20 },
      { path: "rect.height", tolerance: 40 },
      { path: "styles.gap", tolerance: 1 },
      { path: "meta.child_count", tolerance: 1 },
    ],
  },
  {
    id: "metric_card_1",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-metric-card-1" }],
      reference: [
        {
          type: "text-ancestor",
          value: "Total Revenue",
          maxDepth: 8,
          minWidth: 240,
          minHeight: 120,
          maxWidth: 420,
          maxHeight: 280,
        },
      ],
    },
    checks: [
      { path: "rect.width", tolerance: 10 },
      { path: "rect.height", tolerance: 15 },
      { path: "styles.border-radius", tolerance: 1 },
    ],
  },
  {
    id: "chart_card",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-chart-card" }],
      reference: [
        {
          type: "text-ancestor",
          value: "Total Visitors",
          maxDepth: 20,
          minWidth: 900,
          minHeight: 220,
          maxWidth: 1400,
          maxHeight: 700,
        },
      ],
    },
    checks: [
      { path: "rect.width", tolerance: 30 },
      { path: "meta.svg_count", tolerance: 0 },
      { path: "meta.svg_path_count", tolerance: 40 },
      { path: "meta.svg_text_count", tolerance: 12 },
      { path: "meta.svg_labels", compare: "array-eq" },
      { path: "meta.has_desktop_mobile_text" },
    ],
  },
  {
    id: "tabs_root",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-tabs" }],
      reference: [{ type: "query", value: "[data-slot='tabs']" }],
    },
    checks: [
      { path: "rect.width", tolerance: 40 },
      { path: "rect.height", tolerance: 40 },
    ],
  },
  {
    id: "tab_list",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-tab-list" }],
      reference: [{ type: "role", role: "tablist" }],
    },
    checks: [
      { path: "meta.tab_count", tolerance: 0 },
      { path: "meta.tab_labels", compare: "array-eq" },
    ],
  },
  {
    id: "actions_row",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-actions" }],
      reference: [
        {
          type: "text-ancestor",
          value: "Customize Columns",
          maxDepth: 6,
          minWidth: 240,
          minHeight: 24,
          maxWidth: 420,
          maxHeight: 120,
        },
      ],
    },
    checks: [
      { path: "meta.button_count", tolerance: 1 },
      { path: "rect.height", tolerance: 16 },
    ],
  },
  {
    id: "table_root",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-insights-table" }],
      reference: [{ type: "query", value: "table" }],
    },
    checks: [
      { path: "rect.width", tolerance: 14 },
      { path: "meta.table_header_count", tolerance: 0 },
      { path: "meta.table_headers", compare: "array-eq" },
      { path: "meta.table_row_count", tolerance: 1 },
      { path: "meta.checkbox_count", tolerance: 0 },
      { path: "meta.input_count", tolerance: 0 },
      { path: "meta.combobox_count", tolerance: 0 },
    ],
  },
];

const STRUCTURAL_CHECKS = [
  { id: "layout.metrics_before_chart", left: "metrics_row", right: "chart_card", min_delta: 40, tolerance: 40 },
  { id: "layout.chart_before_tabs", left: "chart_card", right: "tabs_root", min_delta: 16, tolerance: 40 },
  { id: "layout.tabs_before_table", left: "tabs_root", right: "table_root", min_delta: 8, tolerance: 60 },
];

const selectorPreference = {
  id: 0,
  role: 1,
  query: 2,
  text: 3,
  "text-ancestor": 4,
};

function sortSelectors(selectors = []) {
  return [...selectors].sort((left, right) => {
    const leftWeight = selectorPreference[left.type] ?? 999;
    const rightWeight = selectorPreference[right.type] ?? 999;
    return leftWeight - rightWeight;
  });
}

function selectorLabel(spec) {
  return spec.value ?? spec.role ?? spec.name ?? spec.text ?? null;
}

function toRegExp(value) {
  if (value instanceof RegExp) return value;
  return new RegExp(String(value), "i");
}

function parsePx(value) {
  if (typeof value !== "string") return Number.NaN;
  const match = value.trim().match(/^(-?\d+(?:\.\d+)?)px$/i);
  return match ? Number.parseFloat(match[1]) : Number.NaN;
}

function normalizeText(value) {
  return String(value ?? "").replace(/\s+/g, " ").trim();
}

function toComparable(value) {
  if (value == null) return null;
  if (typeof value === "number") return value;
  if (typeof value === "string") {
    const px = parsePx(value);
    if (Number.isFinite(px)) return px;
    return normalizeText(value);
  }
  if (Array.isArray(value)) return value.map((item) => normalizeText(item));
  return value;
}

function pickPath(target, path) {
  const keys = path.split(".");
  let current = target;
  for (const key of keys) {
    if (current == null || typeof current !== "object" || !(key in current)) return null;
    current = current[key];
  }
  return current;
}

async function resolveLocator(page, spec) {
  switch (spec.type) {
    case "id":
    case "query":
      return page.locator(spec.value);
    case "role": {
      const options = {};
      if (spec.name != null) options.name = toRegExp(spec.name);
      if (spec.selected != null) options.selected = spec.selected;
      return page.getByRole(spec.role, options);
    }
    case "text":
      return page.getByText(toRegExp(spec.value));
    case "text-ancestor": {
      const selector = {
        text: spec.value,
        exact: spec.exact,
        maxDepth: spec.maxDepth ?? 8,
        minWidth: spec.minWidth ?? 100,
        minHeight: spec.minHeight ?? 20,
        maxWidth: spec.maxWidth ?? null,
        maxHeight: spec.maxHeight ?? null,
      };
      const handle = await page.evaluateHandle((config) => {
        const normalize = (value) => String(value || "")
          .replace(/\s+/g, " ")
          .trim()
          .toLowerCase();

        const target = normalize(config.text);
        const nodes = Array.from(document.querySelectorAll("*"));
        const depthOf = (node) => {
          let depth = 0;
          let current = node;
          while (current?.parentElement) {
            depth += 1;
            current = current.parentElement;
          }
          return depth;
        };

        const matches = nodes.filter((node) => {
          const candidate = normalize(node.textContent);
          return config.exact ? candidate === target : candidate.includes(target);
        });
        matches.sort((left, right) => {
          const depthDelta = depthOf(right) - depthOf(left);
          if (depthDelta !== 0) return depthDelta;
          return normalize(left.textContent).length - normalize(right.textContent).length;
        });

        for (const candidate of matches) {
          let current = candidate;
          for (let depth = 0; depth <= config.maxDepth && current; depth += 1) {
            const rect = current.getBoundingClientRect();
            const withinMaxWidth = config.maxWidth == null || rect.width <= config.maxWidth;
            const withinMaxHeight = config.maxHeight == null || rect.height <= config.maxHeight;
            if (
              rect.width >= config.minWidth &&
              rect.height >= config.minHeight &&
              withinMaxWidth &&
              withinMaxHeight
            ) {
              return current;
            }
            current = current.parentElement;
          }
        }
        return null;
      }, selector);
      return handle.asElement();
    }
    default:
      throw new Error(`unsupported selector type '${spec.type}'`);
  }
}

async function resolveNode(page, atom, mode, resolutionDebug = null) {
  const selectors = sortSelectors(atom.selectors[mode] || atom.selectors.benchmark || []);
  if (resolutionDebug) {
    resolutionDebug.attempts = [];
    resolutionDebug.selected_selector_type = null;
    resolutionDebug.selected_selector_value = null;
    resolutionDebug.match_count = 0;
  }

  for (const spec of selectors) {
    const locator = await resolveLocator(page, spec);
    const attempt = {
      selector_type: spec.type,
      selector_value: selectorLabel(spec),
      match_count: 0,
      selected: false,
      kind: "locator",
    };

    if (!locator) {
      if (resolutionDebug) resolutionDebug.attempts.push(attempt);
      continue;
    }

    if (typeof locator.count !== "function") {
      attempt.kind = "element-handle";
      attempt.match_count = 1;
      attempt.selected = true;
      if (resolutionDebug) {
        resolutionDebug.attempts.push(attempt);
        resolutionDebug.selected_selector_type = spec.type;
        resolutionDebug.selected_selector_value = selectorLabel(spec);
        resolutionDebug.match_count = 1;
      }
      return locator;
    }

    const count = await locator.count();
    attempt.match_count = count;
    if (resolutionDebug) resolutionDebug.attempts.push(attempt);
    const label = `${atom.id}:${spec.type}:${spec.value ?? spec.role ?? spec.name ?? spec.text ?? ""}`;

    if (count === 1) {
      if (resolutionDebug) {
        attempt.selected = true;
        resolutionDebug.selected_selector_type = spec.type;
        resolutionDebug.selected_selector_value = selectorLabel(spec);
        resolutionDebug.match_count = count;
      }
      return locator;
    }
    if (count > 1) {
      throw new Error(`Multiple matches for ${label} (${count})`);
    }
  }

  return null;
}

async function captureNodeSnapshot(locator) {
  return locator.evaluate((element) => {
    const normalize = (value) => String(value || "").replace(/\s+/g, " ").trim();
    const computed = getComputedStyle(element);
    const rect = element.getBoundingClientRect();

    const tabs = Array.from(element.querySelectorAll("[role='tab']"))
      .map((node) => normalize(node.textContent))
      .filter(Boolean);

    const table = element.matches("table") ? element : element.querySelector("table");
    const tableHeaders = table
      ? Array.from(table.querySelectorAll("th")).map((node) => normalize(node.textContent)).filter(Boolean)
      : [];
    const tableRows = table ? table.querySelectorAll("tbody tr").length : 0;

    const svgNodes = element.querySelectorAll("svg");
    const svgPathCount = Array.from(svgNodes).reduce(
      (count, svg) => count + svg.querySelectorAll("path").length,
      0,
    );
    const svgTextCount = Array.from(svgNodes).reduce(
      (count, svg) => count + svg.querySelectorAll("text").length,
      0,
    );
    const svgLabels = Array.from(element.querySelectorAll("svg text"))
      .map((node) => normalize(node.textContent))
      .filter(Boolean);
    const elementText = normalize(element.textContent);
    const hasDesktopMobileText =
      elementText.toLowerCase().includes("desktop")
      && elementText.toLowerCase().includes("mobile");

    return {
      rect: {
        x: Math.round(rect.x),
        y: Math.round(rect.y),
        width: Math.round(rect.width),
        height: Math.round(rect.height),
      },
      text: normalize(element.textContent).slice(0, 400),
      styles: {
        "font-size": computed.getPropertyValue("font-size"),
        "font-weight": computed.getPropertyValue("font-weight"),
        "line-height": computed.getPropertyValue("line-height"),
        "border-radius": computed.getPropertyValue("border-radius"),
        "padding-top": computed.getPropertyValue("padding-top"),
        "padding-right": computed.getPropertyValue("padding-right"),
        "padding-bottom": computed.getPropertyValue("padding-bottom"),
        "padding-left": computed.getPropertyValue("padding-left"),
        "background-color": computed.getPropertyValue("background-color"),
        "box-shadow": computed.getPropertyValue("box-shadow"),
        "color-scheme": computed.getPropertyValue("color-scheme"),
        color: computed.getPropertyValue("color"),
        gap: computed.getPropertyValue("gap"),
      },
      meta: {
        tag: element.tagName.toLowerCase(),
        class_list: Array.from(element.classList),
        has_dark_class: element.classList.contains("dark"),
        child_count: element.children.length,
        button_count: element.querySelectorAll("button").length,
        checkbox_count: element.querySelectorAll("input[type='checkbox'], [role='checkbox']").length,
        input_count: element.querySelectorAll("input").length,
        combobox_count: element.querySelectorAll("[role='combobox'], select").length,
        tab_count: tabs.length,
        tab_labels: tabs,
        table_header_count: tableHeaders.length,
        table_headers: tableHeaders,
        table_row_count: tableRows,
        svg_count: svgNodes.length,
        svg_path_count: svgPathCount,
        svg_text_count: svgTextCount,
        svg_labels: svgLabels,
        has_desktop_mobile_text: hasDesktopMobileText,
      },
    };
  });
}

async function captureAtoms(page, mode, debug = null) {
  const atoms = {};
  const atomDebug = debug ? {} : null;
  if (debug) debug.atoms = atomDebug;

  for (const atom of SIGNATURE_MATRIX) {
    const resolution = {};
    const node = await resolveNode(page, atom, mode, resolution);
    if (!node) {
      atoms[atom.id] = null;
      if (atomDebug) atomDebug[atom.id] = { ...resolution, status: "missing" };
      continue;
    }
    atoms[atom.id] = await captureNodeSnapshot(node);
    if (atomDebug) atomDebug[atom.id] = { ...resolution, status: "captured" };
  }

  return atoms;
}

function compareValue(referenceValue, benchmarkValue, path, tolerance = 0, compareMode = null) {
  if (referenceValue == null || benchmarkValue == null) {
    return {
      path,
      status: "missing",
      reference: referenceValue,
      benchmark: benchmarkValue,
      tolerance,
    };
  }

  if (compareMode === "array-eq") {
    const left = Array.isArray(referenceValue) ? referenceValue.map((item) => normalizeText(item)) : [];
    const right = Array.isArray(benchmarkValue) ? benchmarkValue.map((item) => normalizeText(item)) : [];
    const same = left.length === right.length && left.every((item, index) => item === right[index]);
    return {
      path,
      status: same ? "ok" : "drift",
      reference: left,
      benchmark: right,
      tolerance,
    };
  }

  const ref = toComparable(referenceValue);
  const bench = toComparable(benchmarkValue);

  if (typeof ref === "number" && typeof bench === "number") {
    const delta = Math.abs(ref - bench);
    return {
      path,
      status: delta <= tolerance ? "ok" : "drift",
      tolerance,
      reference: ref,
      benchmark: bench,
      delta,
    };
  }

  return {
    path,
    status: JSON.stringify(ref) === JSON.stringify(bench) ? "ok" : "drift",
    tolerance,
    reference: ref,
    benchmark: bench,
  };
}

function compareSnapshots(reference, benchmark) {
  const diffs = [];
  for (const atom of SIGNATURE_MATRIX) {
    for (const check of atom.checks) {
      const referenceAtom = reference.atoms[atom.id];
      const benchmarkAtom = benchmark.atoms[atom.id];

      if (referenceAtom == null || benchmarkAtom == null) {
        diffs.push({
          atom: atom.id,
          path: check.path,
          status: "missing",
          reference: referenceAtom,
          benchmark: benchmarkAtom,
          tolerance: check.tolerance,
        });
        continue;
      }

      const diff = compareValue(
        pickPath(referenceAtom, check.path),
        pickPath(benchmarkAtom, check.path),
        check.path,
        check.tolerance ?? 0,
        check.compare,
      );
      if (diff.status !== "ok") diffs.push({ atom: atom.id, ...diff });
    }
  }
  return diffs;
}

function compareStructure(reference, benchmark) {
  const diffs = [];
  for (const check of STRUCTURAL_CHECKS) {
    const leftRef = reference.atoms[check.left]?.rect?.y ?? null;
    const rightRef = reference.atoms[check.right]?.rect?.y ?? null;
    const leftBench = benchmark.atoms[check.left]?.rect?.y ?? null;
    const rightBench = benchmark.atoms[check.right]?.rect?.y ?? null;
    if (leftRef == null || rightRef == null || leftBench == null || rightBench == null) {
      diffs.push({
        atom: "structure",
        path: check.id,
        status: "missing",
        reference: { left: leftRef, right: rightRef },
        benchmark: { left: leftBench, right: rightBench },
        tolerance: check.tolerance ?? 0,
      });
      continue;
    }

    const refDelta = rightRef - leftRef;
    const benchDelta = rightBench - leftBench;
    if (refDelta < check.min_delta || benchDelta < check.min_delta) {
      diffs.push({
        atom: "structure",
        path: check.id,
        status: "drift",
        reference: refDelta,
        benchmark: benchDelta,
        tolerance: check.tolerance ?? 0,
      });
      continue;
    }

    const delta = Math.abs(refDelta - benchDelta);
    if (delta > (check.tolerance ?? 0)) {
      diffs.push({
        atom: "structure",
        path: check.id,
        status: "drift",
        reference: refDelta,
        benchmark: benchDelta,
        delta,
        tolerance: check.tolerance ?? 0,
      });
    }
  }
  return diffs;
}

function formatValue(value) {
  if (value == null) return "null";
  if (typeof value === "string") return value;
  return JSON.stringify(value);
}

async function extract(page, mode) {
  await page.addStyleTag({
    content: "*,:before,:after{animation:none!important;transition:none!important;caret-color:transparent!important}",
  });
  await page.waitForTimeout(200);

  const debug = {};
  const atoms = await captureAtoms(page, mode, debug);
  return { mode, url: page.url(), atoms, debug };
}

async function main() {
  const browser = await chromium.launch({ headless: true });
  try {
    const context = await browser.newContext({ viewport });
    const benchmarkPage = await context.newPage();
    await benchmarkPage.goto(benchmarkUrl, { waitUntil: "domcontentloaded", timeout: 120000 });
    await benchmarkPage.waitForSelector("#benchmark-app", { timeout: 30000 });
    const benchmark = await extract(benchmarkPage, "benchmark");

    const referencePage = await context.newPage();
    await referencePage.goto(referenceUrl, { waitUntil: "domcontentloaded", timeout: 120000 });
    await referencePage.waitForSelector("[data-slot='sidebar-wrapper']", { timeout: 60000 });
    const reference = await extract(referencePage, "reference");

    const diffs = [...compareSnapshots(reference, benchmark), ...compareStructure(reference, benchmark)];

    await fs.mkdir(artifactDir, { recursive: true });
    await fs.writeFile(
      debugArtifactPath,
      `${JSON.stringify(
        {
          generated_at: new Date().toISOString(),
          benchmark_url: benchmark.url,
          reference_url: reference.url,
          benchmark_debug: benchmark.debug,
          reference_debug: reference.debug,
          benchmark_atoms: benchmark.atoms,
          reference_atoms: reference.atoms,
          diffs,
          summary: {
            total: diffs.length,
            missing: diffs.filter((item) => item.status === "missing").length,
            drift: diffs.filter((item) => item.status === "drift").length,
          },
        },
        null,
        2,
      )}\n`,
      "utf8",
    );

    process.stdout.write(`Reference: ${reference.url}\n`);
    process.stdout.write(`Benchmark: ${benchmark.url}\n`);
    process.stdout.write(`Debug artifact: ${debugArtifactPath}\n\n`);

    for (const diff of diffs) {
      if (diff.status === "missing") {
        process.stdout.write(
          `MISS  ${diff.atom}.${diff.path} ref=${formatValue(diff.reference)} got=${formatValue(diff.benchmark)}\n`,
        );
        continue;
      }
      if (typeof diff.delta === "number") {
        process.stdout.write(
          `DRIFT ${diff.atom}.${diff.path} ref=${formatValue(diff.reference)} got=${formatValue(
            diff.benchmark,
          )} delta=${formatValue(diff.delta)} tol=${formatValue(diff.tolerance)}\n`,
        );
        continue;
      }
      process.stdout.write(
        `DRIFT ${diff.atom}.${diff.path} ref=${formatValue(diff.reference)} got=${formatValue(diff.benchmark)}\n`,
      );
    }

    process.stdout.write(`\nTotal signature drift items: ${diffs.length}\n`);
    if (diffs.length > 0) process.exitCode = 1;
  } finally {
    await browser.close();
  }
}

main().catch((error) => {
  process.stderr.write(`${error.stack ?? error}\n`);
  process.exit(1);
});
