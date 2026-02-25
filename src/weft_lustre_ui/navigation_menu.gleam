//// Styled navigation-menu primitives for shadcn compatibility.
////
//// Applies theme-driven defaults to `headless/navigation_menu` slot primitives.

import gleam/list
import weft
import weft_lustre
import weft_lustre_ui/headless/navigation_menu as headless_navigation_menu
import weft_lustre_ui/theme

/// Styled navigation-menu configuration alias.
pub type NavigationMenuConfig(msg) =
  headless_navigation_menu.NavigationMenuConfig(msg)

/// Construct a default navigation-menu configuration.
pub fn navigation_menu_config(
  theme _theme: theme.Theme,
) -> NavigationMenuConfig(msg) {
  headless_navigation_menu.navigation_menu_config()
}

/// Enable or disable viewport semantics on the root.
pub fn navigation_menu_viewport_enabled(
  theme _theme: theme.Theme,
  config config: NavigationMenuConfig(msg),
  enabled enabled: Bool,
) -> NavigationMenuConfig(msg) {
  headless_navigation_menu.navigation_menu_viewport_enabled(
    config: config,
    enabled: enabled,
  )
}

/// Append root attributes.
pub fn navigation_menu_attrs(
  theme _theme: theme.Theme,
  config config: NavigationMenuConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> NavigationMenuConfig(msg) {
  headless_navigation_menu.navigation_menu_attrs(config: config, attrs: attrs)
}

/// Read the viewport-enabled setting from config.
pub fn navigation_menu_config_viewport_enabled(
  theme _theme: theme.Theme,
  config config: NavigationMenuConfig(msg),
) -> Bool {
  headless_navigation_menu.navigation_menu_config_viewport_enabled(
    config: config,
  )
}

/// Trigger baseline style attributes for navigation-menu triggers.
pub fn navigation_menu_trigger_style(
  theme _theme: theme.Theme,
) -> List(weft.Attribute) {
  headless_navigation_menu.navigation_menu_trigger_style()
}

fn root_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  [
    weft.row_layout(),
    weft.align_items(value: weft.align_items_center()),
    weft.justify_content(value: weft.justify_center()),
    weft.font_family(families: theme.font_families(theme)),
  ]
}

/// Render the styled root navigation-menu container.
pub fn navigation_menu(
  theme theme: theme.Theme,
  config config: NavigationMenuConfig(msg),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let viewport_enabled =
    headless_navigation_menu.navigation_menu_config_viewport_enabled(
      config: config,
    )
  let config = case viewport_enabled {
    True ->
      headless_navigation_menu.navigation_menu_viewport_enabled(
        config: config,
        enabled: False,
      )
    False -> config
  }
  let children = case viewport_enabled {
    True ->
      list.append(children, [
        navigation_menu_viewport(theme: theme, attrs: [], children: []),
      ])
    False -> children
  }

  headless_navigation_menu.navigation_menu(
    config: config
      |> headless_navigation_menu.navigation_menu_attrs(attrs: [
        weft_lustre.styles(root_styles(theme: theme)),
      ]),
    children: children,
  )
}

/// Render a styled navigation-menu list container.
pub fn navigation_menu_list(
  theme _theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  headless_navigation_menu.navigation_menu_list(
    attrs: list.append(
      [
        weft_lustre.styles([
          weft.row_layout(),
          weft.align_items(value: weft.align_items_center()),
          weft.spacing(pixels: 4),
        ]),
      ],
      attrs,
    ),
    children: children,
  )
}

/// Render a styled navigation-menu item container.
pub fn navigation_menu_item(
  theme _theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  headless_navigation_menu.navigation_menu_item(
    attrs: list.append(
      [
        weft_lustre.styles([
          weft.position(value: weft.position_relative()),
        ]),
      ],
      attrs,
    ),
    children: children,
  )
}

fn trigger_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  let #(surface_bg, surface_fg) = theme.surface(theme)

  list.append(headless_navigation_menu.navigation_menu_trigger_style(), [
    weft.background(color: surface_bg),
    weft.text_color(color: surface_fg),
    weft.border(
      width: weft.px(pixels: 1),
      style: weft.border_style_solid(),
      color: theme.border_color(theme),
    ),
    weft.outline_none(),
  ])
}

/// Render a styled navigation-menu trigger.
pub fn navigation_menu_trigger(
  theme theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  child child: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  headless_navigation_menu.navigation_menu_trigger(
    attrs: list.append(
      [weft_lustre.styles(trigger_styles(theme: theme))],
      attrs,
    ),
    child: child,
  )
}

/// Render styled navigation-menu content.
pub fn navigation_menu_content(
  theme theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let #(overlay_bg, overlay_fg) = theme.overlay_surface(theme)

  headless_navigation_menu.navigation_menu_content(
    attrs: list.append(
      [
        weft_lustre.styles([
          weft.padding(pixels: 8),
          weft.background(color: overlay_bg),
          weft.text_color(color: overlay_fg),
          weft.rounded(radius: theme.radius_md(theme)),
          weft.border(
            width: weft.px(pixels: 1),
            style: weft.border_style_solid(),
            color: theme.border_color(theme),
          ),
        ]),
      ],
      attrs,
    ),
    children: children,
  )
}

/// Render styled navigation-menu viewport.
pub fn navigation_menu_viewport(
  theme theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  headless_navigation_menu.navigation_menu_viewport(
    attrs: list.append(
      [
        weft_lustre.styles([
          weft.position(value: weft.position_absolute()),
          weft.top(length: weft.pct(pct: 100.0)),
          weft.left(length: weft.px(pixels: 0)),
          weft.padding_top(pixels: 6),
          weft.width(length: weft.fill()),
          weft.font_family(families: theme.font_families(theme)),
        ]),
      ],
      attrs,
    ),
    children: children,
  )
}

/// Render a styled navigation-menu link.
pub fn navigation_menu_link(
  theme theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  child child: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  let #(_, surface_fg) = theme.surface(theme)

  headless_navigation_menu.navigation_menu_link(
    attrs: list.append(
      [
        weft_lustre.styles([
          weft.display(value: weft.display_flex()),
          weft.padding(pixels: 8),
          weft.rounded(radius: theme.radius_md(theme)),
          weft.text_color(color: surface_fg),
          weft.text_decoration(value: weft.text_decoration_none()),
        ]),
      ],
      attrs,
    ),
    child: child,
  )
}

/// Render a styled navigation-menu indicator.
pub fn navigation_menu_indicator(
  theme theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  child child: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  headless_navigation_menu.navigation_menu_indicator(
    attrs: list.append(
      [
        weft_lustre.styles([
          weft.display(value: weft.display_flex()),
          weft.align_items(value: weft.align_items_end()),
          weft.justify_content(value: weft.justify_center()),
          weft.height(length: weft.fixed(length: weft.px(pixels: 8))),
          weft.text_color(color: theme.border_color(theme)),
        ]),
      ],
      attrs,
    ),
    child: child,
  )
}
