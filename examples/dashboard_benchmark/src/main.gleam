import gleam/dict
import gleam/dynamic/decode
import gleam/float
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import lustre
import lustre/attribute
import lustre/effect
import lustre/element as html_element
import lustre/element/html as html_el
import lustre/element/svg as svg_el
import lustre/event
import plinth/browser/window
import weft
import weft_chart/axis as wc_axis
import weft_chart/chart as wc
import weft_chart/curve as wc_curve
import weft_chart/grid as wc_grid
import weft_chart/series/area as wc_area
import weft_chart/series/common as wc_common
import weft_chart/tooltip as wc_tooltip
import weft_lustre
import weft_lustre/modal
import weft_lustre_ui
import weft_lustre_ui/badge
import weft_lustre_ui/button
import weft_lustre_ui/calendar
import weft_lustre_ui/card
import weft_lustre_ui/drawer
import weft_lustre_ui/input
import weft_lustre_ui/popover
import weft_lustre_ui/select
import weft_lustre_ui/sheet
import weft_lustre_ui/sidebar
import weft_lustre_ui/sonner
import weft_lustre_ui/table
import weft_lustre_ui/theme as ui_theme
import weft_lustre_ui/toggle_group

type TableRow {
  TableRow(
    id: String,
    header: String,
    section_type: String,
    status: String,
    target: String,
    limit: String,
    reviewer: String,
    reviewer_is_select: Bool,
  )
}

type DragState {
  DragState(
    source_index: Int,
    current_y: Float,
    start_y: Float,
    row_height: Float,
  )
}

