//// Styled, theme-driven separator component for weft_lustre_ui.
////
//// Uses semantic orientation from the headless config and applies tokenized styling
//// for both horizontal and vertical separators.

import gleam/list
import weft
import weft_lustre
import weft_lustre_ui/headless/separator as headless_separator
import weft_lustre_ui/theme

/// Separator configuration — aliased from headless.
pub type SeparatorConfig(msg) =
  headless_separator.SeparatorConfig(msg)

/// Separator orientation — aliased from headless.
pub type SeparatorOrientation =
  headless_separator.SeparatorOrientation

/// Horizontal orientation.
pub fn separator_horizontal() -> SeparatorOrientation {
  headless_separator.separator_horizontal()
}

/// Vertical orientation.
pub fn separator_vertical() -> SeparatorOrientation {
  headless_separator.separator_vertical()
}

/// Construct a default separator configuration.
pub fn separator_config() -> SeparatorConfig(msg) {
  headless_separator.separator_config()
}

/// Set separator orientation.
pub fn separator_orientation(
  config config: SeparatorConfig(msg),
  orientation orientation: SeparatorOrientation,
) -> SeparatorConfig(msg) {
  headless_separator.separator_orientation(config:, orientation:)
}

/// Set separator decorative mode.
pub fn separator_decorative(
  config config: SeparatorConfig(msg),
  decorative decorative: Bool,
) -> SeparatorConfig(msg) {
  headless_separator.separator_decorative(config:, decorative:)
}

/// Append additional attributes to the separator.
pub fn separator_attrs(
  config config: SeparatorConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> SeparatorConfig(msg) {
  headless_separator.separator_attrs(config:, attrs:)
}

fn separator_styles(
  theme theme: theme.Theme,
  orientation orientation: SeparatorOrientation,
) -> List(weft.Attribute) {
  let line_color = theme.muted_text(theme)

  let orientation_styles = case
    headless_separator.separator_orientation_is_vertical(
      orientation: orientation,
    )
  {
    True -> [
      weft.display(value: weft.display_inline_block()),
      weft.width(length: weft.fixed(length: weft.px(pixels: 1))),
      weft.height(length: weft.fixed(length: weft.pct(pct: 100.0))),
    ]

    False -> [
      weft.display(value: weft.display_block()),
      weft.height(length: weft.fixed(length: weft.px(pixels: 1))),
      weft.width(length: weft.fixed(length: weft.pct(pct: 100.0))),
    ]
  }

  list.flatten([
    [weft.background(color: line_color)],
    orientation_styles,
  ])
}

/// Render a styled separator with preserved accessibility mode from the headless
/// configuration.
pub fn separator(
  theme theme: theme.Theme,
  config config: SeparatorConfig(msg),
) -> weft_lustre.Element(msg) {
  let orientation =
    headless_separator.separator_config_orientation(config: config)
  let decorated =
    headless_separator.separator_attrs(config: config, attrs: [
      weft_lustre.styles(separator_styles(
        theme: theme,
        orientation: orientation,
      )),
    ])
  headless_separator.separator(config: decorated)
}
