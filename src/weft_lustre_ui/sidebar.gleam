//// Styled sidebar shell for weft_lustre_ui.

import gleam/option.{type Option, None, Some}
import weft
import weft_lustre
import weft_lustre_ui/headless/sidebar as headless_sidebar
import weft_lustre_ui/theme

/// Styled sidebar configuration alias.
pub type SidebarConfig(msg) =
  headless_sidebar.SidebarConfig(msg)

/// Construct sidebar configuration.
pub fn sidebar_config() -> SidebarConfig(msg) {
  headless_sidebar.sidebar_config()
}

/// Collapse the sidebar.
pub fn sidebar_collapsed(
  config config: SidebarConfig(msg),
) -> SidebarConfig(msg) {
  headless_sidebar.sidebar_collapsed(config: config)
}

/// Expand the sidebar.
pub fn sidebar_expanded(config config: SidebarConfig(msg)) -> SidebarConfig(msg) {
  headless_sidebar.sidebar_expanded(config: config)
}

/// Read collapsed state.
pub fn sidebar_is_collapsed(config config: SidebarConfig(msg)) -> Bool {
  headless_sidebar.sidebar_is_collapsed(config: config)
}

/// Append root attributes.
pub fn sidebar_attrs(
  config config: SidebarConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> SidebarConfig(msg) {
  headless_sidebar.sidebar_attrs(config: config, attrs: attrs)
}

/// Append `<aside>` attributes.
pub fn sidebar_aside_attrs(
  config config: SidebarConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> SidebarConfig(msg) {
  headless_sidebar.sidebar_aside_attrs(config: config, attrs: attrs)
}

/// Append `<main>` inset attributes.
pub fn sidebar_inset_attrs(
  config config: SidebarConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> SidebarConfig(msg) {
  headless_sidebar.sidebar_inset_attrs(config: config, attrs: attrs)
}

fn shell_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  let #(surface_bg, surface_fg) = theme.surface(theme)

  [
    weft.display(value: weft.display_flex()),
    weft.width(length: weft.fixed(length: weft.pct(pct: 100.0))),
    weft.height(length: weft.fixed(length: weft.vh(vh: 100.0))),
    weft.overflow_x(overflow: weft.overflow_hidden()),
    weft.background(color: surface_bg),
    weft.text_color(color: surface_fg),
    weft.font_family(families: theme.font_families(theme)),
    weft.align_items(value: weft.align_items_stretch()),
  ]
}

fn aside_styles(
  theme _theme: theme.Theme,
  collapsed collapsed: Bool,
) -> List(weft.Attribute) {
  let width_px = case collapsed {
    True -> 0
    False -> 288
  }

  [
    weft.width(length: weft.fixed(length: weft.px(pixels: width_px))),
    weft.height(length: weft.fixed(length: weft.vh(vh: 100.0))),
    weft.padding(pixels: case collapsed {
      True -> 0
      False -> 8
    }),
    weft.overflow_x(overflow: weft.overflow_hidden()),
    weft.overflow_y(overflow: weft.overflow_auto()),
    case collapsed {
      True -> weft.pointer_events(value: weft.pointer_events_none())
      False -> weft.pointer_events(value: weft.pointer_events_auto())
    },
    weft.transitions(transitions: [
      weft.transition_item(
        property: weft.transition_property_all(),
        duration: weft.ms(milliseconds: 200),
        easing: weft.ease_out(),
      ),
    ]),
    weft.when(query: weft.max_width(length: weft.px(pixels: 900)), attrs: [
      weft.display_none(),
    ]),
  ]
}

fn aside_header_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  [
    weft.padding_xy(x: theme.space_md(theme), y: 12),
  ]
}

fn aside_body_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  [
    weft.padding_xy(x: theme.space_md(theme) - 2, y: 8),
    weft.spacing(pixels: 8),
    weft.width(length: weft.fixed(length: weft.pct(pct: 100.0))),
    weft.height(length: weft.fill()),
  ]
}

fn aside_footer_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  [
    weft.padding_xy(x: theme.space_md(theme), y: 12),
    weft.text_color(color: theme.muted_text(theme)),
    weft.font_size(size: weft.rem(rem: 0.8125)),
  ]
}

fn main_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  let #(surface_bg, _) = theme.surface(theme)

  [
    weft.width(length: weft.fill()),
    weft.overflow_y(overflow: weft.overflow_auto()),
    weft.background(color: surface_bg),
    weft.rounded(radius: weft.px(pixels: 14)),
    weft.border(
      width: weft.px(pixels: 1),
      style: weft.border_style_solid(),
      color: theme.border_color(theme),
    ),
    weft.shadows(shadows: [
      weft.shadow(
        x: weft.px(pixels: 0),
        y: weft.px(pixels: 1),
        blur: weft.px(pixels: 3),
        spread: weft.px(pixels: 0),
        color: weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.1),
      ),
      weft.shadow(
        x: weft.px(pixels: 0),
        y: weft.px(pixels: 1),
        blur: weft.px(pixels: 2),
        spread: weft.px(pixels: -1),
        color: weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.1),
      ),
    ]),
    weft.when(query: weft.max_width(length: weft.px(pixels: 900)), attrs: [
      weft.padding(pixels: 6),
    ]),
  ]
}

