//// Styled collapsible component for weft_lustre_ui.

import weft
import weft_lustre
import weft_lustre_ui/headless/collapsible as headless_collapsible
import weft_lustre_ui/theme

/// Styled collapsible configuration alias.
pub type CollapsibleConfig(msg) =
  headless_collapsible.CollapsibleConfig(msg)

/// Construct a collapsible configuration.
pub fn collapsible_config(
  open open: Bool,
  on_toggle on_toggle: fn(Bool) -> msg,
) -> CollapsibleConfig(msg) {
  headless_collapsible.collapsible_config(open: open, on_toggle: on_toggle)
}

/// Append additional root attributes.
pub fn collapsible_attrs(
  config config: CollapsibleConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> CollapsibleConfig(msg) {
  headless_collapsible.collapsible_attrs(config: config, attrs: attrs)
}

/// Append trigger attributes.
pub fn collapsible_trigger_attrs(
  config config: CollapsibleConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> CollapsibleConfig(msg) {
  headless_collapsible.collapsible_trigger_attrs(config: config, attrs: attrs)
}

/// Append content attributes.
pub fn collapsible_content_attrs(
  config config: CollapsibleConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> CollapsibleConfig(msg) {
  headless_collapsible.collapsible_content_attrs(config: config, attrs: attrs)
}

fn styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  [
    weft.spacing(pixels: 8),
    weft.width(length: weft.fixed(length: weft.pct(pct: 100.0))),
    weft.font_family(families: theme.font_families(theme)),
  ]
}

fn trigger_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  [
    weft.display(value: weft.display_flex()),
    weft.align_items(value: weft.align_items_center()),
    weft.justify_content(value: weft.justify_space_between()),
    weft.width(length: weft.fixed(length: weft.pct(pct: 100.0))),
    weft.padding_xy(x: 8, y: 6),
    weft.rounded(radius: theme.radius_md(theme)),
    weft.background(color: weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.0)),
    weft.font_size(size: weft.rem(rem: 0.875)),
    weft.font_weight(weight: weft.font_weight_value(weight: 560)),
    weft.text_align(align: weft.text_align_left()),
    weft.outline_none(),
    weft.appearance(value: weft.appearance_none()),
    weft.mouse_over(attrs: [
      weft.background(color: weft.rgb(red: 244, green: 244, blue: 245)),
    ]),
  ]
}

fn content_styles() -> List(weft.Attribute) {
  [
    weft.padding_xy(x: 8, y: 0),
  ]
}

/// Render a styled collapsible.
pub fn collapsible(
  theme theme: theme.Theme,
  config config: CollapsibleConfig(msg),
  trigger trigger: weft_lustre.Element(msg),
  content content: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  headless_collapsible.collapsible(
    config: config
      |> headless_collapsible.collapsible_attrs(attrs: [
        weft_lustre.styles(styles(theme: theme)),
      ])
      |> headless_collapsible.collapsible_trigger_attrs(attrs: [
        weft_lustre.styles(trigger_styles(theme: theme)),
      ])
      |> headless_collapsible.collapsible_content_attrs(attrs: [
        weft_lustre.styles(content_styles()),
      ]),
    trigger: trigger,
    content: content,
  )
}
