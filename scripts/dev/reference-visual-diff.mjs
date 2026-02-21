#!/usr/bin/env node
import fs from "node:fs/promises";
import path from "node:path";
import process from "node:process";
import { spawn, spawnSync } from "node:child_process";
import { chromium } from "playwright";

const benchmarkUrl = process.env.BENCHMARK_URL ?? "http://127.0.0.1:4175/index.html";
const referenceUrl = process.env.REFERENCE_URL ?? "http://127.0.0.1:4180/dashboard";
const artifactDir =
  process.env.REFERENCE_VISUAL_ARTIFACT_DIR ??
  path.join(process.cwd(), "examples", "dashboard_benchmark", "visual-artifacts", "reference-diff");
const maxDiffRatio = Number.parseFloat(process.env.REFERENCE_VISUAL_MAX_DIFF_RATIO ?? "0.02");
const diffMetric = String(process.env.REFERENCE_VISUAL_DIFF_METRIC ?? "MAE").toUpperCase();

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

function fail(message) {
  throw new Error(message);
}

async function ensureDir(dir) {
  await fs.mkdir(dir, { recursive: true });
}

function detectMagickBinary() {
  const candidates = ["magick", "compare"];
  for (const command of candidates) {
    const result = spawnSync(command, ["-version"], { encoding: "utf8" });
    if (result.status === 0) return command;
  }
  return null;
}

function runImageDiff(command, metric, leftPath, rightPath, diffPath) {
  const args =
    command === "magick"
      ? ["compare", "-metric", metric, leftPath, rightPath, diffPath]
      : ["-metric", metric, leftPath, rightPath, diffPath];

  return new Promise((resolve, reject) => {
    const child = spawn(command, args);
    let stderr = "";
    let stdout = "";

    child.stderr.on("data", (chunk) => {
      stderr += String(chunk);
    });
    child.stdout.on("data", (chunk) => {
      stdout += String(chunk);
    });
    child.on("error", reject);
    child.on("close", (code) => {
      // ImageMagick uses exit 1 when images differ.
      if (code !== 0 && code !== 1) {
        reject(
          new Error(
            `ImageMagick compare failed (code=${code})\nstdout:\n${stdout}\nstderr:\n${stderr}`,
          ),
        );
        return;
      }

      const stderrTrimmed = stderr.trim();
      const rawMatch = stderrTrimmed.match(/^-?\d+(?:\.\d+)?/);
      const normalizedMatch = stderrTrimmed.match(/\((-?\d+(?:\.\d+)?)\)/);
      const rawMetric = Number.parseFloat(rawMatch?.[0] ?? "");
      const normalizedMetric = Number.parseFloat(normalizedMatch?.[1] ?? "");
      if (!Number.isFinite(rawMetric)) {
        reject(
          new Error(
            `Unable to parse ImageMagick diff metric from stderr='${stderrTrimmed}'`,
          ),
        );
        return;
      }
      resolve({
        rawMetric,
        normalizedMetric: Number.isFinite(normalizedMetric) ? normalizedMetric : null,
        stderr: stderrTrimmed,
      });
    });
  });
}

async function captureScenario(browser, scenario, url, outputPath) {
  const context = await browser.newContext({
    viewport: {
      width: scenario.viewport.width,
      height: scenario.viewport.height,
    },
    deviceScaleFactor: scenario.viewport.deviceScaleFactor,
    isMobile: scenario.viewport.isMobile,
    hasTouch: scenario.viewport.hasTouch,
  });

  try {
    const page = await context.newPage();
    await page.goto(url, { waitUntil: "domcontentloaded", timeout: 120000 });
    if (url.includes("/dashboard")) {
      await page.waitForSelector("[data-slot='sidebar-wrapper']", { timeout: 60000 });
    } else {
      await page.waitForSelector("#benchmark-app", { timeout: 30000 });
    }
    await page.addStyleTag({
      content:
        "*,:before,:after{animation:none!important;transition:none!important;caret-color:transparent!important}",
    });
    await page.waitForTimeout(250);
    await page.screenshot({ path: outputPath, fullPage: false });
  } finally {
    await context.close();
  }
}