/// Render a styled sidebar shell.
pub fn sidebar(
  theme theme: theme.Theme,
  config config: SidebarConfig(msg),
  header header: weft_lustre.Element(msg),
  body body: List(weft_lustre.Element(msg)),
  footer footer: weft_lustre.Element(msg),
  inset inset: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  let collapsed = headless_sidebar.sidebar_is_collapsed(config: config)
  let aside = aside_styles(theme: theme, collapsed: collapsed)
  let aside_header = aside_header_styles(theme: theme)
  let aside_body = aside_body_styles(theme: theme)
  let aside_footer = aside_footer_styles(theme: theme)

  headless_sidebar.sidebar(
    config: headless_sidebar.sidebar_attrs(config: config, attrs: [
      weft_lustre.styles(shell_styles(theme: theme)),
    ])
      |> headless_sidebar.sidebar_aside_attrs(attrs: [
        weft_lustre.styles(aside),
      ])
      |> headless_sidebar.sidebar_inset_attrs(attrs: [
        weft_lustre.styles(main_styles(theme: theme)),
      ]),
    header: weft_lustre.el(
      attrs: [weft_lustre.styles(aside_header)],
      child: header,
    ),
    body: [
      weft_lustre.column(
        attrs: [weft_lustre.styles(aside_body)],
        children: body,
      ),
    ],
    footer: weft_lustre.el(
      attrs: [weft_lustre.styles(aside_footer)],
      child: footer,
    ),
    inset: inset,
  )
}

/// Styled nav group container — optional label + list of menu items.
pub fn sidebar_group(
  theme theme: theme.Theme,
  label label: Option(String),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let label_el = case label {
    None -> weft_lustre.none()
    Some(text) ->
      weft_lustre.el(
        attrs: [
          weft_lustre.styles([
            weft.font_size(size: weft.rem(rem: 0.75)),
            weft.font_weight(weight: weft.font_weight_value(weight: 600)),
            weft.text_color(color: theme.muted_text(theme)),
            weft.padding_xy(x: 8, y: 2),
          ]),
        ],
        child: weft_lustre.text(content: text),
      )
  }
  weft_lustre.column(
    attrs: [
      weft_lustre.styles([
        weft.spacing(pixels: 4),
        weft.width(length: weft.fill()),
      ]),
    ],
    children: [label_el, ..children],
  )
}

/// Styled ordered list (`<ul>`) wrapper for nav items.
pub fn sidebar_menu(
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "ul",
    base_weft_attrs: [weft.el_layout()],
    attrs: [
      weft_lustre.styles([
        weft.padding(pixels: 0),
        weft.margin(pixels: 0),
        weft.spacing(pixels: 2),
        weft.width(length: weft.fill()),
      ]),
    ],
    children: children,
  )
}

/// Styled single nav item container (`<li>`).
pub fn sidebar_menu_item(
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let item = headless_sidebar.sidebar_menu_item(children: children)
  weft_lustre.el(
    attrs: [
      weft_lustre.styles([
        weft.position(value: weft.position_relative()),
        weft.width(length: weft.fill()),
      ]),
    ],
    child: item,
  )
}

/// Configuration alias for styled sidebar menu button.
pub type SidebarMenuButtonConfig(msg) =
  headless_sidebar.SidebarMenuButtonConfig(msg)

/// Construct a sidebar menu button config.
pub fn sidebar_menu_button_config(
  label label: weft_lustre.Element(msg),
) -> SidebarMenuButtonConfig(msg) {
  headless_sidebar.sidebar_menu_button_config(label: label)
}

/// Mark the button as the currently active nav item.
pub fn sidebar_menu_button_active(
  config config: SidebarMenuButtonConfig(msg),
) -> SidebarMenuButtonConfig(msg) {
  headless_sidebar.sidebar_menu_button_active(config: config)
}

/// Set the click handler on the menu button.
pub fn sidebar_menu_button_on_click(
  config config: SidebarMenuButtonConfig(msg),
  on_click on_click: fn() -> msg,
) -> SidebarMenuButtonConfig(msg) {
  headless_sidebar.sidebar_menu_button_on_click(
    config: config,
    on_click: on_click,
  )
}

/// Set the href on the menu button (renders as `<a>` instead of `<button>`).
pub fn sidebar_menu_button_href(
  config config: SidebarMenuButtonConfig(msg),
  href href: String,
) -> SidebarMenuButtonConfig(msg) {
  headless_sidebar.sidebar_menu_button_href(config: config, href: href)
}

