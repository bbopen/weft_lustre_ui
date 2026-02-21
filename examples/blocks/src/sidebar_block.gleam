//// Sidebar-07 block composition for QA validation.
////
//// Validates sidebar nav primitives, collapsible groups, group-hover actions,
//// theme tokens, avatar/dropdown composition, breadcrumb, and tabs using
//// zero escape hatches.

import gleam/option.{type Option, None, Some}
import weft
import weft_lustre
import weft_lustre_ui/avatar
import weft_lustre_ui/breadcrumb
import weft_lustre_ui/collapsible
import weft_lustre_ui/dropdown_menu
import weft_lustre_ui/headless/separator as headless_separator
import weft_lustre_ui/separator
import weft_lustre_ui/sidebar
import weft_lustre_ui/tabs
import weft_lustre_ui/theme

/// Model for the sidebar block state.
pub type SidebarModel {
  SidebarModel(
    active_item: String,
    platform_open: Bool,
    projects_open: Bool,
    active_tab: String,
  )
}

/// Messages for sidebar block interaction.
pub type SidebarMsg {
  TogglePlatform(Bool)
  ToggleProjects(Bool)
  NavigateTo(String)
  TabChanged(String)
  ActionClicked(String)
}

/// Initialize the sidebar block model with sensible defaults.
pub fn sidebar_init() -> SidebarModel {
  SidebarModel(
    active_item: "playground",
    platform_open: True,
    projects_open: True,
    active_tab: "overview",
  )
}

/// Update the sidebar block model in response to a message.
pub fn sidebar_update(
  model model: SidebarModel,
  msg msg: SidebarMsg,
) -> SidebarModel {
  case msg {
    TogglePlatform(open) -> SidebarModel(..model, platform_open: open)
    ToggleProjects(open) -> SidebarModel(..model, projects_open: open)
    NavigateTo(item) -> SidebarModel(..model, active_item: item)
    TabChanged(tab) -> SidebarModel(..model, active_tab: tab)
    ActionClicked(_) -> model
  }
}