async function main() {
  if (!Number.isFinite(maxDiffRatio) || maxDiffRatio < 0 || maxDiffRatio > 1) {
    fail(
      `REFERENCE_VISUAL_MAX_DIFF_RATIO must be in [0,1], got '${process.env.REFERENCE_VISUAL_MAX_DIFF_RATIO}'`,
    );
  }
  if (!["AE", "MAE", "RMSE", "DSSIM"].includes(diffMetric)) {
    fail(
      `REFERENCE_VISUAL_DIFF_METRIC must be one of AE, MAE, RMSE, DSSIM. Got '${process.env.REFERENCE_VISUAL_DIFF_METRIC ?? diffMetric}'.`,
    );
  }

  const magickBinary = detectMagickBinary();
  if (!magickBinary) {
    fail("ImageMagick is required for reference visual diff checks (`magick` or `compare`).");
  }

  await ensureDir(artifactDir);
  const browser = await chromium.launch({ headless: true });
  const summary = {
    generated_at: new Date().toISOString(),
    benchmark_url: benchmarkUrl,
    reference_url: referenceUrl,
    max_diff_ratio: maxDiffRatio,
    diff_metric: diffMetric,
    image_diff_tool: magickBinary,
    scenarios: {},
  };

  try {
    for (const scenario of scenarios) {
      const benchmarkPath = path.join(artifactDir, `${scenario.name}-benchmark.png`);
      const referencePath = path.join(artifactDir, `${scenario.name}-reference.png`);
      const diffPath = path.join(artifactDir, `${scenario.name}-diff.png`);

      await Promise.all([
        captureScenario(browser, scenario, benchmarkUrl, benchmarkPath),
        captureScenario(browser, scenario, referenceUrl, referencePath),
      ]);

      const totalPixels =
        scenario.viewport.width *
        scenario.viewport.deviceScaleFactor *
        scenario.viewport.height *
        scenario.viewport.deviceScaleFactor;
      const diffResult = await runImageDiff(
        magickBinary,
        diffMetric,
        benchmarkPath,
        referencePath,
        diffPath,
      );
      const diffRatio =
        diffMetric === "AE"
          ? diffResult.rawMetric / totalPixels
          : diffResult.normalizedMetric ?? diffResult.rawMetric;
      if (!Number.isFinite(diffRatio)) {
        fail(
          `Unable to parse normalized diff ratio for metric ${diffMetric} from '${diffResult.stderr}'.`,
        );
      }

      summary.scenarios[scenario.name] = {
        viewport: scenario.viewport,
        diff_raw: diffResult.rawMetric,
        total_pixels: totalPixels,
        diff_ratio: Number(diffRatio.toFixed(6)),
        status: diffRatio <= maxDiffRatio ? "passed" : "failed",
      };
      if (diffMetric === "AE") {
        summary.scenarios[scenario.name].diff_pixels = diffResult.rawMetric;
      }

      process.stdout.write(
        `${scenario.name}: metric=${diffMetric} diff_ratio=${summary.scenarios[scenario.name].diff_ratio} threshold=${maxDiffRatio}\n`,
      );
    }
  } finally {
    await browser.close();
  }

  const summaryPath = path.join(artifactDir, "summary.json");
  await fs.writeFile(summaryPath, `${JSON.stringify(summary, null, 2)}\n`, "utf8");
  process.stdout.write(`summary: ${summaryPath}\n`);

  const failed = Object.entries(summary.scenarios).filter(([, item]) => item.status === "failed");
  if (failed.length > 0) {
    fail(
      `Reference visual diff failed for ${failed.map(([name]) => name).join(", ")}. See ${artifactDir}.`,
    );
  }
}

main().catch((error) => {
  process.stderr.write(`${error.stack ?? error}\n`);
  process.exit(1);
});
