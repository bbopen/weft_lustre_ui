//// Styled hover card component for weft_lustre_ui.
////
//// A hover card shows rich content when hovering over a trigger element.
//// This module applies theme-driven styling over the headless hover card.

import weft
import weft_lustre
import weft_lustre_ui/headless/hover_card as headless_hover_card
import weft_lustre_ui/theme

/// Styled hover card configuration alias.
pub type HoverCardConfig(msg) =
  headless_hover_card.HoverCardConfig(msg)

/// Construct hover card configuration.
pub fn hover_card_config(
  open open: Bool,
  on_open_change on_open_change: fn(Bool) -> msg,
) -> HoverCardConfig(msg) {
  headless_hover_card.hover_card_config(
    open: open,
    on_open_change: on_open_change,
  )
}

/// Append root attributes.
pub fn hover_card_attrs(
  config config: HoverCardConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> HoverCardConfig(msg) {
  headless_hover_card.hover_card_attrs(config: config, attrs: attrs)
}

/// Append trigger attributes.
pub fn hover_card_trigger_attrs(
  config config: HoverCardConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> HoverCardConfig(msg) {
  headless_hover_card.hover_card_trigger_attrs(config: config, attrs: attrs)
}

/// Append content attributes.
pub fn hover_card_content_attrs(
  config config: HoverCardConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> HoverCardConfig(msg) {
  headless_hover_card.hover_card_content_attrs(config: config, attrs: attrs)
}

fn root_styles() -> List(weft.Attribute) {
  [
    weft.display(value: weft.display_inline_flex()),
    weft.align_items(value: weft.align_items_start()),
    weft.position(value: weft.position_relative()),
  ]
}

fn content_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  let #(overlay_bg, overlay_fg) = theme.overlay_surface(theme)

  [
    weft.position(value: weft.position_absolute()),
    weft.top(length: weft.pct(pct: 100.0)),
    weft.left(length: weft.px(pixels: 0)),
    weft.width(length: weft.fixed(length: weft.px(pixels: 256))),
    weft.padding(pixels: 16),
    weft.background(color: overlay_bg),
    weft.text_color(color: overlay_fg),
    weft.rounded(radius: theme.radius_md(theme)),
    weft.border(
      width: weft.px(pixels: 1),
      style: weft.border_style_solid(),
      color: theme.border_color(theme),
    ),
    weft.shadows(shadows: [
      weft.shadow(
        x: weft.px(pixels: 0),
        y: weft.px(pixels: 8),
        blur: weft.px(pixels: 24),
        spread: weft.px(pixels: -6),
        color: theme.tooltip_shadow(theme),
      ),
    ]),
    weft.font_family(families: theme.font_families(theme)),
  ]
}

/// Render styled hover card.
pub fn hover_card(
  theme theme: theme.Theme,
  config config: HoverCardConfig(msg),
  trigger trigger: weft_lustre.Element(msg),
  content content: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  headless_hover_card.hover_card(
    config: config
      |> headless_hover_card.hover_card_attrs(attrs: [
        weft_lustre.styles(root_styles()),
      ])
      |> headless_hover_card.hover_card_content_attrs(attrs: [
        weft_lustre.styles(content_styles(theme: theme)),
      ]),
    trigger: trigger,
    content: content,
  )
}