type AppState {
  AppState(
    sidebar_collapsed: Bool,
    navigation_open: Bool,
    active_tab: String,
    team_filter: String,
    theme_menu_open: Bool,
    density: String,
    switch_on: Bool,
    is_mobile_viewport: Bool,
    viewport_width: Int,
    popover_open: Bool,
    sheet_open: Bool,
    drawer_open: Bool,
    toast_open: Bool,
    table_rows: List(TableRow),
    drag: Option(DragState),
    reviewer_open: Option(String),
    nav_menu_open: Option(#(String, Float)),
    visible_columns: List(String),
  )
}

pub type Msg {
  ToggleSidebar
  NavigationChanged(Bool)
  TabChanged(String)
  TeamChanged(String)
  ThemeMenuOpenChanged(Bool)
  SelectTheme(String)
  TableNoop
  DensityChanged(String)
  SwitchChanged(Bool)
  PopoverChanged(Bool)
  OpenSheet
  CloseSheet
  OpenDrawer
  CloseDrawer
  ShowToast
  DismissToast
  ToggleColorMode
  ViewportMeasured(Int)
  DragStart(index: Int, y: Float)
  DragMove(y: Float)
  DragEnd
  ReviewerOpenChanged(Option(String))
  NavMenuOpenChanged(Option(#(String, Float)))
  ToggleColumn(String)
}

const sheet_root_id = "benchmark-sheet"

const drawer_root_id = "benchmark-drawer"

const benchmark_root_shell_id = "benchmark-sidebar-shell"

const benchmark_sidebar_aside_id = "benchmark-sidebar"

const benchmark_main_id = "benchmark-main"

const benchmark_main_surface_id = "benchmark-main-surface"

const benchmark_inset_header_id = "benchmark-inset-header"

const benchmark_menu_toggle_id = "benchmark-menu-toggle"

const benchmark_primary_action_id = "benchmark-open-sheet"

const benchmark_secondary_action_disabled_id = "benchmark-action-disabled"

const benchmark_actions_id = "benchmark-actions"

const benchmark_metrics_row_id = "benchmark-metrics-row"

const benchmark_metric_card_id_prefix = "benchmark-metric-card-"

const benchmark_metric_value_id_prefix = "benchmark-metric-value-"

const benchmark_tab_list_id = "benchmark-tab-list"

const benchmark_active_tab_id = "benchmark-tab-active"

const benchmark_tab_panel_id = "benchmark-tab-panel"

const benchmark_select_id = "benchmark-select"

const benchmark_filter_row_id = "benchmark-filter-row"

const benchmark_switch_row_id = "benchmark-switch-row"

const benchmark_toggle_group_id = "benchmark-toggle-group"

const benchmark_chart_card_id = "benchmark-chart-card"

const benchmark_breadcrumb_id = "benchmark-breadcrumb"

const benchmark_popover_trigger_id = "benchmark-popover-trigger"

const benchmark_popover_panel_id = "benchmark-popover-panel"

const benchmark_sheet_content_id = "benchmark-sheet-content"

const benchmark_drawer_trigger_id = "benchmark-open-drawer"

const benchmark_drawer_content_id = "benchmark-drawer-content"

const benchmark_toast_trigger_id = "benchmark-show-toast"

const benchmark_toast_region_id = "benchmark-toast-region"

const benchmark_toast_content_id = "benchmark-toast-content"

fn initial_table_rows() -> List(TableRow) {
  [
    TableRow(
      id: "benchmark-table-row-1",
      header: "Cover page",
      section_type: "Cover page",
      status: "In Process",
      target: "18",
      limit: "5",
      reviewer: "eddie_lake",
      reviewer_is_select: True,
    ),
    TableRow(
      id: "benchmark-table-row-2",
      header: "Table of contents",
      section_type: "Table of contents",
      status: "Done",
      target: "29",
      limit: "24",
      reviewer: "eddie_lake",
      reviewer_is_select: True,
    ),
    TableRow(
      id: "benchmark-table-row-3",
      header: "Executive summary",
      section_type: "Narrative",
      status: "Done",
      target: "10",
      limit: "13",
      reviewer: "avery_lucas",
      reviewer_is_select: True,
    ),
    TableRow(
      id: "benchmark-table-row-4",
      header: "Technical approach",
      section_type: "Narrative",
      status: "In Process",
      target: "27",
      limit: "23",
      reviewer: "Avery Lucas",
      reviewer_is_select: False,
    ),
    TableRow(
      id: "benchmark-table-row-5",
      header: "Design",
      section_type: "Narrative",
      status: "Done",
      target: "22",
      limit: "17",
      reviewer: "Liam Turner",
      reviewer_is_select: False,
    ),
    TableRow(
      id: "benchmark-table-row-6",
      header: "Capabilities",
      section_type: "Narrative",
      status: "Done",
      target: "19",
      limit: "15",
      reviewer: "Mia James",
      reviewer_is_select: False,
    ),
    TableRow(
      id: "benchmark-table-row-7",
      header: "Integration with existing systems",
      section_type: "Narrative",
      status: "Done",
      target: "24",
      limit: "16",
      reviewer: "Noah Patel",
      reviewer_is_select: False,
    ),
    TableRow(
      id: "benchmark-table-row-8",
      header: "Innovation and advantages",
      section_type: "Narrative",
      status: "In Process",
      target: "16",
      limit: "9",
      reviewer: "Sophia Chen",
      reviewer_is_select: False,
    ),
    TableRow(
      id: "benchmark-table-row-9",
      header: "Overview of EMR's Innovative Solutions",
      section_type: "Narrative",
      status: "Done",
      target: "21",
      limit: "11",
      reviewer: "Olivia Reed",
      reviewer_is_select: False,
    ),
    TableRow(
      id: "benchmark-table-row-10",
      header: "Advanced Algorithms and Machine Learning",
      section_type: "Narrative",
      status: "Done",
      target: "30",
      limit: "25",
      reviewer: "Ethan Flores",
      reviewer_is_select: False,
    ),
  ]
}

const row_height = 49.0

fn drag_target_index(drag: DragState, row_count: Int) -> Int {
  let delta_y = drag.current_y -. drag.start_y
  let offset = float.round(delta_y /. drag.row_height)
  int.clamp(drag.source_index + offset, min: 0, max: row_count - 1)
}

fn move_to_index(rows: List(a), from from: Int, to to: Int) -> List(a) {
  case from == to {
    True -> rows
    False -> {
      let indexed = list.index_map(rows, fn(item, i) { #(i, item) })
      let item = list.key_find(indexed, from)
      case item {
        Error(_) -> rows
        Ok(source_item) -> {
          let without =
            list.filter(indexed, fn(pair) { pair.0 != from })
            |> list.map(fn(pair) { pair.1 })
          let #(before, after) = list.split(without, to)
          list.flatten([before, [source_item], after])
        }
      }
    }
  }
}

fn theme_label(value: String) -> String {
  case value {
    "theme_blue" -> "Blue"
    "theme_green" -> "Green"
    _ -> "Default"
  }
}

fn theme_for_state(state: AppState) -> weft_lustre_ui.Theme {
  let base_theme = ui_theme.theme_default()

  case state.switch_on {
    False -> base_theme
    True ->
      base_theme
      |> ui_theme.theme_primary(
        color: weft.rgb(red: 250, green: 250, blue: 250),
        on_color: weft.rgb(red: 9, green: 9, blue: 11),
      )
      |> ui_theme.theme_surface(
        color: weft.rgb(red: 9, green: 9, blue: 11),
        on_color: weft.rgb(red: 250, green: 250, blue: 250),
      )
      |> ui_theme.theme_input_surface(
        color: weft.rgb(red: 24, green: 24, blue: 27),
        on_color: weft.rgb(red: 250, green: 250, blue: 250),
      )
      |> ui_theme.theme_overlay_surface(
        color: weft.rgb(red: 24, green: 24, blue: 27),
        on_color: weft.rgb(red: 250, green: 250, blue: 250),
      )
      |> ui_theme.theme_border(color: weft.rgb(red: 39, green: 39, blue: 42))
      |> ui_theme.theme_muted_text(color: weft.rgba(
        red: 161,
        green: 161,
        blue: 170,
        alpha: 0.95,
      ))
      |> ui_theme.theme_focus_ring(color: weft.rgb(
        red: 161,
        green: 161,
        blue: 170,
      ))
      |> ui_theme.theme_scrim(color: weft.rgba(
        red: 0,
        green: 0,
        blue: 0,
        alpha: 0.7,
      ))
      |> ui_theme.theme_button_shadows(
        base: weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.0),
        hover: weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.0),
      )
  }
}

fn text_title(content: String) -> weft_lustre.Element(msg) {
  weft_lustre.el(
    attrs: [
      weft_lustre.styles([
        weft.font_size(size: weft.rem(rem: 0.875)),
        weft.font_weight(weight: weft.font_weight_value(weight: 600)),
        weft.line_height(height: weft.line_height_multiple(multiplier: 1.2)),
      ]),
    ],
    child: weft_lustre.text(content: content),
  )
}

fn text_value_id(content: String, id: String) -> weft_lustre.Element(msg) {
  weft_lustre.el(
    attrs: [
      weft_lustre.html_attribute(attribute.id(id)),
      weft_lustre.styles([
        weft.font_size(size: weft.rem(rem: 1.875)),
        weft.font_weight(weight: weft.font_weight_value(weight: 600)),
        weft.line_height(height: weft.line_height_multiple(multiplier: 1.15)),
      ]),
    ],
    child: weft_lustre.text(content: content),
  )
}

fn text_muted(
  theme: weft_lustre_ui.Theme,
  content: String,
) -> weft_lustre.Element(msg) {
  weft_lustre.el(
    attrs: [
      weft_lustre.styles([
        weft.font_size(size: weft.rem(rem: 0.75)),
        weft.text_color(color: ui_theme.muted_text(theme)),
        weft.line_height(height: weft.line_height_multiple(multiplier: 1.35)),
      ]),
    ],
    child: weft_lustre.text(content: content),
  )
}

fn text_small_strong(content: String) -> weft_lustre.Element(msg) {
  weft_lustre.el(
    attrs: [
      weft_lustre.styles([
        weft.font_size(size: weft.rem(rem: 0.8125)),
        weft.font_weight(weight: weft.font_weight_value(weight: 560)),
        weft.line_height(height: weft.line_height_multiple(multiplier: 1.3)),
      ]),
    ],
    child: weft_lustre.text(content: content),
  )
}

fn icon_stroke(paths paths: List(String)) -> weft_lustre.Element(msg) {
  weft_lustre.html(html_element.namespaced(
    "http://www.w3.org/2000/svg",
    "svg",
    [
      attribute.attribute("width", "18"),
      attribute.attribute("height", "18"),
      attribute.attribute("viewBox", "0 0 24 24"),
      attribute.attribute("fill", "none"),
      attribute.attribute("stroke", "currentColor"),
      attribute.attribute("stroke-width", "2"),
      attribute.attribute("stroke-linecap", "round"),
      attribute.attribute("stroke-linejoin", "round"),
    ],
    list.map(paths, fn(d) {
      html_element.namespaced(
        "http://www.w3.org/2000/svg",
        "path",
        [attribute.attribute("d", d)],
        [],
      )
    }),
  ))
}

fn icon_filled(paths paths: List(String)) -> weft_lustre.Element(msg) {
  weft_lustre.html(html_element.namespaced(
    "http://www.w3.org/2000/svg",
    "svg",
    [
      attribute.attribute("width", "18"),
      attribute.attribute("height", "18"),
      attribute.attribute("viewBox", "0 0 24 24"),
      attribute.attribute("fill", "currentColor"),
      attribute.attribute("stroke", "none"),
    ],
    list.map(paths, fn(d) {
      html_element.namespaced(
        "http://www.w3.org/2000/svg",
        "path",
        [attribute.attribute("d", d)],
        [],
      )
    }),
  ))
}

fn metrics_row(theme: weft_lustre_ui.Theme) -> weft_lustre.Element(Msg) {
  let #(input_surface_bg, _) = ui_theme.input_surface(theme)

  let trend_pill = fn(trend: String) {
    weft_lustre.el(
      attrs: [
        weft_lustre.styles([
          weft.display(value: weft.display_inline_flex()),
          weft.align_items(value: weft.align_items_center()),
          weft.padding_xy(x: 7, y: 3),
          weft.rounded(radius: weft.px(pixels: 9999)),
          weft.border(
            width: weft.px(pixels: 1),
            style: weft.border_style_solid(),
            color: ui_theme.border_color(theme),
          ),
          weft.font_size(size: weft.rem(rem: 0.75)),
          weft.font_weight(weight: weft.font_weight_value(weight: 560)),
          weft.background(color: input_surface_bg),
        ]),
      ],
      child: weft_lustre.text(content: case string.starts_with(trend, "+") {
        True -> "↗ " <> trend
        False ->
          case string.starts_with(trend, "-") {
            True -> "↘ " <> trend
            False -> trend
          }
      }),
    )
  }

  let metric = fn(
    label: String,
    value: String,
    trend: String,
    summary: String,
    detail: String,
    card_id: String,
    value_id: String,
  ) {
    card.card(
      theme: theme,
      attrs: [
        weft_lustre.html_attribute(attribute.id(card_id)),
        weft_lustre.styles([
          weft.height(length: weft.fixed(length: weft.px(pixels: 184))),
          weft.padding_xy(x: 0, y: 24),
          weft.spacing(pixels: 24),
        ]),
      ],
      children: [
        card.card_header(theme: theme, attrs: [], children: [
          weft_lustre.row(
            attrs: [
              weft_lustre.styles([
                weft.spacing(pixels: 6),
                weft.align_items(value: weft.align_items_start()),
                weft.justify_content(value: weft.justify_space_between()),
              ]),
            ],
            children: [
              weft_lustre.column(
                attrs: [weft_lustre.styles([weft.spacing(pixels: 6)])],
                children: [
                  text_muted(theme, label),
                  text_value_id(value, value_id),
                ],
              ),
              trend_pill(trend),
            ],
          ),
        ]),
        card.card_footer(theme: theme, attrs: [], children: [
          weft_lustre.column(
            attrs: [weft_lustre.styles([weft.spacing(pixels: 3)])],
            children: [
              text_small_strong(summary),
              text_muted(theme, detail),
            ],
          ),
        ]),
      ],
    )
  }

  weft_lustre.grid(
    attrs: [
      weft_lustre.styles([
        weft.grid_columns(tracks: [weft.grid_fr(fr: 1.0)]),
        weft.spacing(pixels: 16),
        weft.padding_xy(x: 24, y: 0),
        weft.when(query: weft.max_width(length: weft.px(pixels: 767)), attrs: [
          weft.padding_xy(x: 16, y: 0),
        ]),
        weft.when(query: weft.min_width(length: weft.px(pixels: 900)), attrs: [
          weft.grid_columns(tracks: [
            weft.grid_repeat(count: 4, track: weft.grid_fr(fr: 1.0)),
          ]),
        ]),
      ]),
      weft_lustre.html_attribute(attribute.id(benchmark_metrics_row_id)),
    ],
    children: [
      metric(
        "Total Revenue",
        "$1,250.00",
        "+12.5%",
        "Trending up this month ↗",
        "Visitors for the last 6 months",
        benchmark_metric_card_id_prefix <> "1",
        benchmark_metric_value_id_prefix <> "1",
      ),
      metric(
        "New Customers",
        "1,234",
        "-20%",
        "Down 20% this period ↘",
        "Acquisition needs attention",
        benchmark_metric_card_id_prefix <> "2",
        benchmark_metric_value_id_prefix <> "2",
      ),
      metric(
        "Active Accounts",
        "45,678",
        "+12.5%",
        "Strong user retention ↗",
        "Engagement exceed targets",
        benchmark_metric_card_id_prefix <> "3",
        benchmark_metric_value_id_prefix <> "3",
      ),
      metric(
        "Growth Rate",
        "4.5%",
        "+4.5%",
        "Steady performance increase ↗",
        "Meets growth projections",
        benchmark_metric_card_id_prefix <> "4",
        benchmark_metric_value_id_prefix <> "4",
      ),
    ],
  )
}

fn insights_table(
  theme: weft_lustre_ui.Theme,
  state: AppState,
) -> weft_lustre.Element(Msg) {
  let #(input_surface_bg, _) = ui_theme.input_surface(theme)

  let reviewer_options: List(#(String, String)) = [
    #("assign", "Assign reviewer"),
    #("eddie_lake", "Eddie Lake"),
    #("jamik_tashpulatov", "Jamik Tashpulatov"),
    #("avery_lucas", "Avery Lucas"),
  ]

  let reviewer_label = fn(value: String) {
    case list.find(reviewer_options, fn(opt) { opt.0 == value }) {
      Ok(#(_, lbl)) -> lbl
      Error(_) -> value
    }
  }

  let checkbox_cell = fn(checked: Bool) {
    weft_lustre.element_tag(
      tag: "button",
      base_weft_attrs: [weft.el_layout()],
      attrs: [
        weft_lustre.html_attribute(attribute.type_("button")),
        weft_lustre.html_attribute(attribute.role("checkbox")),
        weft_lustre.html_attribute(
          attribute.attribute("aria-checked", case checked {
            True -> "true"
            False -> "false"
          }),
        ),
        weft_lustre.styles([
          weft.width(length: weft.fixed(length: weft.px(pixels: 16))),
          weft.height(length: weft.fixed(length: weft.px(pixels: 16))),
          weft.border(
            width: weft.px(pixels: 1),
            style: weft.border_style_solid(),
            color: ui_theme.border_color(theme),
          ),
          weft.rounded(radius: weft.px(pixels: 4)),
          weft.background(color: case checked {
            True -> ui_theme.border_color(theme)
            False -> input_surface_bg
          }),
        ]),
      ],
      children: [],
    )
  }

  let metric_input = fn(value: String, id: String) {
    input.text_input(
      theme: theme,
      config: input.text_input_config(value: value, on_input: fn(_value) {
        TableNoop
      })
        |> input.text_input_attrs(attrs: [
          weft_lustre.html_attribute(attribute.id(id)),
          weft_lustre.styles([
            weft.width(length: weft.fixed(length: weft.px(pixels: 64))),
            weft.height(length: weft.fixed(length: weft.px(pixels: 32))),
            weft.padding_xy(x: 8, y: 4),
            weft.text_align(align: weft.text_align_right()),
            weft.background(color: weft.rgba(
              red: 0,
              green: 0,
              blue: 0,
              alpha: 0.0,
            )),
            weft.border(
              width: weft.px(pixels: 1),
              style: weft.border_style_solid(),
              color: weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.0),
            ),
            weft.shadows(shadows: []),
          ]),
        ]),
    )
  }

  let grip_icon =
    weft_lustre.html(
      svg_el.svg(
        [
          attribute.attribute("width", "16"),
          attribute.attribute("height", "16"),
          attribute.attribute("viewBox", "0 0 24 24"),
          attribute.attribute("fill", "currentColor"),
          attribute.attribute("stroke", "none"),
        ],
        [
          svg_el.circle([
            attribute.attribute("cx", "9"),
            attribute.attribute("cy", "5"),
            attribute.attribute("r", "1"),
          ]),
          svg_el.circle([
            attribute.attribute("cx", "9"),
            attribute.attribute("cy", "12"),
            attribute.attribute("r", "1"),
          ]),
          svg_el.circle([
            attribute.attribute("cx", "9"),
            attribute.attribute("cy", "19"),
            attribute.attribute("r", "1"),
          ]),
          svg_el.circle([
            attribute.attribute("cx", "15"),
            attribute.attribute("cy", "5"),
            attribute.attribute("r", "1"),
          ]),
          svg_el.circle([
            attribute.attribute("cx", "15"),
            attribute.attribute("cy", "12"),
            attribute.attribute("r", "1"),
          ]),
          svg_el.circle([
            attribute.attribute("cx", "15"),
            attribute.attribute("cy", "19"),
            attribute.attribute("r", "1"),
          ]),
        ],
      ),
    )

  let section_type_badge = fn(section_type: String) {
    badge.badge(
      theme: theme,
      config: badge.badge_config()
        |> badge.badge_variant(variant: badge.badge_outline())
        |> badge.badge_attrs(attrs: [
          weft_lustre.styles([
            weft.text_color(color: ui_theme.muted_text(theme)),
            weft.padding_xy(x: 6, y: 1),
          ]),
        ]),
      child: weft_lustre.text(content: section_type),
    )
  }

  let status_icon = fn(status: String) {
    let icon = case status {
      "Done" ->
        weft_lustre.html(
          svg_el.svg(
            [
              attribute.attribute("width", "16"),
              attribute.attribute("height", "16"),
              attribute.attribute("viewBox", "0 0 24 24"),
              attribute.attribute("fill", "#22c55e"),
              attribute.attribute("stroke", "none"),
            ],
            [
              svg_el.path([
                attribute.attribute(
                  "d",
                  "M17 3.34a10 10 0 1 1-14.995 8.984L2 12l.005-.324A10 10 0 0 1 17 3.34zm-1.293 5.953a1 1 0 0 0-1.32-.083l-.094.083L11 12.585l-1.293-1.292-.094-.083a1 1 0 0 0-1.403 1.403l.083.094 2 2 .094.083a1 1 0 0 0 1.226 0l.094-.083 4-4 .083-.094a1 1 0 0 0-.083-1.32z",
                ),
              ]),
            ],
          ),
        )
      _ ->
        weft_lustre.html(
          svg_el.svg(
            [
              attribute.attribute("width", "16"),
              attribute.attribute("height", "16"),
              attribute.attribute("viewBox", "0 0 24 24"),
              attribute.attribute("fill", "none"),
              attribute.attribute("stroke", "#737373"),
              attribute.attribute("stroke-width", "2"),
            ],
            [
              svg_el.path([
                attribute.attribute("d", "M12 6l0 -3"),
              ]),
              svg_el.path([
                attribute.attribute("d", "M16.25 7.75l2.15 -2.15"),
              ]),
              svg_el.path([
                attribute.attribute("d", "M18 12l3 0"),
              ]),
              svg_el.path([
                attribute.attribute("d", "M16.25 16.25l2.15 2.15"),
              ]),
              svg_el.path([
                attribute.attribute("d", "M12 18l0 3"),
              ]),
              svg_el.path([
                attribute.attribute("d", "M7.75 16.25l-2.15 2.15"),
              ]),
              svg_el.path([
                attribute.attribute("d", "M6 12l-3 0"),
              ]),
              svg_el.path([
                attribute.attribute("d", "M7.75 7.75l-2.15 -2.15"),
              ]),
            ],
          ),
        )
    }

    weft_lustre.row(
      attrs: [
        weft_lustre.styles([
          weft.align_items(value: weft.align_items_center()),
          weft.spacing(pixels: 6),
        ]),
      ],
      children: [
        icon,
        weft_lustre.text(content: status),
      ],
    )
  }

  let reviewer_cell = fn(reviewer: String, row_id: String, use_select: Bool) {
    case use_select {
      False -> weft_lustre.text(content: reviewer)
      True -> {
        let label = reviewer_label(reviewer)
        let is_open = state.reviewer_open == Some(row_id)
        let #(_, surface_fg) = ui_theme.surface(theme)

        popover.popover(
          theme: theme,
          config: popover.popover_config(open: is_open, on_toggle: fn(open) {
            ReviewerOpenChanged(case open {
              True -> Some(row_id)
              False -> None
            })
          })
            |> popover.popover_attrs(attrs: [
              weft_lustre.styles([
                weft.align_items(value: weft.align_items_center()),
              ]),
            ])
            |> popover.popover_trigger_attrs(attrs: [
              weft_lustre.html_attribute(attribute.id(row_id <> "-reviewer")),
              weft_lustre.styles([
                weft.width(length: weft.fixed(length: weft.px(pixels: 160))),
                weft.height(length: weft.fixed(length: weft.px(pixels: 32))),
                weft.justify_content(value: weft.justify_space_between()),
                weft.padding_xy(x: 8, y: 0),
                weft.font_size(size: weft.rem(rem: 0.875)),
                weft.text_color(color: ui_theme.muted_text(theme)),
              ]),
            ])
            |> popover.popover_panel_attrs(attrs: [
              weft_lustre.styles([
                weft.width(length: weft.fixed(length: weft.px(pixels: 160))),
                weft.padding_xy(x: 4, y: 4),
                weft.spacing(pixels: 2),
              ]),
            ]),
          trigger: weft_lustre.row(
            attrs: [
              weft_lustre.styles([
                weft.spacing(pixels: 4),
                weft.align_items(value: weft.align_items_center()),
                weft.width(length: weft.fill()),
              ]),
            ],
            children: [
              weft_lustre.el(
                attrs: [weft_lustre.styles([weft.width(length: weft.fill())])],
                child: weft_lustre.text(content: label),
              ),
              icon_stroke(paths: ["M6 9l6 6l6 -6"]),
            ],
          ),
          panel: weft_lustre.column(
            attrs: [weft_lustre.styles([weft.spacing(pixels: 2)])],
            children: list.map(reviewer_options, fn(opt) {
              let #(opt_value, opt_label) = opt
              let is_selected = opt_value == reviewer
              weft_lustre.element_tag(
                tag: "button",
                base_weft_attrs: [weft.el_layout()],
                attrs: [
                  weft_lustre.html_attribute(attribute.type_("button")),
                  weft_lustre.html_attribute(
                    event.on_click(ReviewerOpenChanged(None)),
                  ),
                  weft_lustre.styles([
                    weft.display(value: weft.display_flex()),
                    weft.align_items(value: weft.align_items_center()),
                    weft.width(length: weft.fill()),
                    weft.padding_xy(x: 8, y: 4),
                    weft.rounded(radius: ui_theme.radius_md(theme)),
                    weft.font_size(size: weft.rem(rem: 0.875)),
                    weft.cursor(cursor: weft.cursor_pointer()),
                    weft.background(color: case is_selected {
                      True -> weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.06)
                      False -> weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.0)
                    }),
                    weft.border(
                      width: weft.px(pixels: 0),
                      style: weft.border_style_solid(),
                      color: weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.0),
                    ),
                    weft.mouse_over(attrs: [
                      weft.background(color: case state.switch_on {
                        True ->
                          weft.rgba(
                            red: 255,
                            green: 255,
                            blue: 255,
                            alpha: 0.06,
                          )
                        False ->
                          weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.04)
                      }),
                    ]),
                    weft.text_color(color: surface_fg),
                  ]),
                ],
                children: [weft_lustre.text(content: opt_label)],
              )
            }),
          ),
        )
      }
    }
  }

  let col_visible_attrs = fn(col_key: String) {
    case list.contains(state.visible_columns, col_key) {
      True -> []
      False -> [weft_lustre.styles([weft.display_none()])]
    }
  }

  let header =
    table.table_header(attrs: [], children: [
      table.table_row(theme: theme, attrs: [], children: [
        table.table_head(
          theme: theme,
          attrs: [
            weft_lustre.styles([
              weft.width(length: weft.fixed(length: weft.px(pixels: 44))),
            ]),
          ],
          child: weft_lustre.text(content: ""),
        ),
        table.table_head(theme: theme, attrs: [], child: checkbox_cell(False)),
        table.table_head(
          theme: theme,
          attrs: col_visible_attrs("header"),
          child: weft_lustre.text(content: "Header"),
        ),
        table.table_head(
          theme: theme,
          attrs: col_visible_attrs("section_type"),
          child: weft_lustre.text(content: "Section Type"),
        ),
        table.table_head(
          theme: theme,
          attrs: col_visible_attrs("status"),
          child: weft_lustre.text(content: "Status"),
        ),
        table.table_head(
          theme: theme,
          attrs: col_visible_attrs("target"),
          child: weft_lustre.text(content: "Target"),
        ),
        table.table_head(
          theme: theme,
          attrs: col_visible_attrs("limit"),
          child: weft_lustre.text(content: "Limit"),
        ),
        table.table_head(
          theme: theme,
          attrs: col_visible_attrs("reviewer"),
          child: weft_lustre.text(content: "Reviewer"),
        ),
        table.table_head(
          theme: theme,
          attrs: [],
          child: weft_lustre.text(content: ""),
        ),
      ]),
    ])

  let row_count = list.length(state.table_rows)
  let target_idx = case state.drag {
    None -> -1
    Some(d) -> drag_target_index(d, row_count)
  }
  let source_idx = case state.drag {
    None -> -1
    Some(d) -> d.source_index
  }

  let row_shift = fn(i: Int) -> Float {
    case state.drag {
      None -> 0.0
      Some(_) -> {
        case i == source_idx {
          True -> 0.0
          False ->
            case source_idx < target_idx {
              True ->
                case i > source_idx && i <= target_idx {
                  True -> float.negate(row_height)
                  False -> 0.0
                }
              False ->
                case i >= target_idx && i < source_idx {
                  True -> row_height
                  False -> 0.0
                }
            }
        }
      }
    }
  }

  let render_row = fn(r: TableRow, index: Int) {
    let is_source = source_idx == index
    let shift_y = row_shift(index)
    table.table_row(
      theme: theme,
      attrs: [
        weft_lustre.html_attribute(attribute.id(r.id)),
        weft_lustre.styles(
          list.flatten([
            [
              weft.transition(
                property: weft.transition_property_transform(),
                duration: weft.ms(milliseconds: 200),
                easing: weft.cubic_bezier(x1: 0.25, y1: 1.0, x2: 0.5, y2: 1.0),
              ),
              weft.transform(items: [
                weft.translate(
                  x: weft.px(pixels: 0),
                  y: weft.px(pixels: float.round(shift_y)),
                ),
              ]),
            ],
            case is_source {
              True -> [weft.alpha(opacity: 0.4)]
              False -> []
            },
          ]),
        ),
      ],
      children: [
        table.table_cell(
          attrs: [
            weft_lustre.styles([
              weft.width(length: weft.fixed(length: weft.px(pixels: 44))),
              weft.text_color(color: ui_theme.muted_text(theme)),
              weft.cursor(cursor: weft.cursor_grab()),
              weft.user_select(value: weft.user_select_none()),
            ]),
            weft_lustre.html_attribute(attribute.attribute(
              "touch-action",
              "none",
            )),
            weft_lustre.html_attribute(
              event.on("pointerdown", {
                use y <- decode.field("clientY", decode.float)
                decode.success(DragStart(index:, y:))
              }),
            ),
          ],
          child: grip_icon,
        ),
        table.table_cell(attrs: [], child: checkbox_cell(False)),
        table.table_cell(
          attrs: col_visible_attrs("header"),
          child: weft_lustre.text(content: r.header),
        ),
        table.table_cell(
          attrs: col_visible_attrs("section_type"),
          child: section_type_badge(r.section_type),
        ),
        table.table_cell(
          attrs: col_visible_attrs("status"),
          child: status_icon(r.status),
        ),
        table.table_cell(
          attrs: col_visible_attrs("target"),
          child: metric_input(r.target, r.id <> "-target"),
        ),
        table.table_cell(
          attrs: col_visible_attrs("limit"),
          child: metric_input(r.limit, r.id <> "-limit"),
        ),
        table.table_cell(
          attrs: col_visible_attrs("reviewer"),
          child: reviewer_cell(r.reviewer, r.id, r.reviewer_is_select),
        ),
        table.table_cell(
          attrs: [],
          child: weft_lustre.html(
            html_element.namespaced(
              "http://www.w3.org/2000/svg",
              "svg",
              [
                attribute.attribute("width", "16"),
                attribute.attribute("height", "16"),
                attribute.attribute("viewBox", "0 0 24 24"),
                attribute.attribute("fill", "currentColor"),
                attribute.attribute("stroke", "none"),
              ],
              [
                html_element.namespaced(
                  "http://www.w3.org/2000/svg",
                  "circle",
                  [
                    attribute.attribute("cx", "12"),
                    attribute.attribute("cy", "5"),
                    attribute.attribute("r", "1"),
                  ],
                  [],
                ),
                html_element.namespaced(
                  "http://www.w3.org/2000/svg",
                  "circle",
                  [
                    attribute.attribute("cx", "12"),
                    attribute.attribute("cy", "12"),
                    attribute.attribute("r", "1"),
                  ],
                  [],
                ),
                html_element.namespaced(
                  "http://www.w3.org/2000/svg",
                  "circle",
                  [
                    attribute.attribute("cx", "12"),
                    attribute.attribute("cy", "19"),
                    attribute.attribute("r", "1"),
                  ],
                  [],
                ),
              ],
            ),
          ),
        ),
      ],
    )
  }

  let body =
    table.table_body(
      attrs: [],
      children: list.index_map(state.table_rows, render_row),
    )

  let drag_overlay = case state.drag {
    None -> weft_lustre.none()
    Some(drag) -> {
      let source_row =
        list.index_map(state.table_rows, fn(r, i) { #(i, r) })
        |> list.key_find(drag.source_index)

      let floating_row = case source_row {
        Error(_) -> weft_lustre.none()
        Ok(r) ->
          weft_lustre.row(
            attrs: [
              weft_lustre.styles([
                weft.position(value: weft.position_fixed()),
                weft.left(length: weft.px(pixels: 0)),
                weft.top(
                  length: weft.px(pixels: float.round(
                    drag.current_y -. row_height /. 2.0,
                  )),
                ),
                weft.width(length: weft.fill()),
                weft.height(
                  length: weft.fixed(
                    length: weft.px(pixels: float.round(row_height)),
                  ),
                ),
                weft.pointer_events(value: weft.pointer_events_none()),
                weft.alpha(opacity: 0.95),
                weft.background(color: {
                  let #(bg, _) = ui_theme.surface(theme)
                  bg
                }),
                weft.shadows(shadows: [
                  weft.shadow(
                    x: weft.px(pixels: 0),
                    y: weft.px(pixels: 8),
                    blur: weft.px(pixels: 24),
                    spread: weft.px(pixels: -4),
                    color: weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.25),
                  ),
                ]),
                weft.padding_xy(x: 16, y: 12),
                weft.spacing(pixels: 16),
                weft.align_items(value: weft.align_items_center()),
                weft.font_size(size: weft.rem(rem: 0.875)),
                weft.border(
                  width: weft.px(pixels: 1),
                  style: weft.border_style_solid(),
                  color: ui_theme.border_color(theme),
                ),
                weft.rounded(radius: ui_theme.radius_md(theme)),
              ]),
            ],
            children: [
              grip_icon,
              weft_lustre.text(content: r.header),
              section_type_badge(r.section_type),
              status_icon(r.status),
            ],
          )
      }

      weft_lustre.in_front(child: weft_lustre.el(
        attrs: [
          weft_lustre.styles([
            weft.position(value: weft.position_fixed()),
            weft.inset(length: weft.px(pixels: 0)),
            weft.cursor(cursor: weft.cursor_grabbing()),
            weft.user_select(value: weft.user_select_none()),
          ]),
          weft_lustre.html_attribute(
            event.advanced("pointermove", {
              use y <- decode.field("clientY", decode.float)
              decode.success(event.handler(
                dispatch: DragMove(y:),
                prevent_default: True,
                stop_propagation: False,
              ))
            }),
          ),
          weft_lustre.html_attribute(event.on(
            "pointerup",
            decode.success(DragEnd),
          )),
          weft_lustre.html_attribute(event.on(
            "pointercancel",
            decode.success(DragEnd),
          )),
        ],
        child: floating_row,
      ))
    }
  }

  weft_lustre.el(
    attrs: [],
    child: weft_lustre.column(attrs: [], children: [
      table.table(
        theme: theme,
        attrs: [
          weft_lustre.html_attribute(attribute.id("benchmark-insights-table")),
          weft_lustre.styles([
            weft.height(length: weft.fixed(length: weft.px(pixels: 570))),
          ]),
        ],
        children: [header, body],
      ),
      drag_overlay,
    ]),
  )
}

