import gleam/list
import lustre
import lustre/attribute
import lustre/effect
import lustre/element as html_element
import plinth/browser/window
import weft
import weft_lustre
import weft_lustre/modal
import weft_lustre_ui
import weft_lustre_ui/avatar
import weft_lustre_ui/badge
import weft_lustre_ui/button
import weft_lustre_ui/calendar
import weft_lustre_ui/card
import weft_lustre_ui/chart
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
    popover_open: Bool,
    sheet_open: Bool,
    drawer_open: Bool,
    toast_open: Bool,
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
      child: weft_lustre.text(content: trend),
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
        "Trending up this month",
        "Visitors for the last 6 months",
        benchmark_metric_card_id_prefix <> "1",
        benchmark_metric_value_id_prefix <> "1",
      ),
      metric(
        "New Customers",
        "1,234",
        "-20%",
        "Down 20% this period",
        "Acquisition needs attention",
        benchmark_metric_card_id_prefix <> "2",
        benchmark_metric_value_id_prefix <> "2",
      ),
      metric(
        "Active Accounts",
        "45,678",
        "+12.5%",
        "Strong user retention",
        "Engagement exceed targets",
        benchmark_metric_card_id_prefix <> "3",
        benchmark_metric_value_id_prefix <> "3",
      ),
      metric(
        "Growth Rate",
        "4.5%",
        "+4.5%",
        "Steady performance increase",
        "Meets growth projections",
        benchmark_metric_card_id_prefix <> "4",
        benchmark_metric_value_id_prefix <> "4",
      ),
    ],
  )
}

