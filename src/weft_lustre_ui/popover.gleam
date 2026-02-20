//// Styled popover component for weft_lustre_ui.

import weft
import weft_lustre
import weft_lustre_ui/headless/popover as headless_popover
import weft_lustre_ui/theme

/// Styled popover configuration alias.
pub type PopoverConfig(msg) =
  headless_popover.PopoverConfig(msg)

/// Construct popover configuration.
pub fn popover_config(
  open open: Bool,
  on_toggle on_toggle: fn(Bool) -> msg,
) -> PopoverConfig(msg) {
  headless_popover.popover_config(open: open, on_toggle: on_toggle)
}

/// Append root attributes.
pub fn popover_attrs(
  config config: PopoverConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> PopoverConfig(msg) {
  headless_popover.popover_attrs(config: config, attrs: attrs)
}

/// Append trigger attributes.
pub fn popover_trigger_attrs(
  config config: PopoverConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> PopoverConfig(msg) {
  headless_popover.popover_trigger_attrs(config: config, attrs: attrs)
}

/// Append panel attributes.
pub fn popover_panel_attrs(
  config config: PopoverConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> PopoverConfig(msg) {
  headless_popover.popover_panel_attrs(config: config, attrs: attrs)
}

fn root_styles() -> List(weft.Attribute) {
  [
    weft.display(value: weft.display_inline_flex()),
    weft.position(value: weft.position_relative()),
  ]
}

fn panel_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  let #(overlay_bg, overlay_fg) = theme.overlay_surface(theme)

  [
    weft.position(value: weft.position_absolute()),
    weft.top(length: weft.pct(pct: 100.0)),
    weft.left(length: weft.px(pixels: 0)),
    weft.padding(pixels: 8),
    weft.background(color: overlay_bg),
    weft.text_color(color: overlay_fg),
    weft.rounded(radius: theme.radius_md(theme)),
    weft.shadows(shadows: [
      weft.shadow(
        x: weft.px(pixels: 0),
        y: weft.px(pixels: 10),
        blur: weft.px(pixels: 24),
        spread: weft.px(pixels: -12),
        color: theme.tooltip_shadow(theme),
      ),
    ]),
    weft.font_family(families: theme.font_families(theme)),
  ]
}

fn trigger_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  let #(surface_bg, surface_fg) = theme.surface(theme)

  [
    weft.padding_xy(x: 12, y: 8),
    weft.rounded(radius: theme.radius_md(theme)),
    weft.border(
      width: weft.px(pixels: 1),
      style: weft.border_style_solid(),
      color: theme.border_color(theme),
    ),
    weft.background(color: surface_bg),
    weft.text_color(color: surface_fg),
    weft.font_size(size: weft.rem(rem: 0.875)),
    weft.font_weight(weight: weft.font_weight_value(weight: 400)),
    weft.line_height(height: weft.line_height_multiple(multiplier: 1.4)),
  ]
}

/// Render styled popover.
pub fn popover(
  theme theme: theme.Theme,
  config config: PopoverConfig(msg),
  trigger trigger: weft_lustre.Element(msg),
  panel panel: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  headless_popover.popover(
    config: config
      |> headless_popover.popover_attrs(attrs: [
        weft_lustre.styles(root_styles()),
      ])
      |> headless_popover.popover_trigger_attrs(attrs: [
        weft_lustre.styles(trigger_styles(theme: theme)),
      ])
      |> headless_popover.popover_panel_attrs(attrs: [
        weft_lustre.styles(panel_styles(theme: theme)),
      ]),
    trigger: trigger,
    panel: panel,
  )
}