fn benchmark_tabs(
  theme: weft_lustre_ui.Theme,
  state: AppState,
) -> weft_lustre.Element(Msg) {
  let #(surface_bg, _) = ui_theme.surface(theme)
  let #(input_surface_bg, _) = ui_theme.input_surface(theme)
  let tabs_list_bg = case state.switch_on {
    True -> weft.rgba(red: 250, green: 250, blue: 250, alpha: 0.08)
    False -> weft.rgb(red: 244, green: 244, blue: 245)
  }

  let calendar_days = [
    calendar.calendar_day(label: "1"),
    calendar.calendar_day(label: "2"),
    calendar.calendar_day_selected(day: calendar.calendar_day(label: "3")),
    calendar.calendar_day(label: "4"),
    calendar.calendar_day(label: "5"),
    calendar.calendar_day(label: "6"),
    calendar.calendar_day(label: "7"),
    calendar.calendar_day(label: "8"),
    calendar.calendar_day(label: "9"),
    calendar.calendar_day(label: "10"),
    calendar.calendar_day(label: "11"),
    calendar.calendar_day(label: "12"),
    calendar.calendar_day(label: "13"),
    calendar.calendar_day(label: "14"),
  ]

  let scrollable_panel = fn(child: weft_lustre.Element(Msg)) {
    weft_lustre.el(
      attrs: [
        weft_lustre.styles([
          weft.overflow_x(overflow: weft.overflow_auto()),
          weft.overflow_y(overflow: weft.overflow_hidden()),
        ]),
      ],
      child: child,
    )
  }

  let outline_panel =
    weft_lustre.column(
      attrs: [weft_lustre.styles([weft.spacing(pixels: 12)])],
      children: [
        weft_lustre.el(
          attrs: [weft_lustre.styles([weft.padding_xy(x: 24, y: 0)])],
          child: scrollable_panel(insights_table(theme, state)),
        ),
        weft_lustre.row(
          attrs: [
            weft_lustre.styles([
              weft.height(length: weft.fixed(length: weft.px(pixels: 44))),
              weft.padding_xy(x: 24, y: 0),
              weft.align_items(value: weft.align_items_center()),
              weft.justify_content(value: weft.justify_space_between()),
            ]),
          ],
          children: [
            text_muted(
              theme,
              "0 of "
                <> int.to_string(list.length(state.table_rows))
                <> " row(s) selected.",
            ),
            weft_lustre.row(
              attrs: [
                weft_lustre.styles([
                  weft.spacing(pixels: 6),
                  weft.align_items(value: weft.align_items_center()),
                ]),
              ],
              children: [
                text_muted(theme, "Page 1 of 1"),
                button.button(
                  theme: theme,
                  config: button.button_config(on_press: TableNoop)
                    |> button.button_variant(variant: button.secondary())
                    |> button.button_disabled()
                    |> button.button_attrs(attrs: [
                      weft_lustre.styles([
                        weft.width(
                          length: weft.fixed(length: weft.px(pixels: 28)),
                        ),
                        weft.height(
                          length: weft.fixed(length: weft.px(pixels: 28)),
                        ),
                        weft.padding(pixels: 0),
                        weft.justify_content(value: weft.justify_center()),
                      ]),
                    ]),
                  label: icon_stroke(paths: [
                    "M15 6l-6 6l6 6",
                  ]),
                ),
                button.button(
                  theme: theme,
                  config: button.button_config(on_press: TableNoop)
                    |> button.button_variant(variant: button.secondary())
                    |> button.button_disabled()
                    |> button.button_attrs(attrs: [
                      weft_lustre.styles([
                        weft.width(
                          length: weft.fixed(length: weft.px(pixels: 28)),
                        ),
                        weft.height(
                          length: weft.fixed(length: weft.px(pixels: 28)),
                        ),
                        weft.padding(pixels: 0),
                        weft.justify_content(value: weft.justify_center()),
                      ]),
                    ]),
                  label: icon_stroke(paths: [
                    "M9 6l6 6l-6 6",
                  ]),
                ),
              ],
            ),
          ],
        ),
      ],
    )

  let content = case state.active_tab {
    "outline" -> outline_panel
    "key_personnel" ->
      calendar.calendar(
        theme: theme,
        config: calendar.calendar_config(),
        days: calendar_days,
      )
    "focus_documents" -> outline_panel
    _ ->
      weft_lustre.html(
        wc.area_chart(
          data: [
            dp(label: "Mon", desktop: 34, mobile: 24),
            dp(label: "Tue", desktop: 48, mobile: 33),
            dp(label: "Wed", desktop: 28, mobile: 20),
            dp(label: "Thu", desktop: 55, mobile: 38),
            dp(label: "Fri", desktop: 61, mobile: 42),
          ],
          width: 400,
          height: 200,
          children: [
            wc.cartesian_grid(
              wc_grid.cartesian_grid_config()
              |> wc_grid.grid_stroke(color: "#e4e4e7")
              |> wc_grid.grid_vertical(show: False),
            ),
            wc.x_axis(wc_axis.x_axis_config()),
            wc.area(
              wc_area.area_config(
                data_key: "desktop",
                meta: wc_common.series_meta()
                  |> wc_common.series_name(name: "Desktop"),
              )
              |> wc_area.area_curve_type(wc_curve.MonotoneX)
              |> wc_area.area_fill("#71717a")
              |> wc_area.area_fill_opacity(0.3)
              |> wc_area.area_stroke("#71717a")
              |> wc_area.area_stroke_width(2.0),
            ),
            wc.area(
              wc_area.area_config(
                data_key: "mobile",
                meta: wc_common.series_meta()
                  |> wc_common.series_name(name: "Mobile"),
              )
              |> wc_area.area_curve_type(wc_curve.MonotoneX)
              |> wc_area.area_fill("#a1a1aa")
              |> wc_area.area_fill_opacity(0.2)
              |> wc_area.area_stroke("#a1a1aa")
              |> wc_area.area_stroke_width(1.5),
            ),
            wc.tooltip(wc_tooltip.tooltip_config()),
          ],
        ),
      )
  }

  let tab_trigger = fn(value: String, label: String, count: Option(Int)) {
    let is_active = state.active_tab == value
    let active_attrs = case is_active {
      True -> [
        weft_lustre.html_attribute(attribute.id(benchmark_active_tab_id)),
      ]
      False -> []
    }
    let badge_bg = case state.switch_on {
      True -> weft.rgba(red: 255, green: 255, blue: 255, alpha: 0.3)
      False -> weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.3)
    }
    let label_el = case count {
      None -> weft_lustre.text(content: label)
      Some(n) ->
        weft_lustre.row(
          attrs: [
            weft_lustre.styles([
              weft.spacing(pixels: 6),
              weft.align_items(value: weft.align_items_center()),
            ]),
          ],
          children: [
            weft_lustre.text(content: label),
            weft_lustre.element_tag(
              tag: "span",
              base_weft_attrs: [weft.el_layout()],
              attrs: [
                weft_lustre.styles([
                  weft.display(value: weft.display_inline_flex()),
                  weft.align_items(value: weft.align_items_center()),
                  weft.justify_content(value: weft.justify_center()),
                  weft.background(color: badge_bg),
                  weft.rounded(radius: weft.px(pixels: 9999)),
                  weft.font_size(size: weft.rem(rem: 0.75)),
                  weft.font_weight(weight: weft.font_weight_value(weight: 500)),
                  weft.padding_xy(x: 4, y: 2),
                  weft.width(length: weft.minimum(
                    base: weft.shrink(),
                    min: weft.px(pixels: 20),
                  )),
                ]),
              ],
              children: [weft_lustre.text(content: int.to_string(n))],
            ),
          ],
        )
    }

    button.button(
      theme: theme,
      config: button.button_config(on_press: TabChanged(value))
        |> button.button_variant(variant: button.secondary())
        |> button.button_attrs(attrs: list.append(
          [
            weft_lustre.html_attribute(attribute.role("tab")),
            weft_lustre.html_attribute(attribute.aria_selected(is_active)),
            weft_lustre.styles([
              weft.height(length: weft.fixed(length: weft.px(pixels: 30))),
              weft.padding_xy(x: 8, y: 4),
              weft.font_size(size: weft.rem(rem: 0.875)),
              weft.font_weight(weight: weft.font_weight_value(weight: 500)),
              weft.line_height(height: weft.line_height_multiple(
                multiplier: 1.43,
              )),
              weft.shadows(shadows: []),
              case is_active {
                True -> weft.background(color: input_surface_bg)
                False ->
                  weft.background(color: weft.rgba(
                    red: 0,
                    green: 0,
                    blue: 0,
                    alpha: 0.0,
                  ))
              },
              case is_active {
                True ->
                  weft.border(
                    width: weft.px(pixels: 1),
                    style: weft.border_style_solid(),
                    color: ui_theme.border_color(theme),
                  )
                False ->
                  weft.border(
                    width: weft.px(pixels: 1),
                    style: weft.border_style_solid(),
                    color: weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.0),
                  )
              },
            ]),
          ],
          active_attrs,
        )),
      label: label_el,
    )
  }

  let mobile_view_select =
    select.select(
      theme: theme,
      config: select.select_config(
        value: state.active_tab,
        on_change: TabChanged,
        options: [
          select.select_option(value: "outline", label: "Outline"),
          select.select_option(
            value: "past_performance",
            label: "Past Performance",
          ),
          select.select_option(value: "key_personnel", label: "Key Personnel"),
          select.select_option(
            value: "focus_documents",
            label: "Focus Documents",
          ),
        ],
      )
        |> select.select_attrs(attrs: [
          weft_lustre.styles([
            weft.display_none(),
            weft.width(length: weft.fixed(length: weft.px(pixels: 136))),
            weft.height(length: weft.fixed(length: weft.px(pixels: 32))),
            weft.when(
              query: weft.max_width(length: weft.px(pixels: 767)),
              attrs: [
                weft.display(value: weft.display_inline_flex()),
              ],
            ),
          ]),
        ]),
    )

  let tabs_list =
    weft_lustre.row(
      attrs: [
        weft_lustre.html_attribute(attribute.id(benchmark_tab_list_id)),
        weft_lustre.html_attribute(attribute.role("tablist")),
        weft_lustre.html_attribute(attribute.style("width", "fit-content")),
        weft_lustre.styles([
          weft.spacing(pixels: 4),
          weft.padding_xy(x: 3, y: 3),
          weft.rounded(radius: ui_theme.radius_md(theme)),
          weft.background(color: tabs_list_bg),
          weft.when(query: weft.max_width(length: weft.px(pixels: 767)), attrs: [
            weft.display_none(),
          ]),
        ]),
      ],
      children: [
        tab_trigger("outline", "Outline", None),
        tab_trigger("past_performance", "Past Performance", Some(3)),
        tab_trigger("key_personnel", "Key Personnel", Some(2)),
        tab_trigger("focus_documents", "Focus Documents", None),
      ],
    )

  let controls =
    weft_lustre.row(
      attrs: [
        weft_lustre.styles([
          weft.spacing(pixels: 8),
          weft.align_items(value: weft.align_items_center()),
          weft.justify_content(value: weft.justify_end()),
        ]),
        weft_lustre.html_attribute(attribute.id(benchmark_actions_id)),
      ],
      children: [
        popover.popover(
          theme: theme,
          config: popover.popover_config(
            open: state.popover_open,
            on_toggle: PopoverChanged,
          )
            |> popover.popover_trigger_attrs(attrs: [
              weft_lustre.styles([
                weft.height(length: weft.fixed(length: weft.px(pixels: 32))),
                weft.padding_xy(x: 10, y: 0),
                weft.font_size(size: weft.rem(rem: 0.875)),
              ]),
              weft_lustre.html_attribute(attribute.id(
                benchmark_popover_trigger_id,
              )),
            ])
            |> popover.popover_panel_attrs(attrs: [
              weft_lustre.html_attribute(attribute.id(
                benchmark_popover_panel_id,
              )),
            ]),
          trigger: weft_lustre.row(
            attrs: [
              weft_lustre.styles([
                weft.spacing(pixels: 6),
                weft.align_items(value: weft.align_items_center()),
              ]),
            ],
            children: [
              weft_lustre.html(
                html_element.namespaced(
                  "http://www.w3.org/2000/svg",
                  "svg",
                  [
                    attribute.attribute("width", "16"),
                    attribute.attribute("height", "16"),
                    attribute.attribute("viewBox", "0 0 24 24"),
                    attribute.attribute("fill", "none"),
                    attribute.attribute("stroke", "currentColor"),
                    attribute.attribute("stroke-width", "2"),
                    attribute.attribute("stroke-linecap", "round"),
                    attribute.attribute("stroke-linejoin", "round"),
                  ],
                  [
                    html_element.namespaced(
                      "http://www.w3.org/2000/svg",
                      "path",
                      [
                        attribute.attribute(
                          "d",
                          "M4 4m0 2a2 2 0 0 1 2 -2h12a2 2 0 0 1 2 2v12a2 2 0 0 1 -2 2h-12a2 2 0 0 1 -2 -2z",
                        ),
                      ],
                      [],
                    ),
                    html_element.namespaced(
                      "http://www.w3.org/2000/svg",
                      "path",
                      [attribute.attribute("d", "M12 4l0 16")],
                      [],
                    ),
                  ],
                ),
              ),
              weft_lustre.text(content: "Customize Columns"),
            ],
          ),
          panel: {
            let #(_, surface_fg) = ui_theme.surface(theme)

            let col_toggle = fn(col_key: String, col_label: String) {
              let is_visible = list.contains(state.visible_columns, col_key)

              weft_lustre.element_tag(
                tag: "button",
                base_weft_attrs: [weft.el_layout()],
                attrs: [
                  weft_lustre.html_attribute(attribute.type_("button")),
                  weft_lustre.html_attribute(
                    event.on_click(ToggleColumn(col_key)),
                  ),
                  weft_lustre.styles([
                    weft.display(value: weft.display_flex()),
                    weft.align_items(value: weft.align_items_center()),
                    weft.spacing(pixels: 8),
                    weft.width(length: weft.fill()),
                    weft.padding_xy(x: 6, y: 5),
                    weft.rounded(radius: ui_theme.radius_md(theme)),
                    weft.font_size(size: weft.rem(rem: 0.8125)),
                    weft.cursor(cursor: weft.cursor_pointer()),
                    weft.background(color: weft.rgba(
                      red: 0,
                      green: 0,
                      blue: 0,
                      alpha: 0.0,
                    )),
                    weft.border(
                      width: weft.px(pixels: 0),
                      style: weft.border_style_solid(),
                      color: weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.0),
                    ),
                    weft.mouse_over(attrs: [
                      weft.background(color: case state.switch_on {
                        True ->
                          weft.rgba(
                            red: 255,
                            green: 255,
                            blue: 255,
                            alpha: 0.06,
                          )
                        False ->
                          weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.04)
                      }),
                    ]),
                    weft.text_color(color: surface_fg),
                  ]),
                ],
                children: [
                  weft_lustre.el(
                    attrs: [
                      weft_lustre.styles([
                        weft.width(
                          length: weft.fixed(length: weft.px(pixels: 14)),
                        ),
                        weft.height(
                          length: weft.fixed(length: weft.px(pixels: 14)),
                        ),
                        weft.border(
                          width: weft.px(pixels: 1),
                          style: weft.border_style_solid(),
                          color: ui_theme.border_color(theme),
                        ),
                        weft.rounded(radius: weft.px(pixels: 3)),
                        weft.background(color: case is_visible {
                          True -> ui_theme.border_color(theme)
                          False ->
                            weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.0)
                        }),
                      ]),
                    ],
                    child: weft_lustre.none(),
                  ),
                  weft_lustre.text(content: col_label),
                ],
              )
            }

            weft_lustre.column(
              attrs: [weft_lustre.styles([weft.spacing(pixels: 2)])],
              children: [
                col_toggle("header", "Header"),
                col_toggle("section_type", "Section Type"),
                col_toggle("status", "Status"),
                col_toggle("target", "Target"),
                col_toggle("limit", "Limit"),
                col_toggle("reviewer", "Reviewer"),
              ],
            )
          },
        ),
        button.button(
          theme: theme,
          config: button.button_config(on_press: OpenDrawer)
            |> button.button_variant(variant: button.secondary())
            |> button.button_attrs(attrs: [
              weft_lustre.styles([
                weft.height(length: weft.fixed(length: weft.px(pixels: 32))),
                weft.padding_xy(x: 10, y: 0),
              ]),
              weft_lustre.html_attribute(attribute.id(
                benchmark_drawer_trigger_id,
              )),
            ]),
          label: weft_lustre.row(
            attrs: [
              weft_lustre.styles([
                weft.spacing(pixels: 6),
                weft.align_items(value: weft.align_items_center()),
              ]),
            ],
            children: [
              weft_lustre.html(
                html_element.namespaced(
                  "http://www.w3.org/2000/svg",
                  "svg",
                  [
                    attribute.attribute("width", "16"),
                    attribute.attribute("height", "16"),
                    attribute.attribute("viewBox", "0 0 24 24"),
                    attribute.attribute("fill", "none"),
                    attribute.attribute("stroke", "currentColor"),
                    attribute.attribute("stroke-width", "2"),
                    attribute.attribute("stroke-linecap", "round"),
                    attribute.attribute("stroke-linejoin", "round"),
                  ],
                  [
                    html_element.namespaced(
                      "http://www.w3.org/2000/svg",
                      "path",
                      [attribute.attribute("d", "M12 5l0 14")],
                      [],
                    ),
                    html_element.namespaced(
                      "http://www.w3.org/2000/svg",
                      "path",
                      [attribute.attribute("d", "M5 12l14 0")],
                      [],
                    ),
                  ],
                ),
              ),
              weft_lustre.text(content: "Add Section"),
            ],
          ),
        ),
      ],
    )

  weft_lustre.column(
    attrs: [
      weft_lustre.html_attribute(attribute.id("benchmark-tabs")),
      weft_lustre.styles([
        weft.spacing(pixels: 24),
      ]),
    ],
    children: [
      weft_lustre.row(
        attrs: [
          weft_lustre.styles([
            weft.align_items(value: weft.align_items_center()),
            weft.justify_content(value: weft.justify_space_between()),
            weft.padding_xy(x: 24, y: 0),
            weft.when(
              query: weft.max_width(length: weft.px(pixels: 767)),
              attrs: [weft.padding_xy(x: 16, y: 0)],
            ),
          ]),
        ],
        children: [
          weft_lustre.row(
            attrs: [
              weft_lustre.styles([
                weft.align_items(value: weft.align_items_center()),
              ]),
            ],
            children: [tabs_list, mobile_view_select],
          ),
          controls,
        ],
      ),
      weft_lustre.el(
        attrs: [
          weft_lustre.html_attribute(attribute.id(benchmark_tab_panel_id)),
          weft_lustre.styles([
            weft.border(
              width: weft.px(pixels: 1),
              style: weft.border_style_solid(),
              color: ui_theme.border_color(theme),
            ),
            weft.rounded(radius: ui_theme.radius_md(theme)),
            weft.background(color: surface_bg),
          ]),
        ],
        child: content,
      ),
    ],
  )
}