/// Append extra attributes to the menu button.
pub fn sidebar_menu_button_attrs(
  config config: SidebarMenuButtonConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> SidebarMenuButtonConfig(msg) {
  headless_sidebar.sidebar_menu_button_attrs(config: config, attrs: attrs)
}

/// Styled nav action/link button.
pub fn sidebar_menu_button(
  theme theme: theme.Theme,
  config config: SidebarMenuButtonConfig(msg),
) -> weft_lustre.Element(msg) {
  let #(surface_bg, surface_fg) = theme.surface(theme)
  let #(accent_bg, accent_fg) = theme.accent(theme: theme)
  let active = headless_sidebar.sidebar_menu_button_is_active(config: config)
  let #(bg, fg) = case active {
    True -> #(accent_bg, accent_fg)
    False -> #(surface_bg, surface_fg)
  }
  let base_styles = [
    weft.display(value: weft.display_flex()),
    weft.align_items(value: weft.align_items_center()),
    weft.spacing(pixels: 8),
    weft.width(length: weft.fill()),
    weft.padding_xy(x: 8, y: 6),
    weft.rounded(radius: theme.radius_md(theme)),
    weft.background(color: bg),
    weft.text_color(color: fg),
    weft.font_size(size: weft.rem(rem: 0.875)),
    weft.font_weight(weight: weft.font_weight_normal()),
    weft.cursor(cursor: weft.cursor_pointer()),
    weft.mouse_over(attrs: [
      weft.background(color: theme.hover_surface(theme: theme)),
    ]),
  ]
  headless_sidebar.sidebar_menu_button(
    config: headless_sidebar.sidebar_menu_button_attrs(config: config, attrs: [
      weft_lustre.styles(base_styles),
    ]),
  )
}

/// Configuration alias for styled sidebar menu action.
pub type SidebarMenuActionConfig(msg) =
  headless_sidebar.SidebarMenuActionConfig(msg)

/// Construct a sidebar menu action config.
pub fn sidebar_menu_action_config(
  on_click on_click: fn() -> msg,
) -> SidebarMenuActionConfig(msg) {
  headless_sidebar.sidebar_menu_action_config(on_click: on_click)
}

/// Make this action button visible only when the parent menu item is hovered.
pub fn sidebar_menu_action_show_on_hover(
  config config: SidebarMenuActionConfig(msg),
) -> SidebarMenuActionConfig(msg) {
  headless_sidebar.sidebar_menu_action_show_on_hover(config: config)
}

/// Append extra attributes to the action button.
pub fn sidebar_menu_action_attrs(
  config config: SidebarMenuActionConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> SidebarMenuActionConfig(msg) {
  headless_sidebar.sidebar_menu_action_attrs(config: config, attrs: attrs)
}

/// Styled action button that can optionally reveal only on hover.
pub fn sidebar_menu_action(
  theme theme: theme.Theme,
  config config: SidebarMenuActionConfig(msg),
  content content: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  let action_styles = [
    weft.position(value: weft.position_absolute()),
    weft.right(length: weft.px(pixels: 4)),
    weft.top(length: weft.pct(pct: 50.0)),
    weft.transform(items: [
      weft.translate(x: weft.px(pixels: 0), y: weft.pct(pct: -50.0)),
    ]),
    weft.display(value: weft.display_flex()),
    weft.align_items(value: weft.align_items_center()),
    weft.justify_content(value: weft.justify_center()),
    weft.width(length: weft.fixed(length: weft.px(pixels: 24))),
    weft.height(length: weft.fixed(length: weft.px(pixels: 24))),
    weft.rounded(radius: theme.radius_md(theme)),
    weft.cursor(cursor: weft.cursor_pointer()),
    weft.mouse_over(attrs: [
      weft.background(color: theme.hover_surface(theme: theme)),
    ]),
  ]
  headless_sidebar.sidebar_menu_action(
    config: headless_sidebar.sidebar_menu_action_attrs(config: config, attrs: [
      weft_lustre.styles(action_styles),
    ]),
    content: content,
  )
}

/// Styled inline count badge for nav items.
pub fn sidebar_menu_badge(
  theme theme: theme.Theme,
  text text: String,
) -> weft_lustre.Element(msg) {
  let #(muted_bg, muted_fg) = theme.muted(theme: theme)
  let badge_styles = [
    weft.display(value: weft.display_inline_flex()),
    weft.align_items(value: weft.align_items_center()),
    weft.justify_content(value: weft.justify_center()),
    weft.width(length: weft.minimum(
      base: weft.shrink(),
      min: weft.px(pixels: 20),
    )),
    weft.height(length: weft.fixed(length: weft.px(pixels: 20))),
    weft.padding_xy(x: 4, y: 0),
    weft.rounded(radius: weft.px(pixels: 9999)),
    weft.background(color: muted_bg),
    weft.text_color(color: muted_fg),
    weft.font_size(size: weft.rem(rem: 0.75)),
    weft.font_weight(weight: weft.font_weight_value(weight: 600)),
    weft.text_align(align: weft.text_align_center()),
  ]
  weft_lustre.element_tag(
    tag: "span",
    base_weft_attrs: [weft.el_layout()],
    attrs: [weft_lustre.styles(badge_styles)],
    children: [weft_lustre.text(content: text)],
  )
}