fn insights_table(theme: weft_lustre_ui.Theme) -> weft_lustre.Element(Msg) {
  let #(input_surface_bg, _) = ui_theme.input_surface(theme)

  let reviewer_options = [
    select.select_option(value: "assign", label: "Assign reviewer"),
    select.select_option(value: "eddie_lake", label: "Eddie Lake"),
    select.select_option(value: "jamik_tashpulatov", label: "Jamik Tashpulatov"),
    select.select_option(value: "avery_lucas", label: "Avery Lucas"),
  ]

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

  let status_badge = fn(status: String) {
    let indicator = case status {
      "Done" -> "●"
      _ -> "◌"
    }

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
      child: weft_lustre.text(content: indicator <> " " <> status),
    )
  }

  let reviewer_cell = fn(reviewer: String, row_id: String, use_select: Bool) {
    case use_select {
      True ->
        select.select(
          theme: theme,
          config: select.select_config(
            value: reviewer,
            on_change: fn(_value) { TableNoop },
            options: reviewer_options,
          )
            |> select.select_attrs(attrs: [
              weft_lustre.html_attribute(attribute.id(row_id <> "-reviewer")),
              weft_lustre.styles([
                weft.width(length: weft.fixed(length: weft.px(pixels: 160))),
                weft.height(length: weft.fixed(length: weft.px(pixels: 32))),
              ]),
            ]),
        )
      False -> weft_lustre.text(content: reviewer)
    }
  }

  let header =
    table.table_header(attrs: [], children: [
      table.table_row(theme: theme, attrs: [], children: [
        table.table_head(attrs: [], child: checkbox_cell(False)),
        table.table_head(attrs: [], child: weft_lustre.text(content: "Header")),
        table.table_head(
          attrs: [],
          child: weft_lustre.text(content: "Section Type"),
        ),
        table.table_head(attrs: [], child: weft_lustre.text(content: "Status")),
        table.table_head(attrs: [], child: weft_lustre.text(content: "Target")),
        table.table_head(attrs: [], child: weft_lustre.text(content: "Limit")),
        table.table_head(
          attrs: [],
          child: weft_lustre.text(content: "Reviewer"),
        ),
        table.table_head(attrs: [], child: weft_lustre.text(content: "")),
      ]),
    ])

  let row = fn(
    header_text: String,
    section_type: String,
    status: String,
    target: String,
    limit: String,
    reviewer: String,
    reviewer_is_select: Bool,
    row_id: String,
  ) {
    table.table_row(
      theme: theme,
      attrs: [weft_lustre.html_attribute(attribute.id(row_id))],
      children: [
        table.table_cell(attrs: [], child: checkbox_cell(False)),
        table.table_cell(
          attrs: [],
          child: weft_lustre.text(content: header_text),
        ),
        table.table_cell(attrs: [], child: section_type_badge(section_type)),
        table.table_cell(attrs: [], child: status_badge(status)),
        table.table_cell(
          attrs: [],
          child: metric_input(target, row_id <> "-target"),
        ),
        table.table_cell(
          attrs: [],
          child: metric_input(limit, row_id <> "-limit"),
        ),
        table.table_cell(
          attrs: [],
          child: reviewer_cell(reviewer, row_id, reviewer_is_select),
        ),
        table.table_cell(attrs: [], child: weft_lustre.text(content: "⋯")),
      ],
    )
  }

  let body =
    table.table_body(attrs: [], children: [
      row(
        "Cover page",
        "Cover page",
        "In Process",
        "18",
        "5",
        "assign",
        True,
        "benchmark-table-row-1",
      ),
      row(
        "Table of contents",
        "Table of contents",
        "Done",
        "29",
        "24",
        "assign",
        True,
        "benchmark-table-row-2",
      ),
      row(
        "Executive summary",
        "Narrative",
        "Done",
        "10",
        "13",
        "assign",
        True,
        "benchmark-table-row-3",
      ),
      row(
        "Technical approach",
        "Narrative",
        "In Process",
        "27",
        "23",
        "Avery Lucas",
        False,
        "benchmark-table-row-4",
      ),
      row(
        "Design",
        "Narrative",
        "Done",
        "22",
        "17",
        "Liam Turner",
        False,
        "benchmark-table-row-5",
      ),
      row(
        "Capabilities",
        "Narrative",
        "Done",
        "19",
        "15",
        "Mia James",
        False,
        "benchmark-table-row-6",
      ),
      row(
        "Integration with existing systems",
        "Narrative",
        "Done",
        "24",
        "16",
        "Noah Patel",
        False,
        "benchmark-table-row-7",
      ),
      row(
        "Innovation and advantages",
        "Narrative",
        "In Process",
        "16",
        "9",
        "Sophia Chen",
        False,
        "benchmark-table-row-8",
      ),
      row(
        "Overview of EMR's Innovative Solutions",
        "Narrative",
        "Done",
        "21",
        "11",
        "Olivia Reed",
        False,
        "benchmark-table-row-9",
      ),
      row(
        "Advanced Algorithms and Machine Learning",
        "Narrative",
        "Done",
        "30",
        "25",
        "Ethan Flores",
        False,
        "benchmark-table-row-10",
      ),
    ])

  table.table(
    theme: theme,
    attrs: [
      weft_lustre.html_attribute(attribute.id("benchmark-insights-table")),
      weft_lustre.styles([
        weft.height(length: weft.fixed(length: weft.px(pixels: 570))),
      ]),
    ],
    children: [header, body],
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
          child: scrollable_panel(insights_table(theme)),
        ),
        weft_lustre.row(
          attrs: [
            weft_lustre.styles([
              weft.height(length: weft.fixed(length: weft.px(pixels: 40))),
              weft.padding_xy(x: 24, y: 0),
              weft.align_items(value: weft.align_items_center()),
              weft.justify_content(value: weft.justify_end()),
            ]),
          ],
          children: [text_muted(theme, "Page 1 of 1")],
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
      chart.chart(theme: theme, config: chart.chart_config(), data: [
        chart.chart_datum(label: "Mon", value: 34),
        chart.chart_datum(label: "Tue", value: 48),
        chart.chart_datum(label: "Wed", value: 28),
        chart.chart_datum(label: "Thu", value: 55),
        chart.chart_datum(label: "Fri", value: 61),
      ])
  }

  let tab_trigger = fn(value: String, label: String) {
    let is_active = state.active_tab == value
    let active_attrs = case is_active {
      True -> [
        weft_lustre.html_attribute(attribute.id(benchmark_active_tab_id)),
      ]
      False -> []
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
      label: weft_lustre.text(content: label),
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
        tab_trigger("outline", "Outline"),
        tab_trigger("past_performance", "Past Performance 3"),
        tab_trigger("key_personnel", "Key Personnel 2"),
        tab_trigger("focus_documents", "Focus Documents"),
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
                weft.width(length: weft.fixed(length: weft.px(pixels: 200))),
                weft.height(length: weft.fixed(length: weft.px(pixels: 32))),
                weft.padding_xy(x: 8, y: 0),
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
          trigger: weft_lustre.text(content: "Customize Columns"),
          panel: text_muted(
            theme,
            "Use tabs and filters to narrow dashboard insights.",
          ),
        ),
        button.button(
          theme: theme,
          config: button.button_config(on_press: OpenDrawer)
            |> button.button_variant(variant: button.secondary())
            |> button.button_attrs(attrs: [
              weft_lustre.styles([
                weft.width(length: weft.fixed(length: weft.px(pixels: 125))),
                weft.height(length: weft.fixed(length: weft.px(pixels: 32))),
              ]),
              weft_lustre.html_attribute(attribute.id(
                benchmark_drawer_trigger_id,
              )),
            ]),
          label: weft_lustre.text(content: "Add Section"),
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

fn chart_card(
  theme: weft_lustre_ui.Theme,
  state: AppState,
) -> weft_lustre.Element(Msg) {
  let #(surface_bg, _) = ui_theme.surface(theme)

  let chart_data = [
    chart.chart_datum_series(label: "", primary: 222, secondary: 150),
    chart.chart_datum_series(label: "", primary: 97, secondary: 180),
    chart.chart_datum_series(label: "Apr 3", primary: 167, secondary: 120),
    chart.chart_datum_series(label: "", primary: 242, secondary: 260),
    chart.chart_datum_series(label: "", primary: 373, secondary: 290),
    chart.chart_datum_series(label: "", primary: 301, secondary: 340),
    chart.chart_datum_series(label: "", primary: 245, secondary: 180),
    chart.chart_datum_series(label: "Apr 8", primary: 409, secondary: 320),
    chart.chart_datum_series(label: "", primary: 59, secondary: 110),
    chart.chart_datum_series(label: "", primary: 261, secondary: 190),
    chart.chart_datum_series(label: "", primary: 327, secondary: 350),
    chart.chart_datum_series(label: "", primary: 292, secondary: 210),
    chart.chart_datum_series(label: "Apr 13", primary: 342, secondary: 380),
    chart.chart_datum_series(label: "", primary: 137, secondary: 220),
    chart.chart_datum_series(label: "", primary: 120, secondary: 170),
    chart.chart_datum_series(label: "", primary: 138, secondary: 190),
    chart.chart_datum_series(label: "", primary: 446, secondary: 360),
    chart.chart_datum_series(label: "Apr 18", primary: 364, secondary: 410),
    chart.chart_datum_series(label: "", primary: 243, secondary: 180),
    chart.chart_datum_series(label: "", primary: 89, secondary: 150),
    chart.chart_datum_series(label: "", primary: 137, secondary: 200),
    chart.chart_datum_series(label: "", primary: 224, secondary: 170),
    chart.chart_datum_series(label: "Apr 23", primary: 138, secondary: 230),
    chart.chart_datum_series(label: "", primary: 387, secondary: 290),
    chart.chart_datum_series(label: "", primary: 215, secondary: 250),
    chart.chart_datum_series(label: "", primary: 75, secondary: 130),
    chart.chart_datum_series(label: "", primary: 383, secondary: 420),
    chart.chart_datum_series(label: "Apr 28", primary: 122, secondary: 180),
    chart.chart_datum_series(label: "", primary: 315, secondary: 240),
    chart.chart_datum_series(label: "", primary: 454, secondary: 380),
    chart.chart_datum_series(label: "", primary: 165, secondary: 220),
    chart.chart_datum_series(label: "", primary: 293, secondary: 310),
    chart.chart_datum_series(label: "May 3", primary: 247, secondary: 190),
    chart.chart_datum_series(label: "", primary: 385, secondary: 420),
    chart.chart_datum_series(label: "", primary: 481, secondary: 390),
    chart.chart_datum_series(label: "", primary: 498, secondary: 520),
    chart.chart_datum_series(label: "", primary: 388, secondary: 300),
    chart.chart_datum_series(label: "May 8", primary: 149, secondary: 210),
    chart.chart_datum_series(label: "", primary: 227, secondary: 180),
    chart.chart_datum_series(label: "", primary: 293, secondary: 330),
    chart.chart_datum_series(label: "", primary: 335, secondary: 270),
    chart.chart_datum_series(label: "", primary: 197, secondary: 240),
    chart.chart_datum_series(label: "May 13", primary: 197, secondary: 160),
    chart.chart_datum_series(label: "", primary: 448, secondary: 490),
    chart.chart_datum_series(label: "", primary: 473, secondary: 380),
    chart.chart_datum_series(label: "", primary: 338, secondary: 400),
    chart.chart_datum_series(label: "", primary: 499, secondary: 420),
    chart.chart_datum_series(label: "May 18", primary: 315, secondary: 350),
    chart.chart_datum_series(label: "", primary: 235, secondary: 180),
    chart.chart_datum_series(label: "", primary: 177, secondary: 230),
    chart.chart_datum_series(label: "", primary: 82, secondary: 140),
    chart.chart_datum_series(label: "", primary: 81, secondary: 120),
    chart.chart_datum_series(label: "May 23", primary: 252, secondary: 290),
    chart.chart_datum_series(label: "", primary: 294, secondary: 220),
    chart.chart_datum_series(label: "", primary: 201, secondary: 250),
    chart.chart_datum_series(label: "", primary: 213, secondary: 170),
    chart.chart_datum_series(label: "", primary: 420, secondary: 460),
    chart.chart_datum_series(label: "", primary: 233, secondary: 190),
    chart.chart_datum_series(label: "May 29", primary: 78, secondary: 130),
    chart.chart_datum_series(label: "", primary: 340, secondary: 280),
    chart.chart_datum_series(label: "", primary: 178, secondary: 230),
    chart.chart_datum_series(label: "", primary: 178, secondary: 200),
    chart.chart_datum_series(label: "", primary: 470, secondary: 410),
    chart.chart_datum_series(label: "Jun 3", primary: 103, secondary: 160),
    chart.chart_datum_series(label: "", primary: 439, secondary: 380),
    chart.chart_datum_series(label: "", primary: 88, secondary: 140),
    chart.chart_datum_series(label: "", primary: 294, secondary: 250),
    chart.chart_datum_series(label: "", primary: 323, secondary: 370),
    chart.chart_datum_series(label: "Jun 8", primary: 385, secondary: 320),
    chart.chart_datum_series(label: "", primary: 438, secondary: 480),
    chart.chart_datum_series(label: "", primary: 155, secondary: 200),
    chart.chart_datum_series(label: "", primary: 92, secondary: 150),
    chart.chart_datum_series(label: "", primary: 492, secondary: 420),
    chart.chart_datum_series(label: "Jun 13", primary: 81, secondary: 130),
    chart.chart_datum_series(label: "", primary: 426, secondary: 380),
    chart.chart_datum_series(label: "", primary: 307, secondary: 350),
    chart.chart_datum_series(label: "", primary: 371, secondary: 310),
    chart.chart_datum_series(label: "", primary: 475, secondary: 520),
    chart.chart_datum_series(label: "Jun 18", primary: 107, secondary: 170),
    chart.chart_datum_series(label: "", primary: 341, secondary: 290),
    chart.chart_datum_series(label: "", primary: 408, secondary: 450),
    chart.chart_datum_series(label: "", primary: 169, secondary: 210),
    chart.chart_datum_series(label: "", primary: 317, secondary: 270),
    chart.chart_datum_series(label: "Jun 23", primary: 480, secondary: 530),
    chart.chart_datum_series(label: "", primary: 132, secondary: 180),
    chart.chart_datum_series(label: "", primary: 141, secondary: 190),
    chart.chart_datum_series(label: "", primary: 434, secondary: 380),
    chart.chart_datum_series(label: "", primary: 448, secondary: 490),
    chart.chart_datum_series(label: "", primary: 149, secondary: 200),
    chart.chart_datum_series(label: "Jun 29", primary: 103, secondary: 160),
    chart.chart_datum_series(label: "", primary: 446, secondary: 400),
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
      chart.chart(
        theme: theme,
        config: chart.chart_config()
          |> chart.chart_attrs(attrs: [
            weft_lustre.styles([
              weft.padding_xy(x: 24, y: 0),
              weft.when(
                query: weft.max_width(length: weft.px(pixels: 767)),
                attrs: [
                  weft.padding_xy(x: 16, y: 0),
                ],
              ),
              weft.height(length: weft.fixed(length: weft.px(pixels: 276))),
            ]),
          ]),
        data: filtered_chart_data,
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

  let brand_avatar =
    avatar.avatar(
      theme: theme,
      config: avatar.avatar_config(alt: "Acme")
        |> avatar.avatar_fallback(fallback: weft_lustre.text(content: "A")),
    )

  let sidebar_header =
    weft_lustre.row(
      attrs: [
        weft_lustre.styles([
          weft.spacing(pixels: 10),
          weft.align_items(value: weft.align_items_center()),
        ]),
      ],
      children: [
        brand_avatar,
        text_title("Acme Inc."),
      ],
    )

  let nav_item = fn(label: String, active: Bool) {
    let #(_surface_bg, surface_fg) = ui_theme.surface(theme)

    weft_lustre.el(
      attrs: [
        weft_lustre.styles([
          weft.padding_xy(x: 8, y: 4),
          weft.rounded(radius: ui_theme.radius_md(theme)),
          weft.font_size(size: weft.rem(rem: 0.875)),
          weft.font_weight(weight: weft.font_weight_value(weight: 560)),
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
        ]),
      ],
      child: weft_lustre.text(content: label),
    )
  }

  let sidebar_body = [
    button.button(
      theme: theme,
      config: button.button_config(on_press: OpenSheet)
        |> button.button_variant(variant: button.primary())
        |> button.button_attrs(attrs: [
          weft_lustre.styles([
            weft.width(length: weft.fixed(length: weft.px(pixels: 216))),
            weft.height(length: weft.fixed(length: weft.px(pixels: 32))),
            weft.padding_xy(x: 8, y: 8),
          ]),
          weft_lustre.html_attribute(attribute.id(benchmark_primary_action_id)),
        ]),
      label: weft_lustre.text(content: "Quick Create"),
    ),
    nav_item("Inbox", False),
    nav_item("Dashboard", True),
    nav_item("Lifecycle", False),
    nav_item("Analytics", False),
    nav_item("Projects", False),
    nav_item("Team", False),
    text_muted(theme, "Documents"),
    nav_item("Data Library", False),
    nav_item("Reports", False),
    nav_item("Word Assistant", False),
    nav_item("More", False),
    nav_item("Settings", False),
    nav_item("Get Help", False),
    nav_item("Search", False),
    weft_lustre.row(
      attrs: [
        weft_lustre.styles([
          weft.spacing(pixels: 8),
          weft.align_items(value: weft.align_items_center()),
        ]),
      ],
      children: [
        text_muted(theme, "Dark Mode"),
        button.button(
          theme: theme,
          config: button.button_config(on_press: ToggleColorMode)
            |> button.button_variant(variant: button.secondary())
            |> button.button_size(size: button.sm())
            |> button.button_attrs(attrs: [
              weft_lustre.styles([
                weft.width(length: weft.fixed(length: weft.px(pixels: 32))),
                weft.height(length: weft.fixed(length: weft.px(pixels: 18))),
                weft.padding(pixels: 0),
              ]),
            ]),
          label: weft_lustre.text(content: case state.switch_on {
            True -> "●"
            False -> "○"
          }),
        ),
      ],
    ),
  ]

  let sidebar_footer = text_muted(theme, "shadcn  m@example.com")

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
            popover_open: False,
            sheet_open: False,
            drawer_open: False,
            toast_open: False,
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
          ViewportMeasured(width) -> #(
            case width <= 767 {
              True ->
                case state.is_mobile_viewport {
                  True -> AppState(..state, is_mobile_viewport: True)
                  False ->
                    AppState(
                      ..state,
                      density: "last_7_days",
                      is_mobile_viewport: True,
                    )
                }
              False -> AppState(..state, is_mobile_viewport: False)
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

        let color_scheme_style =
          weft_lustre.html(
            html_element.element("style", [], [
              html_element.text(
                "html { color-scheme: " <> color_scheme <> "; }" <> chart_vars,
              ),
            ]),
          )

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
            ],
          ),
        )
      },
    )

  lustre.start(app, "#app", Nil)
}
