import fs from "node:fs/promises";
import path from "node:path";
import process from "node:process";
import { chromium } from "playwright";

const benchmarkUrl = process.env.BENCHMARK_URL ?? "http://127.0.0.1:4175/index.html";
const referenceUrl = process.env.REFERENCE_URL ?? "http://127.0.0.1:4180/dashboard";
const artifactDir =
  process.env.PARITY_ARTIFACT_DIR ??
  path.join(process.cwd(), "examples", "dashboard_benchmark", "visual-artifacts");
const debugArtifactPath =
  process.env.PARITY_DEBUG_JSON ?? path.join(artifactDir, "parity-debug.json");

const viewport = { width: 1440, height: 900 };

const CHECK_MATRIX = [
  {
    id: "shell",
    required: true,
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-sidebar-shell" }],
      reference: [
        { type: "query", value: "[data-slot='sidebar-wrapper']" },
      ],
    },
    checks: [
      { path: "rect.x", tolerance: 0 },
      { path: "rect.y", tolerance: 0 },
      { path: "rect.width", tolerance: 1 },
      { path: "rect.height", tolerance: 300 },
      { path: "styles.border-radius", tolerance: 1 },
      { path: "styles.box-shadow" },
      { path: "styles.padding-left", tolerance: 1 },
      { path: "styles.padding-right", tolerance: 1 },
      { path: "styles.padding-top", tolerance: 1 },
      { path: "styles.padding-bottom", tolerance: 1 },
    ],
  },
  {
    id: "sidebar",
    required: true,
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-sidebar" }],
      reference: [
        { type: "query", value: "[data-slot='sidebar-container']" },
      ],
    },
    checks: [
      { path: "rect.x", tolerance: 1 },
      { path: "rect.y", tolerance: 1 },
      { path: "rect.width", tolerance: 1 },
      { path: "rect.height", tolerance: 1 },
      { path: "styles.background-color" },
      { path: "styles.border-radius", tolerance: 1 },
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
    ],
  },
  {
    id: "main",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-main" }],
      reference: [{ type: "query", value: "[data-slot='sidebar-inset']" }],
    },
    checks: [
      { path: "rect.width", tolerance: 20 },
      { path: "rect.height", tolerance: 300 },
      { path: "styles.border-radius", tolerance: 1 },
      { path: "styles.padding-left", tolerance: 1 },
      { path: "styles.padding-right", tolerance: 1 },
      { path: "styles.padding-top", tolerance: 1 },
      { path: "styles.padding-bottom", tolerance: 1 },
    ],
  },
  {
    id: "inset_header",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-inset-header" }],
      reference: [
        { type: "query", value: "[data-slot='sidebar-inset'] > header" },
      ],
    },
    checks: [
      { path: "rect.x", tolerance: 8 },
      { path: "rect.y", tolerance: 8 },
      { path: "rect.width", tolerance: 20 },
      { path: "rect.height", tolerance: 10 },
      { path: "styles.padding-left", tolerance: 12 },
      { path: "styles.padding-right", tolerance: 12 },
      { path: "styles.padding-top", tolerance: 8 },
      { path: "styles.padding-bottom", tolerance: 8 },
    ],
  },
  {
    id: "main_surface",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-main-surface" }],
      reference: [{ type: "query", value: "[data-slot='sidebar-inset'] > div" }],
    },
    required: false,
    checks: [
      { path: "rect.width", tolerance: 20 },
      { path: "rect.height", tolerance: 300 },
      { path: "styles.padding-left", tolerance: 1 },
      { path: "styles.padding-right", tolerance: 1 },
      { path: "styles.padding-top", tolerance: 1 },
      { path: "styles.padding-bottom", tolerance: 1 },
    ],
  },
  {
    id: "menu_toggle",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-menu-toggle" }],
      reference: [
        { type: "query", value: "[data-slot='sidebar-trigger']" },
        { type: "role", role: "button", name: /toggle sidebar/i },
      ],
    },
    checks: [
      { path: "rect.width", tolerance: 1 },
      { path: "rect.height", tolerance: 1 },
      { path: "styles.width", tolerance: 1 },
      { path: "styles.height", tolerance: 1 },
      { path: "styles.font-size", tolerance: 0.5 },
      { path: "styles.line-height", tolerance: 1 },
      { path: "styles.padding-top", tolerance: 1 },
      { path: "styles.padding-right", tolerance: 1 },
      { path: "styles.padding-bottom", tolerance: 1 },
      { path: "styles.padding-left", tolerance: 1 },
    ],
  },
  {
    id: "actions_primary",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-open-sheet" }],
      reference: [{ type: "role", role: "button", name: /quick create/i }],
    },
    checks: [
      { path: "rect.width", tolerance: 1 },
      { path: "rect.height", tolerance: 1 },
      { path: "styles.font-size", tolerance: 0.5 },
      { path: "styles.line-height", tolerance: 1 },
      { path: "styles.padding-top", tolerance: 1 },
      { path: "styles.padding-right", tolerance: 1 },
      { path: "styles.padding-bottom", tolerance: 1 },
      { path: "styles.padding-left", tolerance: 1 },
      { path: "styles.border-radius", tolerance: 1 },
    ],
  },
  {
    id: "actions_secondary_drawer",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-open-drawer" }],
      reference: [{ type: "role", role: "button", name: /add section/i }],
    },
    checks: [
      { path: "rect.width", tolerance: 1 },
      { path: "rect.height", tolerance: 1 },
      { path: "styles.font-size", tolerance: 1 },
      { path: "styles.border-radius", tolerance: 1 },
    ],
  },
  {
    id: "actions_secondary_toast",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-popover-trigger" }],
      reference: [{ type: "role", role: "button", name: /customize columns/i }],
    },
    checks: [
      { path: "rect.width", tolerance: 1 },
      { path: "rect.height", tolerance: 1 },
      { path: "styles.font-size", tolerance: 1 },
      { path: "styles.border-radius", tolerance: 1 },
    ],
  },
  {
    id: "actions_secondary_disabled",
    required: false,
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-action-disabled" }],
      reference: [{ type: "text", value: "Disabled action" }],
    },
    checks: [
      { path: "rect.width", tolerance: 1 },
      { path: "rect.height", tolerance: 1 },
      { path: "styles.font-size", tolerance: 0.5 },
      { path: "styles.line-height", tolerance: 1 },
      { path: "styles.opacity", tolerance: 0.02 },
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
          maxDepth: 6,
          minWidth: 1000,
          minHeight: 120,
          maxWidth: 1500,
          maxHeight: 280,
        },
      ],
    },
    checks: [
      { path: "rect.width", tolerance: 20 },
      { path: "rect.height", tolerance: 40 },
      { path: "styles.gap", tolerance: 1 },
      { path: "styles.padding-top", tolerance: 1 },
      { path: "styles.padding-bottom", tolerance: 1 },
      { path: "styles.padding-left", tolerance: 1 },
      { path: "styles.padding-right", tolerance: 1 },
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
          maxDepth: 6,
          minWidth: 240,
          minHeight: 140,
          maxWidth: 420,
          maxHeight: 260,
        },
      ],
    },
    checks: [
      { path: "rect.width", tolerance: 10 },
      { path: "rect.height", tolerance: 40 },
      { path: "styles.border-radius", tolerance: 1 },
      { path: "styles.padding-top", tolerance: 1 },
      { path: "styles.padding-right", tolerance: 1 },
      { path: "styles.padding-bottom", tolerance: 1 },
      { path: "styles.padding-left", tolerance: 1 },
      { path: "styles.gap", tolerance: 1 },
    ],
  },
  {
    id: "metric_card_2",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-metric-card-2" }],
      reference: [
        {
          type: "text-ancestor",
          value: "New Customers",
          maxDepth: 6,
          minWidth: 240,
          minHeight: 140,
          maxWidth: 420,
          maxHeight: 260,
        },
      ],
    },
    checks: [
      { path: "rect.width", tolerance: 10 },
      { path: "rect.height", tolerance: 40 },
      { path: "styles.border-radius", tolerance: 1 },
      { path: "styles.padding-top", tolerance: 1 },
      { path: "styles.padding-right", tolerance: 1 },
      { path: "styles.padding-bottom", tolerance: 1 },
      { path: "styles.padding-left", tolerance: 1 },
      { path: "styles.gap", tolerance: 1 },
    ],
  },
  {
    id: "metric_card_3",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-metric-card-3" }],
      reference: [
        {
          type: "text-ancestor",
          value: "Active Accounts",
          maxDepth: 6,
          minWidth: 240,
          minHeight: 140,
          maxWidth: 420,
          maxHeight: 260,
        },
      ],
    },
    checks: [
      { path: "rect.width", tolerance: 10 },
      { path: "rect.height", tolerance: 40 },
      { path: "styles.border-radius", tolerance: 1 },
      { path: "styles.padding-top", tolerance: 1 },
      { path: "styles.padding-right", tolerance: 1 },
      { path: "styles.padding-bottom", tolerance: 1 },
      { path: "styles.padding-left", tolerance: 1 },
      { path: "styles.gap", tolerance: 1 },
    ],
  },
  {
    id: "metric_card_4",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-metric-card-4" }],
      reference: [
        {
          type: "text-ancestor",
          value: "Growth Rate",
          maxDepth: 6,
          minWidth: 240,
          minHeight: 140,
          maxWidth: 420,
          maxHeight: 260,
        },
      ],
    },
    checks: [
      { path: "rect.width", tolerance: 10 },
      { path: "rect.height", tolerance: 40 },
      { path: "styles.border-radius", tolerance: 1 },
      { path: "styles.padding-top", tolerance: 1 },
      { path: "styles.padding-right", tolerance: 1 },
      { path: "styles.padding-bottom", tolerance: 1 },
      { path: "styles.padding-left", tolerance: 1 },
      { path: "styles.gap", tolerance: 1 },
    ],
  },
  {
    id: "metric_value_1",
    required: false,
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-metric-value-1" }],
      reference: [{ type: "text", value: "$1,250.00" }],
    },
    checks: [
      { path: "styles.font-size", tolerance: 1 },
      { path: "styles.font-weight", tolerance: 1 },
      { path: "styles.line-height", tolerance: 1.5 },
    ],
  },
  {
    id: "metric_value_2",
    required: false,
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-metric-value-2" }],
      reference: [{ type: "text", value: "1,234" }],
    },
    checks: [
      { path: "styles.font-size", tolerance: 1 },
      { path: "styles.font-weight", tolerance: 1 },
      { path: "styles.line-height", tolerance: 1.5 },
    ],
  },
  {
    id: "metric_value_3",
    required: false,
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-metric-value-3" }],
      reference: [{ type: "text", value: "45,678" }],
    },
    checks: [
      { path: "styles.font-size", tolerance: 1 },
      { path: "styles.font-weight", tolerance: 1 },
      { path: "styles.line-height", tolerance: 1.5 },
    ],
  },
  {
    id: "metric_value_4",
    required: false,
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-metric-value-4" }],
      reference: [{ type: "text", value: "4.5%", pick: "first" }],
    },
    checks: [
      { path: "styles.font-size", tolerance: 1 },
      { path: "styles.font-weight", tolerance: 1 },
      { path: "styles.line-height", tolerance: 1.5 },
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
      { path: "rect.width", tolerance: 60 },
      { path: "rect.height", tolerance: 80 },
    ],
  },
  {
    id: "tab_list",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-tab-active" }],
      reference: [{ type: "role", role: "tab", selected: true }],
    },
    checks: [
      { path: "rect.width", tolerance: 18 },
      { path: "rect.height", tolerance: 8 },
      { path: "styles.padding-left", tolerance: 12 },
      { path: "styles.padding-right", tolerance: 12 },
      { path: "styles.padding-top", tolerance: 8 },
      { path: "styles.padding-bottom", tolerance: 8 },
    ],
  },
  {
    id: "tabs_active",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-tab-active" }],
      reference: [{ type: "role", role: "tab", selected: true }],
    },
    checks: [
      { path: "rect.width", tolerance: 1 },
      { path: "rect.height", tolerance: 1 },
      { path: "styles.font-size", tolerance: 0.5 },
      { path: "styles.line-height", tolerance: 1 },
      { path: "styles.padding-top", tolerance: 1 },
      { path: "styles.padding-right", tolerance: 1 },
      { path: "styles.padding-bottom", tolerance: 1 },
      { path: "styles.padding-left", tolerance: 1 },
      { path: "styles.font-weight", tolerance: 1 },
    ],
  },
  {
    id: "tabs_inactive",
    required: false,
    selectors: {
      benchmark: [{ type: "query", value: "#benchmark-tabs [role='tab'][aria-selected='false']", pick: "first" }],
      reference: [{ type: "role", role: "tab", selected: false, pick: "first" }],
    },
    checks: [
      { path: "styles.font-size", tolerance: 0.5 },
      { path: "styles.line-height", tolerance: 1 },
      { path: "styles.font-weight", tolerance: 1 },
    ],
  },
  {
    id: "tab_panel",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-tab-panel" }],
      reference: [{ type: "query", value: "[data-slot='tabs-content'][data-state='active']" }],
    },
    checks: [
      { path: "rect.width", tolerance: 50 },
      { path: "rect.height", tolerance: 60 },
      { path: "styles.padding-left", tolerance: 24 },
      { path: "styles.padding-right", tolerance: 24 },
      { path: "styles.padding-top", tolerance: 1 },
      { path: "styles.padding-bottom", tolerance: 1 },
    ],
  },
  {
    id: "select",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-select" }],
      reference: [{ type: "role", role: "combobox", name: /theme/i }],
    },
    checks: [
      { path: "rect.width", tolerance: 1 },
      { path: "rect.height", tolerance: 1 },
      { path: "styles.font-size", tolerance: 0.5 },
      { path: "styles.font-weight", tolerance: 1 },
      { path: "styles.line-height", tolerance: 1 },
      { path: "styles.padding-top", tolerance: 1 },
      { path: "styles.padding-right", tolerance: 1 },
      { path: "styles.padding-bottom", tolerance: 1 },
      { path: "styles.padding-left", tolerance: 1 },
      { path: "styles.border-radius", tolerance: 1 },
      { path: "styles.border-top-width", tolerance: 1 },
      { path: "styles.border-bottom-width", tolerance: 1 },
      { path: "meta.tag" },
      { path: "text" },
    ],
  },
  {
    id: "switch_row",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-toggle-group" }],
      reference: [{ type: "query", value: "[data-slot='toggle-group']" }],
    },
    checks: [
      { path: "rect.width", tolerance: 1 },
      { path: "rect.height", tolerance: 1 },
      { path: "styles.gap", tolerance: 4 },
    ],
  },
  {
    id: "toggle_group",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-toggle-group" }],
      reference: [
        { type: "query", value: "[data-slot='toggle-group']" },
      ],
    },
    checks: [
      { path: "rect.width", tolerance: 1 },
      { path: "rect.height", tolerance: 1 },
      { path: "styles.border-radius", tolerance: 1 },
    ],
  },
  {
    id: "switch_control",
    selectors: {
      benchmark: [{ type: "id", value: "benchmark-switch" }],
      reference: [{ type: "role", role: "switch" }],
    },
    checks: [
      { path: "rect.width", tolerance: 1 },
      { path: "rect.height", tolerance: 1 },
      { path: "styles.border-radius", tolerance: 1 },
      { path: "styles.background-color" },
    ],
    required: false,
  },
  {
    id: "breadcrumb",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-breadcrumb" }],
      reference: [{ type: "role", role: "heading", name: /documents/i }],
    },
    checks: [
      { path: "rect.width", tolerance: 20 },
      { path: "rect.height", tolerance: 10 },
      { path: "styles.font-size", tolerance: 0.5 },
    ],
  },
  {
    id: "filter_row",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-filter-row" }],
      reference: [
        {
          type: "text-ancestor",
          value: "Total Visitors",
          maxDepth: 5,
          minWidth: 1200,
          minHeight: 36,
          maxWidth: 1400,
          maxHeight: 80,
        },
      ],
    },
    checks: [
      { path: "rect.width", tolerance: 40 },
      { path: "rect.height", tolerance: 1 },
      { path: "styles.gap", tolerance: 1 },
      { path: "styles.padding-top", tolerance: 1 },
      { path: "styles.padding-right", tolerance: 1 },
      { path: "styles.padding-bottom", tolerance: 1 },
      { path: "styles.padding-left", tolerance: 1 },
    ],
  },
  {
    id: "table_root",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-insights-table" }],
      reference: [{ type: "query", value: "table" }],
    },
    checks: [
      { path: "rect.width", tolerance: 12 },
      { path: "rect.height", tolerance: 1 },
      { path: "styles.border-radius", tolerance: 8 },
      { path: "meta.checkbox_count", tolerance: 0 },
      { path: "meta.input_count", tolerance: 0 },
      { path: "meta.combobox_count", tolerance: 0 },
    ],
  },
  {
    id: "table_row_1",
    required: false,
    selectors: {
      benchmark: [{ type: "id", value: "benchmark-table-row-1" }],
      reference: [{ type: "text-ancestor", value: "Cover page", maxDepth: 8, minWidth: 120, minHeight: 24 }],
    },
    checks: [
      { path: "rect.width", tolerance: 1 },
      { path: "rect.height", tolerance: 1 },
    ],
  },
  {
    id: "table_row_2",
    required: false,
    selectors: {
      benchmark: [{ type: "id", value: "benchmark-table-row-2" }],
      reference: [{ type: "text-ancestor", value: "Table of contents", maxDepth: 8, minWidth: 120, minHeight: 24 }],
    },
    checks: [
      { path: "rect.width", tolerance: 1 },
      { path: "rect.height", tolerance: 1 },
    ],
  },
  {
    id: "table_row_3",
    required: false,
    selectors: {
      benchmark: [{ type: "id", value: "benchmark-table-row-3" }],
      reference: [{ type: "text-ancestor", value: "Executive summary", maxDepth: 8, minWidth: 120, minHeight: 24 }],
    },
    checks: [
      { path: "rect.width", tolerance: 1 },
      { path: "rect.height", tolerance: 1 },
    ],
  },
  {
    id: "popover_trigger",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-popover-trigger" }],
      reference: [{ type: "role", role: "button", name: /customize columns/i }],
    },
    checks: [
      { path: "rect.width", tolerance: 1 },
      { path: "rect.height", tolerance: 1 },
      { path: "styles.font-size", tolerance: 1 },
      { path: "styles.border-radius", tolerance: 1 },
      { path: "styles.padding-right", tolerance: 2 },
      { path: "styles.padding-left", tolerance: 2 },
    ],
  },
  {
    id: "popover_panel",
    required: false,
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-popover-panel" }],
      reference: [{ type: "query", value: "[role='menu']" }],
    },
    checks: [
      { path: "rect.x", tolerance: 1 },
      { path: "rect.y", tolerance: 1 },
      { path: "rect.width", tolerance: 1 },
      { path: "rect.height", tolerance: 1 },
      { path: "styles.box-shadow", compare: "box-shadow" },
      { path: "styles.background-color" },
      { path: "styles.border-radius", tolerance: 1 },
      { path: "styles.padding-left", tolerance: 1 },
      { path: "styles.padding-right", tolerance: 1 },
      { path: "styles.padding-top", tolerance: 1 },
      { path: "styles.padding-bottom", tolerance: 1 },
    ],
  },
  {
    id: "sheet_trigger",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-open-sheet" }],
      reference: [{ type: "role", role: "button", name: /quick create/i }],
    },
    checks: [
      { path: "rect.width", tolerance: 1 },
      { path: "rect.height", tolerance: 1 },
      { path: "styles.border-radius", tolerance: 1 },
      { path: "styles.font-size", tolerance: 0.5 },
      { path: "styles.line-height", tolerance: 1 },
    ],
  },
  {
    id: "sheet_content",
    required: false,
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-sheet-content" }],
      reference: [{ type: "text", value: "Sheet panel" }],
    },
    checks: [
      { path: "rect.width", tolerance: 1 },
      { path: "rect.height", tolerance: 1 },
      { path: "styles.padding-left", tolerance: 1 },
      { path: "styles.padding-right", tolerance: 1 },
      { path: "styles.padding-top", tolerance: 1 },
      { path: "styles.padding-bottom", tolerance: 1 },
      { path: "styles.background-color" },
      { path: "styles.border-radius", tolerance: 1 },
    ],
  },
  {
    id: "drawer_trigger",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-open-drawer" }],
      reference: [{ type: "role", role: "button", name: /^add section$/i }],
    },
    checks: [
      { path: "rect.width", tolerance: 1 },
      { path: "rect.height", tolerance: 1 },
      { path: "styles.border-radius", tolerance: 1 },
      { path: "styles.font-size", tolerance: 0.5 },
      { path: "styles.line-height", tolerance: 1 },
    ],
  },
  {
    id: "drawer_content",
    required: false,
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-drawer-content" }],
      reference: [{ type: "text", value: "Drawer panel" }],
    },
    checks: [
      { path: "rect.width", tolerance: 1 },
      { path: "rect.height", tolerance: 1 },
      { path: "styles.padding-left", tolerance: 1 },
      { path: "styles.padding-right", tolerance: 1 },
      { path: "styles.padding-top", tolerance: 1 },
      { path: "styles.padding-bottom", tolerance: 1 },
      { path: "styles.background-color" },
      { path: "styles.border-radius", tolerance: 1 },
    ],
  },
  {
    id: "toast_trigger",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-show-toast" }],
      reference: [{ type: "role", role: "button", name: /customize columns/i }],
    },
    checks: [
      { path: "rect.width", tolerance: 1 },
      { path: "rect.height", tolerance: 1 },
      { path: "styles.border-radius", tolerance: 1 },
      { path: "styles.font-size", tolerance: 0.5 },
      { path: "styles.line-height", tolerance: 1 },
    ],
  },
  {
    id: "toast_region",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-toast-region" }],
      reference: [{ type: "query", value: "[role='status']" }],
    },
    checks: [
      { path: "rect.x", tolerance: 1 },
      { path: "rect.y", tolerance: 1 },
      { path: "rect.width", tolerance: 1 },
      { path: "rect.height", tolerance: 1 },
    ],
    required: false,
  },
  {
    id: "toast_content",
    selectors: {
      benchmark: [{ type: "id", value: "#benchmark-toast-content" }],
      reference: [
        { type: "text", value: "Dashboard benchmark toast" },
        { type: "text", value: /toast/i, pick: "first" },
      ],
    },
    checks: [
      { path: "styles.font-size", tolerance: 0.5 },
      { path: "styles.font-weight", tolerance: 1 },
      { path: "styles.line-height", tolerance: 1 },
      { path: "styles.color" },
      { path: "rect.width", tolerance: 1 },
      { path: "rect.height", tolerance: 1 },
    ],
    required: false,
  },
];