fn filter_row(
  theme: weft_lustre_ui.Theme,
  state: AppState,
) -> weft_lustre.Element(Msg) {
  let density_toggle =
    toggle_group.toggle_group(
      theme: theme,
      config: toggle_group.toggle_group_config(
        value: state.density,
        on_change: DensityChanged,
      )
        |> toggle_group.toggle_group_attrs(attrs: [
          weft_lustre.styles([
            weft.width(length: weft.fixed(length: weft.px(pixels: 356))),
            weft.height(length: weft.fixed(length: weft.px(pixels: 36))),
            weft.when(
              query: weft.max_width(length: weft.px(pixels: 767)),
              attrs: [
                weft.display_none(),
              ],
            ),
          ]),
          weft_lustre.html_attribute(attribute.id(benchmark_toggle_group_id)),
        ]),
      items: [
        toggle_group.toggle_item(value: "last_3_months", label: "Last 3 months"),
        toggle_group.toggle_item(value: "last_30_days", label: "Last 30 days"),
        toggle_group.toggle_item(value: "last_7_days", label: "Last 7 days"),
      ],
    )

  let density_select =
    select.select(
      theme: theme,
      config: select.select_config(
        value: state.density,
        on_change: DensityChanged,
        options: [
          select.select_option(value: "last_3_months", label: "Last 3 months"),
          select.select_option(value: "last_30_days", label: "Last 30 days"),
          select.select_option(value: "last_7_days", label: "Last 7 days"),
        ],
      )
        |> select.select_attrs(attrs: [
          weft_lustre.styles([
            weft.display_none(),
            weft.width(length: weft.fixed(length: weft.px(pixels: 160))),
            weft.height(length: weft.fixed(length: weft.px(pixels: 32))),
            weft.when(
              query: weft.max_width(length: weft.px(pixels: 767)),
              attrs: [
                weft.display(value: weft.display_inline_flex()),
              ],
            ),
          ]),
        ]),
    )

  weft_lustre.row(
    attrs: [
      weft_lustre.styles([
        weft.height(length: weft.fixed(length: weft.px(pixels: 44))),
        weft.padding_xy(x: 24, y: 0),
        weft.when(query: weft.max_width(length: weft.px(pixels: 767)), attrs: [
          weft.padding_xy(x: 16, y: 0),
        ]),
        weft.spacing(pixels: 8),
        weft.align_items(value: weft.align_items_center()),
        weft.justify_content(value: weft.justify_space_between()),
      ]),
      weft_lustre.html_attribute(attribute.id(benchmark_filter_row_id)),
    ],
    children: [
      weft_lustre.column(
        attrs: [weft_lustre.styles([weft.spacing(pixels: 2)])],
        children: [
          text_title("Total Visitors"),
          text_muted(theme, "Total for the last 3 months"),
        ],
      ),
      weft_lustre.row(
        attrs: [
          weft_lustre.styles([
            weft.spacing(pixels: 8),
            weft.align_items(value: weft.align_items_center()),
          ]),
          weft_lustre.html_attribute(attribute.id(benchmark_switch_row_id)),
        ],
        children: [density_toggle, density_select],
      ),
    ],
  )
}

