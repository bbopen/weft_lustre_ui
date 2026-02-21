//// Styled, theme-driven keyboard shortcut component for weft_lustre_ui.
////
//// Renders a `<kbd>` element with monospace font, muted background,
//// small padding, rounded corners, and a subtle border.

import gleam/list
import weft
import weft_lustre
import weft_lustre_ui/headless/kbd as headless_kbd
import weft_lustre_ui/theme

/// Styled kbd configuration alias.
pub type KbdConfig(msg) =
  headless_kbd.KbdConfig(msg)

/// Construct a default kbd configuration.
pub fn kbd_config() -> KbdConfig(msg) {
  headless_kbd.kbd_config()
}

/// Append additional attributes to the kbd element.
pub fn kbd_attrs(
  config config: KbdConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> KbdConfig(msg) {
  headless_kbd.kbd_attrs(config: config, attrs: attrs)
}

fn kbd_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  let #(muted_bg, muted_fg) = theme.muted(theme)
  let border = theme.border_color(theme)
  let radius = theme.radius_md(theme)

  [
    weft.display(value: weft.display_inline_flex()),
    weft.align_items(value: weft.align_items_center()),
    weft.justify_content(value: weft.justify_center()),
    weft.height(length: weft.fixed(length: weft.px(pixels: 20))),
    weft.width(length: weft.minimum(
      base: weft.shrink(),
      min: weft.px(pixels: 20),
    )),
    weft.padding_xy(x: 4, y: 0),
    weft.spacing(pixels: 4),
    weft.rounded(radius: radius),
    weft.font_family(families: [weft.font_monospace()]),
    weft.font_size(size: weft.rem(rem: 0.75)),
    weft.font_weight(weight: weft.font_weight_value(weight: 500)),
    weft.line_height(height: weft.line_height_multiple(multiplier: 1.0)),
    weft.text_color(color: muted_fg),
    weft.background(color: muted_bg),
    weft.border(
      width: weft.px(pixels: 1),
      style: weft.border_style_solid(),
      color: border,
    ),
    weft.user_select(value: weft.user_select_none()),
  ]
}

/// Render a styled `<kbd>` element.
pub fn kbd(
  theme theme: theme.Theme,
  config config: KbdConfig(msg),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let attrs = headless_kbd.kbd_config_attrs(config: config)

  weft_lustre.element_tag(
    tag: "kbd",
    base_weft_attrs: [weft.el_layout()],
    attrs: list.append([weft_lustre.styles(kbd_styles(theme: theme))], attrs),
    children: children,
  )
}