const INTERACTION_MATRIX = [
  { path: "sidebar.expanded.width", tolerance: 1, required: true },
  { path: "sidebar.expanded.x", tolerance: 1, required: true },
  { path: "sidebar.expanded.y", tolerance: 1, required: true },
  { path: "sidebar.collapsed.width", tolerance: 1, required: true },
  { path: "sidebar.collapsed.x", tolerance: 15, required: true },
  { path: "sidebar.collapsed.y", tolerance: 1, required: true },
  { path: "sidebar.toggle_delta", tolerance: 1, required: true },
  { path: "popover_open.rect.width", tolerance: 1, required: false },
  { path: "popover_open.rect.height", tolerance: 1, required: false },
  { path: "sheet_open.rect.width", tolerance: 1, required: false },
  { path: "sheet_open.rect.height", tolerance: 1, required: false },
  { path: "drawer_open.rect.width", tolerance: 1, required: false },
  { path: "drawer_open.rect.height", tolerance: 1, required: false },
  { path: "toast_open.rect.width", tolerance: 1, required: false },
  { path: "toast_open.rect.height", tolerance: 1, required: false },
  { path: "popover_open.styles.background-color", tolerance: 0, required: false },
  { path: "popover_open.styles.border-radius", tolerance: 1, required: false },
  { path: "popover_open.styles.box-shadow", compare: "box-shadow", tolerance: 0, required: false },
  { path: "sheet_open.styles.background-color", tolerance: 0, required: false },
  { path: "sheet_open.styles.border-radius", tolerance: 1, required: false },
  { path: "drawer_open.styles.background-color", tolerance: 0, required: false },
  { path: "drawer_open.styles.border-radius", tolerance: 1, required: false },
  { path: "toast_open.styles.background-color", tolerance: 0, required: false },
  { path: "toast_open.styles.border-radius", tolerance: 1, required: false },
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

function toComparable(value) {
  if (value == null) return null;
  if (typeof value === "number") return value;
  if (typeof value === "string") {
    const px = parsePx(value);
    if (Number.isFinite(px)) return px;
    const trimmed = value.trim();
    return trimmed === "" ? null : trimmed;
  }

  return value;
}

function pickPath(target, path) {
  const keys = path.split(".");
  let current = target;

  for (const key of keys) {
    if (current == null || typeof current !== "object" || !(key in current)) {
      return null;
    }
    current = current[key];
  }

  return current;
}

function hasShadowTokens(source, tokens) {
  if (typeof source !== "string") return false;
  return tokens.every((token) => source.includes(token));
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
            const withinMaxWidth =
              config.maxWidth == null || rect.width <= config.maxWidth;
            const withinMaxHeight =
              config.maxHeight == null || rect.height <= config.maxHeight;
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
    resolutionDebug.required = atom.required !== false;
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
      pick: spec.pick ?? null,
      match_count: 0,
      selected: false,
      kind: "locator",
    };

    if (!locator) {
      if (resolutionDebug) resolutionDebug.attempts.push(attempt);
      continue;
    }

    // text-ancestor resolves to a single ElementHandle rather than a Locator.
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
      if (spec.pick === "first") return locator.first();
      return locator;
    }
    if (count > 1) {
      if (spec.pick === "first") {
        if (resolutionDebug) {
          attempt.selected = true;
          resolutionDebug.selected_selector_type = spec.type;
          resolutionDebug.selected_selector_value = selectorLabel(spec);
          resolutionDebug.match_count = count;
        }
        return locator.first();
      }
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
    const fullText = normalize(element.textContent);
    const text = fullText.slice(0, 400);

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
    const hasDesktopMobileText =
      fullText.toLowerCase().includes("desktop") &&
      fullText.toLowerCase().includes("mobile");

    return {
      rect: {
        x: Math.round(rect.x),
        y: Math.round(rect.y),
        width: Math.round(rect.width),
        height: Math.round(rect.height),
      },
      text,
      styles: {
        "font-size": computed.getPropertyValue("font-size"),
        "font-weight": computed.getPropertyValue("font-weight"),
        "line-height": computed.getPropertyValue("line-height"),
        "border-radius": computed.getPropertyValue("border-radius"),
        "padding-top": computed.getPropertyValue("padding-top"),
        "padding-right": computed.getPropertyValue("padding-right"),
        "padding-bottom": computed.getPropertyValue("padding-bottom"),
        "padding-left": computed.getPropertyValue("padding-left"),
        height: computed.getPropertyValue("height"),
        width: computed.getPropertyValue("width"),
        "box-shadow": computed.getPropertyValue("box-shadow"),
        "background-color": computed.getPropertyValue("background-color"),
        "border-top-width": computed.getPropertyValue("border-top-width"),
        "border-top-color": computed.getPropertyValue("border-top-color"),
        "border-bottom-width": computed.getPropertyValue("border-bottom-width"),
        color: computed.getPropertyValue("color"),
        "font-family": computed.getPropertyValue("font-family"),
        "color-scheme": computed.getPropertyValue("color-scheme"),
        background: computed.getPropertyValue("background"),
        "background-size": computed.getPropertyValue("background-size"),
        "min-height": computed.getPropertyValue("min-height"),
        "max-height": computed.getPropertyValue("max-height"),
        gap: computed.getPropertyValue("gap"),
        opacity: computed.getPropertyValue("opacity"),
      },
      meta: {
        tag: element.tagName.toLowerCase(),
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

async function captureStaticAtoms(page, mode, debug = null) {
  const atoms = {};
  const atomDebug = debug ? {} : null;
  if (debug) debug.atoms = atomDebug;

  for (const atom of CHECK_MATRIX) {
    const resolution = {};
    try {
      const locator = await resolveNode(page, atom, mode, resolution);
      if (!locator) {
        atoms[atom.id] = null;
        if (atomDebug) atomDebug[atom.id] = { ...resolution, status: "missing" };
        continue;
      }
      atoms[atom.id] = await captureNodeSnapshot(locator);
      if (atomDebug) atomDebug[atom.id] = { ...resolution, status: "captured" };
    } catch (error) {
      atoms[atom.id] = null;
      if (atomDebug) atomDebug[atom.id] = { ...resolution, status: "error", error: error.message };
      continue;
    }
  }

  return atoms;
}

async function captureRect(locator) {
  if (!locator) return null;
  return locator.evaluate((element) => {
    const rect = element.getBoundingClientRect();
    return {
      x: Math.round(rect.x),
      y: Math.round(rect.y),
      width: Math.round(rect.width),
      height: Math.round(rect.height),
    };
  });
}

function delay(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function captureInteractionSnapshot(locator) {
  if (!locator) return null;
  return locator.evaluate((element) => {
    const computed = getComputedStyle(element);
    const rect = element.getBoundingClientRect();

    return {
      rect: {
        x: Math.round(rect.x),
        y: Math.round(rect.y),
        width: Math.round(rect.width),
        height: Math.round(rect.height),
      },
      styles: {
        "background-color": computed.getPropertyValue("background-color"),
        "border-radius": computed.getPropertyValue("border-radius"),
        "box-shadow": computed.getPropertyValue("box-shadow"),
        "padding-top": computed.getPropertyValue("padding-top"),
        "padding-right": computed.getPropertyValue("padding-right"),
        "padding-bottom": computed.getPropertyValue("padding-bottom"),
        "padding-left": computed.getPropertyValue("padding-left"),
      },
    };
  });
}

async function captureInteractionSnapshots(page, mode, debug = null) {
  const atomIndex = new Map(CHECK_MATRIX.map((atom) => [atom.id, atom]));
  const sidebar = await resolveNode(page, atomIndex.get("sidebar"), mode).catch(() => null);
  const menuToggle = await resolveNode(page, atomIndex.get("menu_toggle"), mode).catch(() => null);
  const popoverTrigger = await resolveNode(page, atomIndex.get("popover_trigger"), mode).catch(() => null);
  const sheetTrigger = await resolveNode(page, atomIndex.get("sheet_trigger"), mode).catch(() => null);
  const drawerTrigger = await resolveNode(page, atomIndex.get("drawer_trigger"), mode).catch(() => null);
  const toastTrigger = await resolveNode(page, atomIndex.get("toast_trigger"), mode).catch(() => null);

  const interactions = {
    sidebar: null,
    popover_open: null,
    sheet_open: null,
    drawer_open: null,
    toast_open: null,
  };
  const interactionDebug = {
    sidebar: { attempted: false, opened: false, closed: false },
    popover_open: { attempted: false, opened: false, closed: false },
    sheet_open: { attempted: false, opened: false, closed: false },
    drawer_open: { attempted: false, opened: false, closed: false },
    toast_open: { attempted: false, opened: false, closed: false },
  };
  if (debug) debug.interactions = interactionDebug;
  const safeClick = async (locator) => {
    try {
      await locator.click({ timeout: 2000, force: true });
      return true;
    } catch {
      return false;
    }
  };
  const resolveAfterOpen = async (atomId) =>
    resolveNode(page, atomIndex.get(atomId), mode).catch(() => null);

  if (sidebar && menuToggle) {
    interactionDebug.sidebar.attempted = true;
    const expanded = await captureRect(sidebar);
    const toggledClosed = await safeClick(menuToggle);
    await delay(140);
    const collapsed = await captureRect(sidebar);
    const toggledOpen = await safeClick(menuToggle);
    await delay(140);

    if (expanded && collapsed && toggledClosed) {
      interactions.sidebar = {
        expanded,
        collapsed,
        toggle_delta: Math.abs(collapsed.width - expanded.width),
      };
      interactionDebug.sidebar.opened = true;
      interactionDebug.sidebar.closed = toggledOpen;
    }
  }

  if (popoverTrigger) {
    interactionDebug.popover_open.attempted = true;
    const opened = await safeClick(popoverTrigger);
    await delay(120);
    const popoverPanel = await resolveAfterOpen("popover_panel");
    if (popoverPanel) {
      interactions.popover_open = await captureInteractionSnapshot(popoverPanel);
      interactionDebug.popover_open.opened = interactions.popover_open != null;
    }
    if (opened) {
      await safeClick(popoverTrigger);
      await delay(120);
      interactionDebug.popover_open.closed = true;
    }
  }

  if (sheetTrigger) {
    interactionDebug.sheet_open.attempted = true;
    const opened = await safeClick(sheetTrigger);
    await delay(140);
    const sheetContent = await resolveAfterOpen("sheet_content");
    interactions.sheet_open = await captureInteractionSnapshot(sheetContent);
    interactionDebug.sheet_open.opened = interactions.sheet_open != null;
    if (opened) {
      await page.mouse.click(8, 8);
      await delay(120);
      interactionDebug.sheet_open.closed = true;
    }
  }

  if (drawerTrigger) {
    interactionDebug.drawer_open.attempted = true;
    const opened = await safeClick(drawerTrigger);
    await delay(160);
    const drawerContent = await resolveAfterOpen("drawer_content");
    interactions.drawer_open = await captureInteractionSnapshot(drawerContent);
    interactionDebug.drawer_open.opened = interactions.drawer_open != null;
    if (opened) {
      await page.mouse.click(8, 8);
      await delay(120);
      interactionDebug.drawer_open.closed = true;
    }
  }

  if (toastTrigger) {
    interactionDebug.toast_open.attempted = true;
    const opened = await safeClick(toastTrigger);
    await delay(120);
    const toastContent = await resolveAfterOpen("toast_content");
    if (toastContent) {
      interactions.toast_open = await captureInteractionSnapshot(toastContent);
      interactionDebug.toast_open.opened = interactions.toast_open != null;
    }
    if (opened) {
      const dismiss = page.getByRole("button", { name: /dismiss/i });
      const dismissCount = await dismiss.count();
      if (dismissCount > 0) {
        await dismiss.first().click().catch(() => null);
        await delay(120);
      } else {
        await page.mouse.click(8, 8);
        await delay(120);
      }
      interactionDebug.toast_open.closed = true;
    }
  }

  return interactions;
}

function compareValue(referenceValue, benchmarkValue, path, tolerance = 0, compareMode) {
  if (referenceValue == null || benchmarkValue == null) {
    return {
      path,
      status: "missing",
      reference: referenceValue,
      benchmark: benchmarkValue,
      tolerance,
    };
  }

  if (compareMode === "box-shadow") {
    const requiredTokens = ["0px 1px 3px 0px", "0px 1px 2px -1px"];
    const has = hasShadowTokens(referenceValue, requiredTokens);
    const got = hasShadowTokens(benchmarkValue, requiredTokens);
    return {
      path,
      status: has && got ? "ok" : "drift",
      tolerance,
      reference: referenceValue,
      benchmark: benchmarkValue,
    };
  }

  if (compareMode === "array-eq") {
    const normalizeText = (value) => String(value ?? "").replace(/\s+/g, " ").trim();
    const left = Array.isArray(referenceValue) ? referenceValue.map((item) => normalizeText(item)) : [];
    const right = Array.isArray(benchmarkValue) ? benchmarkValue.map((item) => normalizeText(item)) : [];
    const same = left.length === right.length && left.every((item, index) => item === right[index]);
    return {
      path,
      status: same ? "ok" : "drift",
      tolerance,
      reference: left,
      benchmark: right,
    };
  }

  const ref = toComparable(referenceValue);
  const bench = toComparable(benchmarkValue);

  if (ref == null || bench == null) {
    return {
      path,
      status: ref == null && bench == null ? "ok" : "drift",
      tolerance,
      reference: referenceValue,
      benchmark: benchmarkValue,
    };
  }

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
    status: ref === bench ? "ok" : "drift",
    tolerance,
    reference: ref,
    benchmark: bench,
  };
}

function compareSnapshots(reference, benchmark) {
  const diffs = [];

  for (const atom of CHECK_MATRIX) {
    const required = atom.required !== false;
    for (const check of atom.checks) {
      const referenceAtom = reference.atoms[atom.id];
      const benchmarkAtom = benchmark.atoms[atom.id];

      if (referenceAtom == null || benchmarkAtom == null) {
        if (required) {
          diffs.push({
            atom: atom.id,
            path: check.path,
            status: "missing",
            reference: referenceAtom,
            benchmark: benchmarkAtom,
            tolerance: check.tolerance,
          });
        }
        continue;
      }

      const diff = compareValue(
        pickPath(referenceAtom, check.path),
        pickPath(benchmarkAtom, check.path),
        check.path,
        check.tolerance ?? 0,
        check.compare,
      );

      if (diff.status !== "ok") {
        diffs.push({
          atom: atom.id,
          ...diff,
        });
      }
    }
  }

  for (const check of INTERACTION_MATRIX) {
    const referenceValue = pickPath(reference.interactions, check.path);
    const benchmarkValue = pickPath(benchmark.interactions, check.path);

    if (referenceValue == null || benchmarkValue == null) {
      if (check.required) {
        diffs.push({
          atom: "interactions",
          path: check.path,
          status: "missing",
          reference: referenceValue,
          benchmark: benchmarkValue,
          tolerance: check.tolerance,
          required: true,
        });
      }
      continue;
    }

    const diff = compareValue(referenceValue, benchmarkValue, check.path, check.tolerance ?? 0);
    if (diff.status !== "ok" && check.required) {
      diffs.push({
        atom: "interactions",
        ...diff,
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
  const debug = {};
  const atoms = await captureStaticAtoms(page, mode, debug);
  const interactions = await captureInteractionSnapshots(page, mode, debug);

  return {
    mode,
    url: page.url(),
    atoms,
    interactions,
    debug,
  };
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

    const diffs = compareSnapshots(reference, benchmark);
    const matrixById = new Map(CHECK_MATRIX.map((atom) => [atom.id, atom]));
    const enrichedDiffs = diffs.map((diff) => {
      const isSelectorMiss = diff.status === "missing" && (diff.reference == null || diff.benchmark == null);
      return {
        ...diff,
        required: diff.atom === "interactions" ? true : (matrixById.get(diff.atom)?.required ?? true) !== false,
        failure_kind: isSelectorMiss ? "selector-miss" : "value-drift",
      };
    });

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
          diffs: enrichedDiffs,
          summary: {
            total: diffs.length,
            missing: diffs.filter((diff) => diff.status === "missing").length,
            drift: diffs.filter((diff) => diff.status === "drift").length,
          },
        },
        null,
        2,
      )}\n`,
      "utf8",
    );

    process.stdout.write(`Reference: ${reference.url}\n`);
    process.stdout.write(`Benchmark: ${benchmark.url}\n\n`);
    process.stdout.write(`Debug artifact: ${debugArtifactPath}\n\n`);

    for (const diff of diffs) {
      if (diff.status === "ok") continue;
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

    process.stdout.write(`\nTotal drift items: ${diffs.length}\n`);
    if (diffs.length > 0) process.exitCode = 1;

    await context.close();
  } finally {
    await browser.close();
  }
}

main().catch((error) => {
  process.stderr.write(`${error.stack ?? error}\n`);
  process.exit(1);
});