fn drop_first(items: List(a), count: Int) -> List(a) {
  case count <= 0 {
    True -> items
    False ->
      case items {
        [] -> []
        [_, ..rest] -> drop_first(rest, count - 1)
      }
  }
}

fn take_last(items: List(a), count: Int) -> List(a) {
  let total = list.length(items)
  let drop_count = case total > count {
    True -> total - count
    False -> 0
  }

  drop_first(items, drop_count)
}

fn dp(
  label label: String,
  desktop desktop: Int,
  mobile mobile: Int,
) -> wc.DataPoint {
  wc.DataPoint(
    category: label,
    values: dict.from_list([
      #("desktop", int.to_float(desktop)),
      #("mobile", int.to_float(mobile)),
    ]),
  )
}

fn chart_width(state: AppState) -> Int {
  let sidebar_w = case state.sidebar_collapsed || state.is_mobile_viewport {
    True -> 0
    False -> 288
  }
  // viewport minus sidebar, outer horizontal padding (24px x 2), card margins (23px x 2)
  let raw = state.viewport_width - sidebar_w - 94
  case raw < 300 {
    True -> 300
    False -> raw
  }
}

fn chart_card(
  theme: weft_lustre_ui.Theme,
  state: AppState,
) -> weft_lustre.Element(Msg) {
  let #(surface_bg, _) = ui_theme.surface(theme)

  let chart_data = [
    dp(label: "Apr 1", desktop: 222, mobile: 150),
    dp(label: "Apr 2", desktop: 97, mobile: 180),
    dp(label: "Apr 3", desktop: 167, mobile: 120),
    dp(label: "Apr 4", desktop: 242, mobile: 260),
    dp(label: "Apr 5", desktop: 373, mobile: 290),
    dp(label: "Apr 6", desktop: 301, mobile: 340),
    dp(label: "Apr 7", desktop: 245, mobile: 180),
    dp(label: "Apr 8", desktop: 409, mobile: 320),
    dp(label: "Apr 9", desktop: 59, mobile: 110),
    dp(label: "Apr 10", desktop: 261, mobile: 190),
    dp(label: "Apr 11", desktop: 327, mobile: 350),
    dp(label: "Apr 12", desktop: 292, mobile: 210),
    dp(label: "Apr 13", desktop: 342, mobile: 380),
    dp(label: "Apr 14", desktop: 137, mobile: 220),
    dp(label: "Apr 15", desktop: 120, mobile: 170),
    dp(label: "Apr 16", desktop: 138, mobile: 190),
    dp(label: "Apr 17", desktop: 446, mobile: 360),
    dp(label: "Apr 18", desktop: 364, mobile: 410),
    dp(label: "Apr 19", desktop: 243, mobile: 180),
    dp(label: "Apr 20", desktop: 89, mobile: 150),
    dp(label: "Apr 21", desktop: 137, mobile: 200),
    dp(label: "Apr 22", desktop: 224, mobile: 170),
    dp(label: "Apr 23", desktop: 138, mobile: 230),
    dp(label: "Apr 24", desktop: 387, mobile: 290),
    dp(label: "Apr 25", desktop: 215, mobile: 250),
    dp(label: "Apr 26", desktop: 75, mobile: 130),
    dp(label: "Apr 27", desktop: 383, mobile: 420),
    dp(label: "Apr 28", desktop: 122, mobile: 180),
    dp(label: "Apr 29", desktop: 315, mobile: 240),
    dp(label: "Apr 30", desktop: 454, mobile: 380),
    dp(label: "May 1", desktop: 165, mobile: 220),
    dp(label: "May 2", desktop: 293, mobile: 310),
    dp(label: "May 3", desktop: 247, mobile: 190),
    dp(label: "May 4", desktop: 385, mobile: 420),
    dp(label: "May 5", desktop: 481, mobile: 390),
    dp(label: "May 6", desktop: 498, mobile: 520),
    dp(label: "May 7", desktop: 388, mobile: 300),
    dp(label: "May 8", desktop: 149, mobile: 210),
    dp(label: "May 9", desktop: 227, mobile: 180),
    dp(label: "May 10", desktop: 293, mobile: 330),
    dp(label: "May 11", desktop: 335, mobile: 270),
    dp(label: "May 12", desktop: 197, mobile: 240),
    dp(label: "May 13", desktop: 197, mobile: 160),
    dp(label: "May 14", desktop: 448, mobile: 490),
    dp(label: "May 15", desktop: 473, mobile: 380),
    dp(label: "May 16", desktop: 338, mobile: 400),
    dp(label: "May 17", desktop: 499, mobile: 420),
    dp(label: "May 18", desktop: 315, mobile: 350),
    dp(label: "May 19", desktop: 235, mobile: 180),
    dp(label: "May 20", desktop: 177, mobile: 230),
    dp(label: "May 21", desktop: 82, mobile: 140),
    dp(label: "May 22", desktop: 81, mobile: 120),
    dp(label: "May 23", desktop: 252, mobile: 290),
    dp(label: "May 24", desktop: 294, mobile: 220),
    dp(label: "May 25", desktop: 201, mobile: 250),
    dp(label: "May 26", desktop: 213, mobile: 170),
    dp(label: "May 27", desktop: 420, mobile: 460),
    dp(label: "May 28", desktop: 233, mobile: 190),
    dp(label: "May 29", desktop: 78, mobile: 130),
    dp(label: "May 30", desktop: 340, mobile: 280),
    dp(label: "May 31", desktop: 178, mobile: 230),
    dp(label: "Jun 1", desktop: 178, mobile: 200),
    dp(label: "Jun 2", desktop: 470, mobile: 410),
    dp(label: "Jun 3", desktop: 103, mobile: 160),
    dp(label: "Jun 4", desktop: 439, mobile: 380),
    dp(label: "Jun 5", desktop: 88, mobile: 140),
    dp(label: "Jun 6", desktop: 294, mobile: 250),
    dp(label: "Jun 7", desktop: 323, mobile: 370),
    dp(label: "Jun 8", desktop: 385, mobile: 320),
    dp(label: "Jun 9", desktop: 438, mobile: 480),
    dp(label: "Jun 10", desktop: 155, mobile: 200),
    dp(label: "Jun 11", desktop: 92, mobile: 150),
    dp(label: "Jun 12", desktop: 492, mobile: 420),
    dp(label: "Jun 13", desktop: 81, mobile: 130),
    dp(label: "Jun 14", desktop: 426, mobile: 380),
    dp(label: "Jun 15", desktop: 307, mobile: 350),
    dp(label: "Jun 16", desktop: 371, mobile: 310),
    dp(label: "Jun 17", desktop: 475, mobile: 520),
    dp(label: "Jun 18", desktop: 107, mobile: 170),
    dp(label: "Jun 19", desktop: 341, mobile: 290),
    dp(label: "Jun 20", desktop: 408, mobile: 450),
    dp(label: "Jun 21", desktop: 169, mobile: 210),
    dp(label: "Jun 22", desktop: 317, mobile: 270),
    dp(label: "Jun 23", desktop: 480, mobile: 530),
    dp(label: "Jun 24", desktop: 132, mobile: 180),
    dp(label: "Jun 25", desktop: 141, mobile: 190),
    dp(label: "Jun 26", desktop: 434, mobile: 380),
    dp(label: "Jun 27", desktop: 448, mobile: 490),
    dp(label: "Jun 28", desktop: 149, mobile: 200),
    dp(label: "Jun 29", desktop: 103, mobile: 160),
    dp(label: "Jun 30", desktop: 446, mobile: 400),
  ]
  let day_window = case state.density {
    "last_30_days" -> 30
    "last_7_days" -> 7
    _ -> 90
  }
  let filtered_chart_data = take_last(chart_data, day_window)

  weft_lustre.column(
    attrs: [
      weft_lustre.html_attribute(attribute.id(benchmark_chart_card_id)),
      weft_lustre.html_attribute(attribute.attribute("style", "margin: 0 23px;")),
      weft_lustre.styles([
        weft.spacing(pixels: 24),
        weft.padding_xy(x: 0, y: 24),
        weft.rounded(radius: ui_theme.radius_md(theme)),
        weft.border(
          width: weft.px(pixels: 1),
          style: weft.border_style_solid(),
          color: ui_theme.border_color(theme),
        ),
        weft.background(color: surface_bg),
      ]),
    ],
    children: [
      filter_row(theme, state),
      weft_lustre.html(
        html_el.div([attribute.styles([#("padding", "0 24px")])], [
          wc.area_chart(
            data: filtered_chart_data,
            width: chart_width(state),
            height: 250,
            children: [
              wc.cartesian_grid(
                wc_grid.cartesian_grid_config()
                |> wc_grid.grid_stroke(color: "#e4e4e7")
                |> wc_grid.grid_vertical(show: False),
              ),
              wc.x_axis(
                wc_axis.x_axis_config()
                |> wc_axis.axis_tick_line(show: False)
                |> wc_axis.axis_axis_line(show: False),
              ),
              wc.y_axis(wc_axis.y_axis_config() |> wc_axis.axis_hide()),
              wc.area(
                wc_area.area_config(
                  data_key: "mobile",
                  meta: wc_common.series_meta()
                    |> wc_common.series_name(name: "Mobile"),
                )
                |> wc_area.area_curve_type(wc_curve.Natural)
                |> wc_area.area_stack_id("a")
                |> wc_area.area_gradient_fill("chart-mobile-grad", [
                  wc_area.GradientStop(
                    offset: "5%",
                    color: "#a1a1aa",
                    opacity: 0.8,
                  ),
                  wc_area.GradientStop(
                    offset: "95%",
                    color: "#a1a1aa",
                    opacity: 0.1,
                  ),
                ])
                |> wc_area.area_fill("url(#chart-mobile-grad)")
                |> wc_area.area_stroke("#a1a1aa")
                |> wc_area.area_stroke_width(2.0),
              ),
              wc.area(
                wc_area.area_config(
                  data_key: "desktop",
                  meta: wc_common.series_meta()
                    |> wc_common.series_name(name: "Desktop"),
                )
                |> wc_area.area_curve_type(wc_curve.Natural)
                |> wc_area.area_stack_id("a")
                |> wc_area.area_gradient_fill("chart-desktop-grad", [
                  wc_area.GradientStop(
                    offset: "5%",
                    color: "#71717a",
                    opacity: 1.0,
                  ),
                  wc_area.GradientStop(
                    offset: "95%",
                    color: "#71717a",
                    opacity: 0.1,
                  ),
                ])
                |> wc_area.area_fill("url(#chart-desktop-grad)")
                |> wc_area.area_stroke("#71717a")
                |> wc_area.area_stroke_width(2.0),
              ),
              wc.tooltip(
                wc_tooltip.tooltip_config()
                |> wc_tooltip.tooltip_show_active_dot(show: True),
              ),
            ],
          ),
        ]),
      ),
      weft_lustre.el(
        attrs: [
          weft_lustre.styles([
            weft.position(value: weft.position_absolute()),
            weft.top(length: weft.px(pixels: -10_000)),
            weft.left(length: weft.px(pixels: -10_000)),
          ]),
        ],
        child: weft_lustre.text(content: "Mobile Desktop"),
      ),
    ],
  )
}

fn app_shell(
  theme: weft_lustre_ui.Theme,
  state: AppState,
) -> weft_lustre.Element(Msg) {
  let #(surface_bg, _) = ui_theme.surface(theme)

  let sidebar_header =
    weft_lustre.row(
      attrs: [
        weft_lustre.styles([
          weft.height(length: weft.fixed(length: weft.px(pixels: 36))),
          weft.spacing(pixels: 8),
          weft.align_items(value: weft.align_items_center()),
          weft.padding_xy(x: 4, y: 0),
          weft.rounded(radius: ui_theme.radius_md(theme)),
        ]),
      ],
      children: [
        icon_stroke(paths: [
          "M5.636 5.636a9 9 0 1 0 12.728 12.728a9 9 0 0 0 -12.728 -12.728z",
          "M16.243 7.757a6 6 0 0 0 -8.486 0",
        ]),
        weft_lustre.el(
          attrs: [
            weft_lustre.styles([
              weft.font_size(size: weft.rem(rem: 1.0)),
              weft.font_weight(weight: weft.font_weight_value(weight: 600)),
              weft.line_height(height: weft.line_height_multiple(
                multiplier: 1.2,
              )),
            ]),
          ],
          child: weft_lustre.text(content: "Acme Inc."),
        ),
      ],
    )

  let nav_item = fn(
    icon_el: weft_lustre.Element(Msg),
    label: String,
    active: Bool,
  ) {
    let #(_surface_bg, surface_fg) = ui_theme.surface(theme)
    let is_menu_open = case state.nav_menu_open {
      Some(#(lbl, _)) -> lbl == label
      None -> False
    }

    let hover_bg = case state.switch_on {
      True -> weft.rgba(red: 250, green: 250, blue: 250, alpha: 0.08)
      False -> weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.04)
    }

    let dots_btn =
      weft_lustre.element_tag(
        tag: "button",
        base_weft_attrs: [weft.el_layout()],
        attrs: [
          weft_lustre.html_attribute(attribute.type_("button")),
          weft_lustre.html_attribute(attribute.class("nav-dots")),
          weft_lustre.html_attribute(
            event.on("click", {
              use y <- decode.field("clientY", decode.float)
              decode.success(NavMenuOpenChanged(Some(#(label, y))))
            }),
          ),
          weft_lustre.styles([
            weft.width(length: weft.fixed(length: weft.px(pixels: 24))),
            weft.height(length: weft.fixed(length: weft.px(pixels: 24))),
            weft.padding(pixels: 0),
            weft.display(value: weft.display_flex()),
            weft.align_items(value: weft.align_items_center()),
            weft.justify_content(value: weft.justify_center()),
            weft.alpha(opacity: case is_menu_open {
              True -> 1.0
              False -> 0.0
            }),
            weft.border(
              width: weft.px(pixels: 0),
              style: weft.border_style_solid(),
              color: weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.0),
            ),
            weft.background(color: weft.rgba(
              red: 0,
              green: 0,
              blue: 0,
              alpha: 0.0,
            )),
            weft.rounded(radius: ui_theme.radius_md(theme)),
            weft.cursor(cursor: weft.cursor_pointer()),
          ]),
        ],
        children: [weft_lustre.text(content: "⋮")],
      )

    weft_lustre.row(
      attrs: [
        weft_lustre.html_attribute(attribute.class("nav-item")),
        weft_lustre.styles([
          weft.height(length: weft.fixed(length: weft.px(pixels: 32))),
          weft.padding_xy(x: 8, y: 0),
          weft.rounded(radius: ui_theme.radius_md(theme)),
          weft.font_size(size: weft.rem(rem: 0.875)),
          weft.font_weight(weight: weft.font_weight_value(weight: 500)),
          weft.spacing(pixels: 8),
          weft.align_items(value: weft.align_items_center()),
          case active {
            True -> weft.text_color(color: surface_fg)
            False -> weft.text_color(color: ui_theme.muted_text(theme))
          },
          case active {
            True ->
              case state.switch_on {
                True ->
                  weft.background(color: weft.rgba(
                    red: 250,
                    green: 250,
                    blue: 250,
                    alpha: 0.08,
                  ))
                False ->
                  weft.background(color: weft.rgba(
                    red: 0,
                    green: 0,
                    blue: 0,
                    alpha: 0.04,
                  ))
              }
            False ->
              weft.background(color: weft.rgba(
                red: 0,
                green: 0,
                blue: 0,
                alpha: 0.0,
              ))
          },
          weft.mouse_over(attrs: [weft.background(color: hover_bg)]),
          weft.cursor(cursor: weft.cursor_pointer()),
        ]),
      ],
      children: [
        icon_el,
        weft_lustre.text(content: label),
        weft_lustre.el(
          attrs: [weft_lustre.styles([weft.width(length: weft.fill())])],
          child: weft_lustre.none(),
        ),
        dots_btn,
      ],
    )
  }

  let nav_group_label = fn(label: String) {
    weft_lustre.el(
      attrs: [
        weft_lustre.styles([
          weft.padding_xy(x: 8, y: 6),
          weft.font_size(size: weft.rem(rem: 0.75)),
          weft.font_weight(weight: weft.font_weight_value(weight: 500)),
          weft.text_color(color: ui_theme.muted_text(theme)),
          weft.line_height(height: weft.line_height_multiple(multiplier: 1.35)),
        ]),
      ],
      child: weft_lustre.text(content: label),
    )
  }

  let nav_group = fn(children: List(weft_lustre.Element(Msg))) {
    weft_lustre.column(
      attrs: [weft_lustre.styles([weft.spacing(pixels: 2)])],
      children: children,
    )
  }

  let dark_mode_item =
    weft_lustre.row(
      attrs: [
        weft_lustre.styles([
          weft.height(length: weft.fixed(length: weft.px(pixels: 32))),
          weft.padding_xy(x: 8, y: 0),
          weft.rounded(radius: ui_theme.radius_md(theme)),
          weft.font_size(size: weft.rem(rem: 0.875)),
          weft.font_weight(weight: weft.font_weight_value(weight: 500)),
          weft.spacing(pixels: 8),
          weft.align_items(value: weft.align_items_center()),
          weft.text_color(color: ui_theme.muted_text(theme)),
        ]),
      ],
      children: [
        icon_stroke(paths: [
          "M12 12m-9 0a9 9 0 1 0 18 0a9 9 0 1 0 -18 0",
          "M12 3l0 18",
          "M12 9l4.65 -4.65",
          "M12 14.3l7.37 -7.37",
          "M12 19.6l8.85 -8.85",
        ]),
        weft_lustre.text(content: "Dark Mode"),
        weft_lustre.el(
          attrs: [weft_lustre.styles([weft.width(length: weft.fill())])],
          child: weft_lustre.none(),
        ),
        weft_lustre.row(
          attrs: [
            weft_lustre.html_attribute(event.on_click(ToggleColorMode)),
            weft_lustre.styles([
              weft.width(length: weft.fixed(length: weft.px(pixels: 36))),
              weft.height(length: weft.fixed(length: weft.px(pixels: 20))),
              weft.rounded(radius: weft.px(pixels: 9999)),
              weft.background(color: case state.switch_on {
                True -> weft.rgb(red: 24, green: 24, blue: 27)
                False -> weft.rgb(red: 212, green: 212, blue: 216)
              }),
              weft.padding(pixels: 2),
              weft.cursor(cursor: weft.cursor_pointer()),
              weft.transition(
                property: weft.transition_property_background_color(),
                duration: weft.ms(milliseconds: 150),
                easing: weft.ease_in_out(),
              ),
            ]),
          ],
          children: case state.switch_on {
            False -> [
              weft_lustre.el(
                attrs: [
                  weft_lustre.styles([
                    weft.width(length: weft.fixed(length: weft.px(pixels: 16))),
                    weft.height(length: weft.fixed(length: weft.px(pixels: 16))),
                    weft.rounded(radius: weft.px(pixels: 9999)),
                    weft.background(color: weft.rgb(
                      red: 255,
                      green: 255,
                      blue: 255,
                    )),
                  ]),
                ],
                child: weft_lustre.none(),
              ),
              weft_lustre.el(
                attrs: [weft_lustre.styles([weft.width(length: weft.fill())])],
                child: weft_lustre.none(),
              ),
            ]
            True -> [
              weft_lustre.el(
                attrs: [weft_lustre.styles([weft.width(length: weft.fill())])],
                child: weft_lustre.none(),
              ),
              weft_lustre.el(
                attrs: [
                  weft_lustre.styles([
                    weft.width(length: weft.fixed(length: weft.px(pixels: 16))),
                    weft.height(length: weft.fixed(length: weft.px(pixels: 16))),
                    weft.rounded(radius: weft.px(pixels: 9999)),
                    weft.background(color: weft.rgb(
                      red: 255,
                      green: 255,
                      blue: 255,
                    )),
                  ]),
                ],
                child: weft_lustre.none(),
              ),
            ]
          },
        ),
      ],
    )

  let sidebar_body = [
    nav_group([
      weft_lustre.row(
        attrs: [
          weft_lustre.styles([
            weft.spacing(pixels: 6),
            weft.align_items(value: weft.align_items_center()),
          ]),
        ],
        children: [
          button.button(
            theme: theme,
            config: button.button_config(on_press: OpenSheet)
              |> button.button_variant(variant: button.primary())
              |> button.button_attrs(attrs: [
                weft_lustre.styles([
                  weft.height(length: weft.fixed(length: weft.px(pixels: 32))),
                  weft.width(length: weft.fill()),
                  weft.padding_xy(x: 8, y: 0),
                  weft.font_size(size: weft.rem(rem: 0.875)),
                ]),
                weft_lustre.html_attribute(attribute.id(
                  benchmark_primary_action_id,
                )),
              ]),
            label: weft_lustre.row(
              attrs: [
                weft_lustre.styles([
                  weft.spacing(pixels: 6),
                  weft.align_items(value: weft.align_items_center()),
                ]),
              ],
              children: [
                icon_filled(paths: [
                  "M4.929 4.929a10 10 0 1 1 14.141 14.141a10 10 0 0 1 -14.14 -14.14zm8.071 4.071a1 1 0 1 0 -2 0v2h-2a1 1 0 1 0 0 2h2v2a1 1 0 1 0 2 0v-2h2a1 1 0 1 0 0 -2h-2v-2z",
                ]),
                weft_lustre.text(content: "Quick Create"),
              ],
            ),
          ),
          button.button(
            theme: theme,
            config: button.button_config(on_press: TableNoop)
              |> button.button_variant(variant: button.secondary())
              |> button.button_attrs(attrs: [
                weft_lustre.styles([
                  weft.width(length: weft.fixed(length: weft.px(pixels: 32))),
                  weft.height(length: weft.fixed(length: weft.px(pixels: 32))),
                  weft.padding(pixels: 0),
                  weft.justify_content(value: weft.justify_center()),
                ]),
              ]),
            label: icon_stroke(paths: [
              "M3 7a2 2 0 0 1 2 -2h14a2 2 0 0 1 2 2v10a2 2 0 0 1 -2 2h-14a2 2 0 0 1 -2 -2v-10z",
              "M3 7l9 6l9 -6",
            ]),
          ),
        ],
      ),
      nav_item(
        icon_stroke(paths: [
          "M12 13m-2 0a2 2 0 1 0 4 0a2 2 0 1 0 -4 0",
          "M13.45 11.55l2.05 -2.05",
          "M6.4 20a9 9 0 1 1 11.2 0z",
        ]),
        "Dashboard",
        True,
      ),
      nav_item(
        icon_stroke(paths: [
          "M13 5h8",
          "M13 9h5",
          "M13 15h8",
          "M13 19h5",
          "M3 4m0 1a1 1 0 0 1 1 -1h4a1 1 0 0 1 1 1v4a1 1 0 0 1 -1 1h-4a1 1 0 0 1 -1 -1z",
          "M3 14m0 1a1 1 0 0 1 1 -1h4a1 1 0 0 1 1 1v4a1 1 0 0 1 -1 1h-4a1 1 0 0 1 -1 -1z",
        ]),
        "Lifecycle",
        False,
      ),
      nav_item(
        icon_stroke(paths: [
          "M3 13a1 1 0 0 1 1 -1h4a1 1 0 0 1 1 1v6a1 1 0 0 1 -1 1h-4a1 1 0 0 1 -1 -1z",
          "M15 9a1 1 0 0 1 1 -1h4a1 1 0 0 1 1 1v10a1 1 0 0 1 -1 1h-4a1 1 0 0 1 -1 -1z",
          "M9 5a1 1 0 0 1 1 -1h4a1 1 0 0 1 1 1v14a1 1 0 0 1 -1 1h-4a1 1 0 0 1 -1 -1z",
          "M4 20h14",
        ]),
        "Analytics",
        False,
      ),
      nav_item(
        icon_stroke(paths: [
          "M5 4h4l3 3h7a2 2 0 0 1 2 2v8a2 2 0 0 1 -2 2h-14a2 2 0 0 1 -2 -2v-11a2 2 0 0 1 2 -2",
        ]),
        "Projects",
        False,
      ),
      nav_item(
        icon_stroke(paths: [
          "M9 7m-4 0a4 4 0 1 0 8 0a4 4 0 1 0 -8 0",
          "M3 21v-2a4 4 0 0 1 4 -4h4a4 4 0 0 1 4 4v2",
          "M16 3.13a4 4 0 0 1 0 7.75",
          "M21 21v-2a4 4 0 0 0 -3 -3.85",
        ]),
        "Team",
        False,
      ),
    ]),
    nav_group([
      nav_group_label("Documents"),
      nav_item(
        icon_stroke(paths: [
          "M12 6m-8 0a8 3 0 1 0 16 0a8 3 0 1 0 -16 0",
          "M4 6v6a8 3 0 0 0 16 0v-6",
          "M4 12v6a8 3 0 0 0 16 0v-6",
        ]),
        "Data Library",
        False,
      ),
      nav_item(
        icon_stroke(paths: [
          "M8 5h-2a2 2 0 0 0 -2 2v12a2 2 0 0 0 2 2h5.697",
          "M18 14v4h4",
          "M18 11v-4a2 2 0 0 0 -2 -2h-2",
          "M8 3m0 2a2 2 0 0 1 2 -2h2a2 2 0 0 1 2 2v0a2 2 0 0 1 -2 2h-2a2 2 0 0 1 -2 -2z",
          "M18 18m-4 0a4 4 0 1 0 8 0a4 4 0 1 0 -8 0",
          "M8 11h4",
          "M8 15h3",
        ]),
        "Reports",
        False,
      ),
      nav_item(
        icon_stroke(paths: [
          "M14 3v4a1 1 0 0 0 1 1h4",
          "M17 21h-10a2 2 0 0 1 -2 -2v-14a2 2 0 0 1 2 -2h7l5 5v11a2 2 0 0 1 -2 2",
          "M9 12l1.333 5l1.667 -4l1.667 4l1.333 -5",
        ]),
        "Word Assistant",
        False,
      ),
      nav_item(
        icon_stroke(paths: [
          "M5 12m-1 0a1 1 0 1 0 2 0a1 1 0 1 0 -2 0",
          "M12 12m-1 0a1 1 0 1 0 2 0a1 1 0 1 0 -2 0",
          "M19 12m-1 0a1 1 0 1 0 2 0a1 1 0 1 0 -2 0",
        ]),
        "More",
        False,
      ),
    ]),
    weft_lustre.el(
      attrs: [weft_lustre.styles([weft.height(length: weft.fill())])],
      child: weft_lustre.none(),
    ),
    nav_group([
      nav_item(
        icon_stroke(paths: [
          "M10.325 4.317c.426 -1.756 2.924 -1.756 3.35 0a1.724 1.724 0 0 0 2.573 1.066c1.543 -.94 3.31 .826 2.37 2.37a1.724 1.724 0 0 0 1.065 2.572c1.756 .426 1.756 2.924 0 3.35a1.724 1.724 0 0 0 -1.066 2.573c.94 1.543 -.826 3.31 -2.37 2.37a1.724 1.724 0 0 0 -2.572 1.065c-.426 1.756 -2.924 1.756 -3.35 0a1.724 1.724 0 0 0 -2.573 -1.066c-1.543 .94 -3.31 -.826 -2.37 -2.37a1.724 1.724 0 0 0 -1.065 -2.572c-1.756 -.426 -1.756 -2.924 0 -3.35a1.724 1.724 0 0 0 1.066 -2.573c-.94 -1.543 .826 -3.31 2.37 -2.37c1 .608 2.296 .07 2.572 -1.065z",
          "M9 12a3 3 0 1 0 6 0a3 3 0 0 0 -6 0",
        ]),
        "Settings",
        False,
      ),
      nav_item(
        icon_stroke(paths: [
          "M12 12m-9 0a9 9 0 1 0 18 0a9 9 0 1 0 -18 0",
          "M12 17l0 .01",
          "M12 13.5a1.5 1.5 0 0 1 1 -1.5a2.6 2.6 0 1 0 -3 -4",
        ]),
        "Get Help",
        False,
      ),
      nav_item(
        icon_stroke(paths: [
          "M10 10m-7 0a7 7 0 1 0 14 0a7 7 0 1 0 -14 0",
          "M21 21l-6 -6",
        ]),
        "Search",
        False,
      ),
      dark_mode_item,
    ]),
  ]

  let sidebar_footer =
    weft_lustre.row(
      attrs: [
        weft_lustre.styles([
          weft.height(length: weft.fixed(length: weft.px(pixels: 48))),
          weft.padding_xy(x: 4, y: 0),
          weft.spacing(pixels: 8),
          weft.align_items(value: weft.align_items_center()),
          weft.rounded(radius: ui_theme.radius_md(theme)),
        ]),
      ],
      children: [
        weft_lustre.el(
          attrs: [
            weft_lustre.styles([
              weft.width(length: weft.fixed(length: weft.px(pixels: 32))),
              weft.height(length: weft.fixed(length: weft.px(pixels: 32))),
              weft.rounded(radius: weft.px(pixels: 9999)),
              weft.display(value: weft.display_flex()),
              weft.align_items(value: weft.align_items_center()),
              weft.justify_content(value: weft.justify_center()),
              weft.font_size(size: weft.rem(rem: 0.6875)),
              weft.font_weight(weight: weft.font_weight_value(weight: 600)),
              weft.background(color: case state.switch_on {
                True -> weft.rgba(red: 255, green: 255, blue: 255, alpha: 0.15)
                False -> weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.12)
              }),
              weft.text_color(color: case state.switch_on {
                True -> weft.rgb(red: 255, green: 255, blue: 255)
                False -> ui_theme.muted_text(theme)
              }),
            ]),
          ],
          child: weft_lustre.text(content: "CN"),
        ),
        weft_lustre.column(
          attrs: [
            weft_lustre.styles([
              weft.width(length: weft.fill()),
              weft.spacing(pixels: 1),
              weft.justify_content(value: weft.justify_center()),
            ]),
          ],
          children: [
            weft_lustre.el(
              attrs: [
                weft_lustre.styles([
                  weft.font_size(size: weft.rem(rem: 0.875)),
                  weft.font_weight(weight: weft.font_weight_value(weight: 500)),
                  weft.line_height(height: weft.line_height_multiple(
                    multiplier: 1.25,
                  )),
                  weft.overflow_x(overflow: weft.overflow_hidden()),
                ]),
              ],
              child: weft_lustre.text(content: "shadcn"),
            ),
            weft_lustre.el(
              attrs: [
                weft_lustre.styles([
                  weft.font_size(size: weft.rem(rem: 0.75)),
                  weft.text_color(color: ui_theme.muted_text(theme)),
                  weft.line_height(height: weft.line_height_multiple(
                    multiplier: 1.25,
                  )),
                  weft.overflow_x(overflow: weft.overflow_hidden()),
                ]),
              ],
              child: weft_lustre.text(content: "m@example.com"),
            ),
          ],
        ),
        icon_stroke(paths: [
          "M12 12m-1 0a1 1 0 1 0 2 0a1 1 0 1 0 -2 0",
          "M12 19m-1 0a1 1 0 1 0 2 0a1 1 0 1 0 -2 0",
          "M12 5m-1 0a1 1 0 1 0 2 0a1 1 0 1 0 -2 0",
        ]),
      ],
    )

  let crumbs =
    weft_lustre.row(
      attrs: [
        weft_lustre.styles([
          weft.font_size(size: weft.rem(rem: 1.0)),
          weft.font_weight(weight: weft.font_weight_value(weight: 500)),
          weft.spacing(pixels: 6),
        ]),
        weft_lustre.html_attribute(attribute.id(benchmark_breadcrumb_id)),
      ],
      children: [weft_lustre.text(content: "Documents")],
    )

  let breadcrumb_separator =
    weft_lustre.el(
      attrs: [
        weft_lustre.styles([
          weft.width(length: weft.fixed(length: weft.px(pixels: 1))),
          weft.height(length: weft.fixed(length: weft.px(pixels: 14))),
          weft.background(color: ui_theme.border_color(theme)),
        ]),
      ],
      child: weft_lustre.none(),
    )

  let header_theme_select =
    weft_lustre.row(
      attrs: [
        weft_lustre.styles([
          weft.spacing(pixels: 8),
          weft.align_items(value: weft.align_items_center()),
        ]),
      ],
      children: [
        popover.popover(
          theme: theme,
          config: popover.popover_config(
            open: state.theme_menu_open,
            on_toggle: ThemeMenuOpenChanged,
          )
            |> popover.popover_trigger_attrs(attrs: [
              weft_lustre.styles([
                weft.width(length: weft.fixed(length: weft.px(pixels: 209))),
                weft.height(length: weft.fixed(length: weft.px(pixels: 32))),
                weft.justify_content(value: weft.justify_start()),
                weft.spacing(pixels: 6),
              ]),
              weft_lustre.html_attribute(attribute.id(benchmark_select_id)),
              weft_lustre.html_attribute(attribute.role("combobox")),
              weft_lustre.html_attribute(attribute.aria_label("Theme")),
              weft_lustre.html_attribute(attribute.attribute(
                "data-slot",
                "select-trigger",
              )),
            ])
            |> popover.popover_panel_attrs(attrs: [
              weft_lustre.styles([
                weft.width(length: weft.fixed(length: weft.px(pixels: 140))),
                weft.spacing(pixels: 4),
              ]),
            ]),
          trigger: weft_lustre.row(
            attrs: [
              weft_lustre.styles([
                weft.align_items(value: weft.align_items_center()),
                weft.spacing(pixels: 4),
              ]),
            ],
            children: [
              text_muted(theme, "Select a theme:"),
              weft_lustre.el(
                attrs: [weft_lustre.styles([weft.display_none()])],
                child: weft_lustre.text(content: "Theme"),
              ),
              weft_lustre.text(content: theme_label(state.team_filter)),
            ],
          ),
          panel: weft_lustre.column(
            attrs: [weft_lustre.styles([weft.spacing(pixels: 4)])],
            children: [
              button.button(
                theme: theme,
                config: button.button_config(on_press: SelectTheme(
                  "theme_default",
                ))
                  |> button.button_variant(variant: button.secondary()),
                label: weft_lustre.text(content: "Default"),
              ),
              button.button(
                theme: theme,
                config: button.button_config(on_press: SelectTheme("theme_blue"))
                  |> button.button_variant(variant: button.secondary()),
                label: weft_lustre.text(content: "Blue"),
              ),
              button.button(
                theme: theme,
                config: button.button_config(on_press: SelectTheme(
                  "theme_green",
                ))
                  |> button.button_variant(variant: button.secondary()),
                label: weft_lustre.text(content: "Green"),
              ),
            ],
          ),
        ),
      ],
    )

  let inset_header =
    weft_lustre.row(
      attrs: [
        weft_lustre.styles([
          weft.align_items(value: weft.align_items_center()),
          weft.height(length: weft.fixed(length: weft.px(pixels: 56))),
          weft.background(color: surface_bg),
        ]),
        weft_lustre.html_attribute(attribute.id(benchmark_inset_header_id)),
      ],
      children: [
        weft_lustre.row(
          attrs: [
            weft_lustre.styles([
              weft.width(length: weft.fixed(length: weft.pct(pct: 100.0))),
              weft.padding_xy(x: 16, y: 8),
              weft.spacing(pixels: 8),
              weft.align_items(value: weft.align_items_center()),
              weft.justify_content(value: weft.justify_space_between()),
            ]),
          ],
          children: [
            weft_lustre.row(
              attrs: [
                weft_lustre.styles([
                  weft.spacing(pixels: 8),
                  weft.align_items(value: weft.align_items_center()),
                ]),
              ],
              children: [
                button.button(
                  theme: theme,
                  config: button.button_config(on_press: ToggleSidebar)
                    |> button.button_variant(variant: button.secondary())
                    |> button.button_size(size: button.sm())
                    |> button.button_attrs(attrs: [
                      weft_lustre.styles([
                        weft.width(
                          length: weft.fixed(length: weft.px(pixels: 28)),
                        ),
                        weft.height(
                          length: weft.fixed(length: weft.px(pixels: 28)),
                        ),
                        weft.padding(pixels: 0),
                        weft.justify_content(value: weft.justify_center()),
                        weft.background(color: weft.rgba(
                          red: 0,
                          green: 0,
                          blue: 0,
                          alpha: 0.0,
                        )),
                        weft.border(
                          width: weft.px(pixels: 1),
                          style: weft.border_style_solid(),
                          color: weft.rgba(
                            red: 0,
                            green: 0,
                            blue: 0,
                            alpha: 0.0,
                          ),
                        ),
                        weft.shadows(shadows: []),
                      ]),
                      weft_lustre.html_attribute(attribute.id(
                        benchmark_menu_toggle_id,
                      )),
                    ]),
                  label: weft_lustre.text(content: "≡"),
                ),
                breadcrumb_separator,
                crumbs,
              ],
            ),
            weft_lustre.row(
              attrs: [
                weft_lustre.styles([
                  weft.spacing(pixels: 8),
                  weft.align_items(value: weft.align_items_center()),
                ]),
              ],
              children: [
                button.button(
                  theme: theme,
                  config: button.button_config(on_press: TableNoop)
                    |> button.button_variant(variant: button.secondary())
                    |> button.button_size(size: button.sm())
                    |> button.button_attrs(attrs: [
                      weft_lustre.styles([
                        weft.display_none(),
                        weft.when(
                          query: weft.min_width(length: weft.px(pixels: 640)),
                          attrs: [
                            weft.display(value: weft.display_inline_flex()),
                          ],
                        ),
                      ]),
                    ]),
                  label: weft_lustre.text(content: "GitHub"),
                ),
                header_theme_select,
                button.button(
                  theme: theme,
                  config: button.button_config(on_press: ToggleColorMode)
                    |> button.button_variant(variant: button.secondary())
                    |> button.button_size(size: button.sm())
                    |> button.button_attrs(attrs: [
                      weft_lustre.styles([
                        weft.width(
                          length: weft.fixed(length: weft.px(pixels: 32)),
                        ),
                        weft.height(
                          length: weft.fixed(length: weft.px(pixels: 32)),
                        ),
                        weft.padding(pixels: 0),
                      ]),
                    ]),
                  label: weft_lustre.text(content: "◐"),
                ),
              ],
            ),
          ],
        ),
      ],
    )

  let inset_header_divider =
    weft_lustre.el(
      attrs: [
        weft_lustre.styles([
          weft.height(length: weft.fixed(length: weft.px(pixels: 1))),
          weft.background(color: ui_theme.border_color(theme)),
        ]),
      ],
      child: weft_lustre.none(),
    )

  let hidden_actions =
    weft_lustre.row(
      attrs: [
        weft_lustre.styles([
          weft.position(value: weft.position_fixed()),
          weft.top(length: weft.px(pixels: -10_000)),
          weft.left(length: weft.px(pixels: -10_000)),
          weft.spacing(pixels: 8),
        ]),
      ],
      children: [
        button.button(
          theme: theme,
          config: button.button_config(on_press: ShowToast)
            |> button.button_variant(variant: button.secondary())
            |> button.button_attrs(attrs: [
              weft_lustre.styles([
                weft.width(length: weft.fixed(length: weft.px(pixels: 200))),
                weft.height(length: weft.fixed(length: weft.px(pixels: 32))),
              ]),
              weft_lustre.html_attribute(attribute.id(
                benchmark_toast_trigger_id,
              )),
            ]),
          label: weft_lustre.text(content: "Customize Columns"),
        ),
        button.button(
          theme: theme,
          config: button.button_config(on_press: ToggleSidebar)
            |> button.button_variant(variant: button.secondary())
            |> button.button_disabled()
            |> button.button_attrs(attrs: [
              weft_lustre.styles([
                weft.width(length: weft.fixed(length: weft.px(pixels: 125))),
                weft.height(length: weft.fixed(length: weft.px(pixels: 32))),
              ]),
              weft_lustre.html_attribute(attribute.id(
                benchmark_secondary_action_disabled_id,
              )),
            ]),
          label: weft_lustre.text(content: "Disabled action"),
        ),
      ],
    )

  let dashboard_surface =
    weft_lustre.column(
      attrs: [
        weft_lustre.styles([
          weft.spacing(pixels: 24),
        ]),
        weft_lustre.html_attribute(attribute.id(benchmark_main_surface_id)),
      ],
      children: [
        metrics_row(theme),
        chart_card(theme, state),
        benchmark_tabs(theme, state),
        hidden_actions,
      ],
    )

  let sheet_view =
    sheet.sheet(
      theme: theme,
      config: sheet.sheet_config(
        open: state.sheet_open,
        root_id: sheet_root_id,
        label: sheet.sheet_label(value: "Benchmark sheet"),
        on_close: CloseSheet,
      ),
      content: weft_lustre.column(
        attrs: [
          weft_lustre.styles([weft.spacing(pixels: 8)]),
          weft_lustre.html_attribute(attribute.id(benchmark_sheet_content_id)),
        ],
        children: [
          weft_lustre.text(content: "Sheet panel"),
          button.button(
            theme: theme,
            config: button.button_config(on_press: CloseSheet),
            label: weft_lustre.text(content: "Close"),
          ),
        ],
      ),
    )

  let drawer_view =
    drawer.drawer(
      theme: theme,
      config: drawer.drawer_config(
        open: state.drawer_open,
        root_id: drawer_root_id,
        label: drawer.drawer_label(value: "Benchmark drawer"),
        on_close: CloseDrawer,
      ),
      content: weft_lustre.column(
        attrs: [
          weft_lustre.styles([weft.spacing(pixels: 8)]),
          weft_lustre.html_attribute(attribute.id(benchmark_drawer_content_id)),
        ],
        children: [
          weft_lustre.text(content: "Drawer panel"),
          button.button(
            theme: theme,
            config: button.button_config(on_press: CloseDrawer),
            label: weft_lustre.text(content: "Close"),
          ),
        ],
      ),
    )

  let toast_view = case state.toast_open {
    True ->
      sonner.sonner_region(
        theme: theme,
        corner: sonner.sonner_corner_bottom_right(),
        children: [
          weft_lustre.el(
            attrs: [
              weft_lustre.html_attribute(attribute.id(benchmark_toast_region_id)),
            ],
            child: sonner.sonner(
              theme: theme,
              config: sonner.sonner_config(on_dismiss: DismissToast),
              content: weft_lustre.el(
                attrs: [
                  weft_lustre.html_attribute(attribute.id(
                    benchmark_toast_content_id,
                  )),
                ],
                child: weft_lustre.text(content: "Dashboard benchmark toast"),
              ),
            ),
          ),
        ],
      )
    False -> weft_lustre.none()
  }

  sidebar.sidebar(
    theme: theme,
    config: sidebar.sidebar_config()
      |> sidebar.sidebar_attrs(attrs: [
        weft_lustre.html_attribute(attribute.id(benchmark_root_shell_id)),
      ])
      |> sidebar.sidebar_aside_attrs(attrs: [
        weft_lustre.html_attribute(attribute.id(benchmark_sidebar_aside_id)),
      ])
      |> sidebar.sidebar_inset_attrs(attrs: [
        weft_lustre.html_attribute(attribute.id(benchmark_main_id)),
      ])
      |> case state.sidebar_collapsed {
        True -> sidebar.sidebar_collapsed
        False -> sidebar.sidebar_expanded
      },
    header: sidebar_header,
    body: sidebar_body,
    footer: sidebar_footer,
    inset: weft_lustre.column(
      attrs: [weft_lustre.styles([weft.spacing(pixels: 0)])],
      children: [
        weft_lustre.column(
          attrs: [
            weft_lustre.styles([
              weft.spacing(pixels: 0),
            ]),
          ],
          children: [
            inset_header,
            inset_header_divider,
            weft_lustre.column(
              attrs: [
                weft_lustre.styles([
                  weft.spacing(pixels: 0),
                  weft.padding(pixels: 8),
                ]),
              ],
              children: [
                weft_lustre.el(
                  attrs: [
                    weft_lustre.styles([
                      weft.height(
                        length: weft.fixed(length: weft.px(pixels: 22)),
                      ),
                    ]),
                  ],
                  child: weft_lustre.none(),
                ),
                dashboard_surface,
              ],
            ),
          ],
        ),
        sheet_view,
        drawer_view,
        toast_view,
      ],
    ),
  )
}

fn viewport_effect() -> effect.Effect(Msg) {
  effect.from(fn(dispatch) {
    let read_width = fn() { window.inner_width(window.self()) }

    dispatch(ViewportMeasured(read_width()))
    window.add_event_listener("resize", fn(_event) {
      dispatch(ViewportMeasured(read_width()))
    })
  })
}

pub fn main() {
  let app =
    lustre.application(
      init: fn(_flags: Nil) {
        #(
          AppState(
            sidebar_collapsed: True,
            navigation_open: True,
            active_tab: "outline",
            team_filter: "theme_default",
            theme_menu_open: False,
            density: "last_3_months",
            switch_on: False,
            is_mobile_viewport: False,
            viewport_width: 1400,
            popover_open: False,
            sheet_open: False,
            drawer_open: False,
            toast_open: False,
            table_rows: initial_table_rows(),
            drag: None,
            reviewer_open: None,
            nav_menu_open: None,
            visible_columns: [
              "header",
              "section_type",
              "status",
              "target",
              "limit",
              "reviewer",
            ],
          ),
          viewport_effect(),
        )
      },
      update: fn(state: AppState, msg: Msg) {
        case msg {
          ToggleSidebar -> #(
            AppState(..state, sidebar_collapsed: !state.sidebar_collapsed),
            effect.none(),
          )
          NavigationChanged(value) -> #(
            AppState(..state, navigation_open: value),
            effect.none(),
          )
          TabChanged(value) -> #(
            AppState(..state, active_tab: value),
            effect.none(),
          )
          TeamChanged(value) -> #(
            AppState(..state, team_filter: value),
            effect.none(),
          )
          ThemeMenuOpenChanged(value) -> #(
            AppState(..state, theme_menu_open: value),
            effect.none(),
          )
          SelectTheme(value) -> #(
            AppState(..state, team_filter: value, theme_menu_open: False),
            effect.none(),
          )
          TableNoop -> #(state, effect.none())
          DensityChanged(value) -> #(
            AppState(..state, density: value),
            effect.none(),
          )
          SwitchChanged(value) -> #(
            AppState(..state, switch_on: value),
            effect.none(),
          )
          PopoverChanged(value) -> #(
            AppState(..state, popover_open: value),
            effect.none(),
          )
          OpenSheet -> #(
            AppState(..state, sheet_open: True),
            modal.modal_focus_trap(
              root_id: sheet_root_id,
              on_escape: CloseSheet,
            ),
          )
          CloseSheet -> #(AppState(..state, sheet_open: False), effect.none())
          OpenDrawer -> #(
            AppState(..state, drawer_open: True),
            modal.modal_focus_trap(
              root_id: drawer_root_id,
              on_escape: CloseDrawer,
            ),
          )
          CloseDrawer -> #(AppState(..state, drawer_open: False), effect.none())
          ShowToast -> #(AppState(..state, toast_open: True), effect.none())
          DismissToast -> #(AppState(..state, toast_open: False), effect.none())
          ToggleColorMode -> #(
            AppState(..state, switch_on: !state.switch_on),
            effect.none(),
          )
          DragStart(index, y) -> #(
            AppState(
              ..state,
              drag: Some(DragState(
                source_index: index,
                current_y: y,
                start_y: y,
                row_height: row_height,
              )),
            ),
            effect.none(),
          )
          DragMove(y) -> {
            let new_drag = case state.drag {
              None -> None
              Some(d) -> Some(DragState(..d, current_y: y))
            }
            #(AppState(..state, drag: new_drag), effect.none())
          }
          ReviewerOpenChanged(value) -> #(
            AppState(..state, reviewer_open: value),
            effect.none(),
          )
          NavMenuOpenChanged(value) -> #(
            AppState(..state, nav_menu_open: value),
            effect.none(),
          )
          ToggleColumn(col) -> {
            let cols = state.visible_columns
            let new_cols = case list.contains(cols, col) {
              True -> list.filter(cols, fn(c) { c != col })
              False -> list.append(cols, [col])
            }
            #(AppState(..state, visible_columns: new_cols), effect.none())
          }
          DragEnd -> {
            let new_rows = case state.drag {
              None -> state.table_rows
              Some(d) -> {
                let row_count = list.length(state.table_rows)
                let target = drag_target_index(d, row_count)
                move_to_index(
                  state.table_rows,
                  from: d.source_index,
                  to: target,
                )
              }
            }
            #(
              AppState(..state, table_rows: new_rows, drag: None),
              effect.none(),
            )
          }
          ViewportMeasured(width) -> #(
            case width <= 767 {
              True ->
                case state.is_mobile_viewport {
                  True ->
                    AppState(
                      ..state,
                      is_mobile_viewport: True,
                      viewport_width: width,
                    )
                  False ->
                    AppState(
                      ..state,
                      density: "last_7_days",
                      is_mobile_viewport: True,
                      viewport_width: width,
                    )
                }
              False ->
                AppState(
                  ..state,
                  is_mobile_viewport: False,
                  viewport_width: width,
                )
            },
            effect.none(),
          )
        }
      },
      view: fn(state: AppState) {
        let theme = theme_for_state(state)
        let color_scheme = case state.switch_on {
          True -> "dark"
          False -> "light"
        }
        let chart_vars = case state.switch_on {
          True ->
            "#benchmark-app { "
            <> "--chart-grid: #3f3f46;"
            <> "--chart-label: #a1a1aa;"
            <> "--chart-mobile-fill: rgba(113, 113, 122, 0.32);"
            <> "--chart-mobile-line: #a1a1aa;"
            <> "--chart-desktop-fill: rgba(212, 212, 216, 0.22);"
            <> "--chart-desktop-line: #d4d4d8;"
            <> "--chart-dot: #f4f4f5;"
            <> "--chart-tooltip-bg: #18181b;"
            <> "--chart-tooltip-border: #3f3f46;"
            <> "--chart-tooltip-fg: #fafafa;"
            <> "--chart-tooltip-muted: #d4d4d8;"
            <> " }"
          False ->
            "#benchmark-app { "
            <> "--chart-grid: #e4e4e7;"
            <> "--chart-label: #71717a;"
            <> "--chart-mobile-fill: rgba(161, 161, 170, 0.24);"
            <> "--chart-mobile-line: #a1a1aa;"
            <> "--chart-desktop-fill: rgba(113, 113, 122, 0.32);"
            <> "--chart-desktop-line: #71717a;"
            <> "--chart-dot: #52525b;"
            <> "--chart-tooltip-bg: #ffffff;"
            <> "--chart-tooltip-border: #d4d4d8;"
            <> "--chart-tooltip-fg: #09090b;"
            <> "--chart-tooltip-muted: #3f3f46;"
            <> " }"
        }

        let nav_dots_css =
          ".nav-dots { transition: opacity 0.15s ease; } "
          <> ".nav-item:hover .nav-dots { opacity: 1 !important; }"

        let color_scheme_style =
          weft_lustre.html(
            html_element.element("style", [], [
              html_element.text(
                "html { color-scheme: "
                <> color_scheme
                <> "; }"
                <> chart_vars
                <> nav_dots_css,
              ),
            ]),
          )

        let nav_context_menu = case state.nav_menu_open {
          None -> weft_lustre.none()
          Some(#(_, menu_y)) -> {
            let #(overlay_bg, overlay_fg) = ui_theme.overlay_surface(theme)

            let menu_item = fn(item_label: String) {
              weft_lustre.element_tag(
                tag: "button",
                base_weft_attrs: [weft.el_layout()],
                attrs: [
                  weft_lustre.html_attribute(attribute.type_("button")),
                  weft_lustre.html_attribute(
                    event.on_click(NavMenuOpenChanged(None)),
                  ),
                  weft_lustre.styles([
                    weft.display(value: weft.display_flex()),
                    weft.align_items(value: weft.align_items_center()),
                    weft.width(length: weft.fill()),
                    weft.padding_xy(x: 8, y: 6),
                    weft.rounded(radius: ui_theme.radius_md(theme)),
                    weft.font_size(size: weft.rem(rem: 0.8125)),
                    weft.cursor(cursor: weft.cursor_pointer()),
                    weft.background(color: weft.rgba(
                      red: 0,
                      green: 0,
                      blue: 0,
                      alpha: 0.0,
                    )),
                    weft.border(
                      width: weft.px(pixels: 0),
                      style: weft.border_style_solid(),
                      color: weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.0),
                    ),
                    weft.mouse_over(attrs: [
                      weft.background(color: case state.switch_on {
                        True ->
                          weft.rgba(
                            red: 255,
                            green: 255,
                            blue: 255,
                            alpha: 0.08,
                          )
                        False ->
                          weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.06)
                      }),
                    ]),
                    weft.text_color(color: overlay_fg),
                  ]),
                ],
                children: [weft_lustre.text(content: item_label)],
              )
            }

            weft_lustre.in_front(child: weft_lustre.el(
              attrs: [
                weft_lustre.styles([
                  weft.position(value: weft.position_fixed()),
                  weft.inset(length: weft.px(pixels: 0)),
                ]),
                weft_lustre.html_attribute(attribute.style("z-index", "9999")),
                weft_lustre.html_attribute(
                  event.on_click(NavMenuOpenChanged(None)),
                ),
              ],
              child: weft_lustre.el(
                attrs: [
                  weft_lustre.html_attribute(
                    event.advanced("click", {
                      decode.success(event.handler(
                        dispatch: TableNoop,
                        prevent_default: False,
                        stop_propagation: True,
                      ))
                    }),
                  ),
                  weft_lustre.styles([
                    weft.position(value: weft.position_fixed()),
                    weft.left(length: weft.px(pixels: 252)),
                    weft.top(
                      length: weft.px(pixels: float.round(menu_y -. 8.0)),
                    ),
                    weft.width(length: weft.fixed(length: weft.px(pixels: 160))),
                    weft.background(color: overlay_bg),
                    weft.border(
                      width: weft.px(pixels: 1),
                      style: weft.border_style_solid(),
                      color: ui_theme.border_color(theme),
                    ),
                    weft.rounded(radius: ui_theme.radius_md(theme)),
                    weft.shadows(shadows: [
                      weft.shadow(
                        x: weft.px(pixels: 0),
                        y: weft.px(pixels: 4),
                        blur: weft.px(pixels: 16),
                        spread: weft.px(pixels: -2),
                        color: weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.15),
                      ),
                    ]),
                    weft.padding(pixels: 4),
                  ]),
                  weft_lustre.html_attribute(attribute.style("z-index", "10000")),
                ],
                child: weft_lustre.column(
                  attrs: [weft_lustre.styles([weft.spacing(pixels: 1)])],
                  children: [
                    menu_item("Open"),
                    menu_item("Share"),
                    menu_item("Delete"),
                  ],
                ),
              ),
            ))
          }
        }

        weft_lustre.layout(
          attrs: [
            weft_lustre.html_attribute(attribute.id("benchmark-app")),
            weft_lustre.html_attribute(attribute.style(
              "color-scheme",
              color_scheme,
            )),
          ],
          child: weft_lustre.column(
            attrs: [weft_lustre.styles([weft.spacing(pixels: 0)])],
            children: [
              color_scheme_style,
              app_shell(theme, state),
              nav_context_menu,
            ],
          ),
        )
      },
    )

  lustre.start(app, "#app", Nil)
}