/// Render the sidebar-07 block composition.
///
/// Composes sidebar shell, collapsible nav groups, menu items with
/// group-hover actions, avatar footer with dropdown, and a breadcrumb +
/// tabs inset content area.
pub fn sidebar_07_view(
  theme theme: theme.Theme,
  model model: SidebarModel,
) -> weft_lustre.Element(SidebarMsg) {
  sidebar.sidebar(
    theme: theme,
    config: sidebar.sidebar_config(),
    header: sidebar_header(theme: theme),
    body: sidebar_body(theme: theme, model: model),
    footer: sidebar_footer(theme: theme),
    inset: sidebar_inset(theme: theme, model: model),
  )
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

fn sidebar_header(theme theme: theme.Theme) -> weft_lustre.Element(SidebarMsg) {
  let #(_surface_bg, surface_fg) = theme.surface(theme)

  weft_lustre.row(
    attrs: [
      weft_lustre.styles([
        weft.spacing(pixels: 10),
        weft.align_items(value: weft.align_items_center()),
      ]),
    ],
    children: [
      // Company logo placeholder — a small colored square
      weft_lustre.el(
        attrs: [
          weft_lustre.styles([
            weft.width(length: weft.fixed(length: weft.px(pixels: 28))),
            weft.height(length: weft.fixed(length: weft.px(pixels: 28))),
            weft.rounded(radius: theme.radius_md(theme)),
            weft.background(color: surface_fg),
          ]),
        ],
        child: weft_lustre.none(),
      ),
      weft_lustre.column(
        attrs: [
          weft_lustre.styles([
            weft.spacing(pixels: 0),
          ]),
        ],
        children: [
          weft_lustre.el(
            attrs: [
              weft_lustre.styles([
                weft.font_size(size: weft.rem(rem: 0.875)),
                weft.font_weight(weight: weft.font_weight_value(weight: 600)),
              ]),
            ],
            child: weft_lustre.text(content: "Acme Inc"),
          ),
          weft_lustre.el(
            attrs: [
              weft_lustre.styles([
                weft.font_size(size: weft.rem(rem: 0.75)),
                weft.text_color(color: theme.muted_text(theme)),
              ]),
            ],
            child: weft_lustre.text(content: "Enterprise"),
          ),
        ],
      ),
    ],
  )
}

// ---------------------------------------------------------------------------
// Body — collapsible nav groups
// ---------------------------------------------------------------------------

fn sidebar_body(
  theme theme: theme.Theme,
  model model: SidebarModel,
) -> List(weft_lustre.Element(SidebarMsg)) {
  [
    platform_group(theme: theme, model: model),
    projects_group(theme: theme, model: model),
  ]
}

fn platform_group(
  theme theme: theme.Theme,
  model model: SidebarModel,
) -> weft_lustre.Element(SidebarMsg) {
  sidebar.sidebar_group(theme: theme, label: None, children: [
    collapsible.collapsible(
      theme: theme,
      config: collapsible.collapsible_config(
        open: model.platform_open,
        on_toggle: TogglePlatform,
      ),
      trigger: weft_lustre.text(content: "Platform"),
      content: sidebar.sidebar_menu(children: [
        nav_item(
          theme: theme,
          id: "playground",
          label: "Playground",
          active: model.active_item,
          badge: None,
        ),
        nav_item(
          theme: theme,
          id: "models",
          label: "Models",
          active: model.active_item,
          badge: None,
        ),
        nav_item(
          theme: theme,
          id: "documentation",
          label: "Documentation",
          active: model.active_item,
          badge: None,
        ),
      ]),
    ),
  ])
}

fn projects_group(
  theme theme: theme.Theme,
  model model: SidebarModel,
) -> weft_lustre.Element(SidebarMsg) {
  sidebar.sidebar_group(theme: theme, label: None, children: [
    collapsible.collapsible(
      theme: theme,
      config: collapsible.collapsible_config(
        open: model.projects_open,
        on_toggle: ToggleProjects,
      ),
      trigger: weft_lustre.text(content: "Projects"),
      content: sidebar.sidebar_menu(children: [
        nav_item_with_action(
          theme: theme,
          id: "design-engineering",
          label: "Design Engineering",
          active: model.active_item,
          badge: Some("5"),
        ),
        nav_item_with_action(
          theme: theme,
          id: "sales-marketing",
          label: "Sales & Marketing",
          active: model.active_item,
          badge: Some("12"),
        ),
        nav_item_with_action(
          theme: theme,
          id: "travel",
          label: "Travel",
          active: model.active_item,
          badge: Some("3"),
        ),
      ]),
    ),
  ])
}

// ---------------------------------------------------------------------------
// Nav item helpers
// ---------------------------------------------------------------------------

fn nav_item(
  theme theme: theme.Theme,
  id id: String,
  label label: String,
  active active: String,
  badge badge: Option(String),
) -> weft_lustre.Element(SidebarMsg) {
  let btn_config =
    sidebar.sidebar_menu_button_config(label: nav_item_label(
      theme: theme,
      text: label,
      badge: badge,
    ))
    |> sidebar.sidebar_menu_button_on_click(on_click: fn() { NavigateTo(id) })

  let btn_config = case id == active {
    True -> sidebar.sidebar_menu_button_active(config: btn_config)
    False -> btn_config
  }

  sidebar.sidebar_menu_item(children: [
    sidebar.sidebar_menu_button(theme: theme, config: btn_config),
  ])
}

fn nav_item_with_action(
  theme theme: theme.Theme,
  id id: String,
  label label: String,
  active active: String,
  badge badge: Option(String),
) -> weft_lustre.Element(SidebarMsg) {
  let btn_config =
    sidebar.sidebar_menu_button_config(label: nav_item_label(
      theme: theme,
      text: label,
      badge: badge,
    ))
    |> sidebar.sidebar_menu_button_on_click(on_click: fn() { NavigateTo(id) })

  let btn_config = case id == active {
    True -> sidebar.sidebar_menu_button_active(config: btn_config)
    False -> btn_config
  }

  let action_config =
    sidebar.sidebar_menu_action_config(on_click: fn() { ActionClicked(id) })
    |> sidebar.sidebar_menu_action_show_on_hover()

  sidebar.sidebar_menu_item(children: [
    sidebar.sidebar_menu_button(theme: theme, config: btn_config),
    sidebar.sidebar_menu_action(
      theme: theme,
      config: action_config,
      content: weft_lustre.text(content: "..."),
    ),
  ])
}

fn nav_item_label(
  theme theme: theme.Theme,
  text text: String,
  badge badge: Option(String),
) -> weft_lustre.Element(SidebarMsg) {
  case badge {
    None -> weft_lustre.text(content: text)
    Some(count) ->
      weft_lustre.row(
        attrs: [
          weft_lustre.styles([
            weft.align_items(value: weft.align_items_center()),
            weft.spacing(pixels: 8),
            weft.width(length: weft.fill()),
            weft.justify_content(value: weft.justify_space_between()),
          ]),
        ],
        children: [
          weft_lustre.text(content: text),
          sidebar.sidebar_menu_badge(theme: theme, text: count),
        ],
      )
  }
}

// ---------------------------------------------------------------------------
// Footer — avatar + user info + dropdown
// ---------------------------------------------------------------------------

fn sidebar_footer(theme theme: theme.Theme) -> weft_lustre.Element(SidebarMsg) {
  let user_avatar =
    avatar.avatar_config(alt: "SN")
    |> avatar.avatar_fallback(fallback: weft_lustre.text(content: "SN"))
    |> avatar.avatar_size(size: avatar.avatar_sm())

  dropdown_menu.dropdown_menu(
    theme: theme,
    config: dropdown_menu.dropdown_menu_config(),
    trigger: weft_lustre.row(
      attrs: [
        weft_lustre.styles([
          weft.spacing(pixels: 8),
          weft.align_items(value: weft.align_items_center()),
          weft.cursor(cursor: weft.cursor_pointer()),
        ]),
      ],
      children: [
        avatar.avatar(theme: theme, config: user_avatar),
        weft_lustre.column(
          attrs: [
            weft_lustre.styles([
              weft.spacing(pixels: 0),
            ]),
          ],
          children: [
            weft_lustre.el(
              attrs: [
                weft_lustre.styles([
                  weft.font_size(size: weft.rem(rem: 0.8125)),
                  weft.font_weight(weight: weft.font_weight_value(weight: 560)),
                ]),
              ],
              child: weft_lustre.text(content: "Sofia Nguyen"),
            ),
            weft_lustre.el(
              attrs: [
                weft_lustre.styles([
                  weft.font_size(size: weft.rem(rem: 0.75)),
                  weft.text_color(color: theme.muted_text(theme)),
                ]),
              ],
              child: weft_lustre.text(content: "sofia@acme.com"),
            ),
          ],
        ),
      ],
    ),
    items: [
      dropdown_item(theme: theme, label: "Account Settings"),
      dropdown_item(theme: theme, label: "Sign Out"),
    ],
  )
}

fn dropdown_item(
  theme theme: theme.Theme,
  label label: String,
) -> weft_lustre.Element(SidebarMsg) {
  let #(_, surface_fg) = theme.surface(theme)

  weft_lustre.el(
    attrs: [
      weft_lustre.styles([
        weft.padding_xy(x: 10, y: 6),
        weft.rounded(radius: theme.radius_md(theme)),
        weft.font_size(size: weft.rem(rem: 0.8125)),
        weft.text_color(color: surface_fg),
        weft.cursor(cursor: weft.cursor_pointer()),
        weft.mouse_over(attrs: [
          weft.background(color: theme.hover_surface(theme: theme)),
        ]),
      ]),
    ],
    child: weft_lustre.text(content: label),
  )
}

// ---------------------------------------------------------------------------
// Inset — breadcrumb + separator + tabs content
// ---------------------------------------------------------------------------

fn sidebar_inset(
  theme theme: theme.Theme,
  model model: SidebarModel,
) -> weft_lustre.Element(SidebarMsg) {
  weft_lustre.column(
    attrs: [
      weft_lustre.styles([
        weft.spacing(pixels: 0),
        weft.padding(pixels: 16),
      ]),
    ],
    children: [
      inset_breadcrumb(theme: theme),
      weft_lustre.el(
        attrs: [
          weft_lustre.styles([
            weft.padding_xy(x: 0, y: 8),
          ]),
        ],
        child: separator.separator(
          theme: theme,
          config: headless_separator.separator_config(),
        ),
      ),
      inset_tabs(theme: theme, model: model),
    ],
  )
}

fn inset_breadcrumb(theme theme: theme.Theme) -> weft_lustre.Element(SidebarMsg) {
  let items = [
    breadcrumb.breadcrumb_item(label: "Home")
      |> breadcrumb.breadcrumb_item_href(href: "#"),
    breadcrumb.breadcrumb_item(label: "Building Your Application")
      |> breadcrumb.breadcrumb_item_href(href: "#"),
    breadcrumb.breadcrumb_item(label: "Data Fetching")
      |> breadcrumb.breadcrumb_item_current(),
  ]

  breadcrumb.breadcrumb(
    theme: theme,
    config: breadcrumb.breadcrumb_config(items: items),
  )
}

fn inset_tabs(
  theme theme: theme.Theme,
  model model: SidebarModel,
) -> weft_lustre.Element(SidebarMsg) {
  let tab_items = [
    tabs.tab_item(value: "overview", label: "Overview"),
    tabs.tab_item(value: "usage", label: "Usage"),
    tabs.tab_item(value: "api", label: "API Reference"),
  ]

  let content = case model.active_tab {
    "usage" -> tab_placeholder(theme: theme, title: "Usage")
    "api" -> tab_placeholder(theme: theme, title: "API Reference")
    _ -> tab_placeholder(theme: theme, title: "Overview")
  }

  tabs.tabs(
    theme: theme,
    config: tabs.tabs_config(value: model.active_tab, on_change: TabChanged),
    items: tab_items,
    content: content,
  )
}

fn tab_placeholder(
  theme theme: theme.Theme,
  title title: String,
) -> weft_lustre.Element(SidebarMsg) {
  weft_lustre.column(
    attrs: [
      weft_lustre.styles([
        weft.spacing(pixels: 8),
        weft.padding(pixels: 8),
      ]),
    ],
    children: [
      weft_lustre.el(
        attrs: [
          weft_lustre.styles([
            weft.font_size(size: weft.rem(rem: 1.125)),
            weft.font_weight(weight: weft.font_weight_value(weight: 600)),
          ]),
        ],
        child: weft_lustre.text(content: title),
      ),
      weft_lustre.el(
        attrs: [
          weft_lustre.styles([
            weft.font_size(size: weft.rem(rem: 0.875)),
            weft.text_color(color: theme.muted_text(theme)),
          ]),
        ],
        child: weft_lustre.text(
          content: "Content for the " <> title <> " tab will appear here.",
        ),
      ),
    ],
  )
}
