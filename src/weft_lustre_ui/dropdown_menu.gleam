//// Styled dropdown-menu component for weft_lustre_ui.

import weft
import weft_lustre
import weft_lustre_ui/headless/dropdown_menu as headless_dropdown_menu
import weft_lustre_ui/theme

/// Styled dropdown menu configuration alias.
pub type DropdownMenuConfig(msg) =
  headless_dropdown_menu.DropdownMenuConfig(msg)

/// Construct dropdown-menu configuration.
pub fn dropdown_menu_config() -> DropdownMenuConfig(msg) {
  headless_dropdown_menu.dropdown_menu_config()
}

/// Append root attributes.
pub fn dropdown_menu_attrs(
  config config: DropdownMenuConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> DropdownMenuConfig(msg) {
  headless_dropdown_menu.dropdown_menu_attrs(config: config, attrs: attrs)
}

/// Append trigger attributes.
pub fn dropdown_menu_trigger_attrs(
  config config: DropdownMenuConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> DropdownMenuConfig(msg) {
  headless_dropdown_menu.dropdown_menu_trigger_attrs(
    config: config,
    attrs: attrs,
  )
}

/// Append content attributes.
pub fn dropdown_menu_content_attrs(
  config config: DropdownMenuConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> DropdownMenuConfig(msg) {
  headless_dropdown_menu.dropdown_menu_content_attrs(
    config: config,
    attrs: attrs,
  )
}

fn styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  let #(surface_bg, _) = theme.surface(theme)

  [
    weft.display(value: weft.display_inline_block()),
    weft.position(value: weft.position_relative()),
    weft.font_family(families: theme.font_families(theme)),
    weft.background(color: surface_bg),
  ]
}

fn trigger_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  let #(surface_bg, surface_fg) = theme.surface(theme)

  [
    weft.display(value: weft.display_inline_flex()),
    weft.align_items(value: weft.align_items_center()),
    weft.padding_xy(x: 10, y: 6),
    weft.rounded(radius: theme.radius_md(theme)),
    weft.border(
      width: weft.px(pixels: 1),
      style: weft.border_style_solid(),
      color: theme.border_color(theme),
    ),
    weft.background(color: surface_bg),
    weft.text_color(color: surface_fg),
    weft.font_size(size: weft.rem(rem: 0.8125)),
    weft.font_weight(weight: weft.font_weight_value(weight: 580)),
    weft.outline_none(),
    weft.appearance(value: weft.appearance_none()),
  ]
}

fn content_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  let #(surface_bg, surface_fg) = theme.surface(theme)

  [
    weft.position(value: weft.position_absolute()),
    weft.top(length: weft.px(pixels: 34)),
    weft.left(length: weft.px(pixels: 0)),
    weft.padding(pixels: 8),
    weft.spacing(pixels: 6),
    weft.rounded(radius: theme.radius_md(theme)),
    weft.border(
      width: weft.px(pixels: 1),
      style: weft.border_style_solid(),
      color: theme.border_color(theme),
    ),
    weft.background(color: surface_bg),
    weft.text_color(color: surface_fg),
    weft.shadows(shadows: [
      weft.shadow(
        x: weft.px(pixels: 0),
        y: weft.px(pixels: 8),
        blur: weft.px(pixels: 24),
        spread: weft.px(pixels: -12),
        color: weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.18),
      ),
    ]),
  ]
}

/// Render a styled dropdown menu.
pub fn dropdown_menu(
  theme theme: theme.Theme,
  config config: DropdownMenuConfig(msg),
  trigger trigger: weft_lustre.Element(msg),
  items items: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  headless_dropdown_menu.dropdown_menu(
    config: config
      |> headless_dropdown_menu.dropdown_menu_attrs(attrs: [
        weft_lustre.styles(styles(theme: theme)),
      ])
      |> headless_dropdown_menu.dropdown_menu_trigger_attrs(attrs: [
        weft_lustre.styles(trigger_styles(theme: theme)),
      ])
      |> headless_dropdown_menu.dropdown_menu_content_attrs(attrs: [
        weft_lustre.styles(content_styles(theme: theme)),
      ]),
    trigger: trigger,
    items: items,
  )
}
