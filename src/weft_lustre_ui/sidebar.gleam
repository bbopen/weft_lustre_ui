//// Styled sidebar shell for weft_lustre_ui.

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
  let left_px = case collapsed {
    True -> -288
    False -> 0
  }

  [
    weft.position(value: weft.position_fixed()),
    weft.top(length: weft.px(pixels: 0)),
    weft.left(length: weft.px(pixels: left_px)),
    weft.width(length: weft.fixed(length: weft.px(pixels: 288))),
    weft.height(length: weft.fixed(length: weft.vh(vh: 100.0))),
    weft.padding(pixels: 8),
    weft.overflow_x(overflow: weft.overflow_hidden()),
    weft.background(color: weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.0)),
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
    weft.padding_xy(x: theme.space_md(theme) - 2, y: 10),
    weft.spacing(pixels: 10),
    weft.width(length: weft.fixed(length: weft.pct(pct: 100.0))),
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
