//// Styled, theme-driven button group component for weft_lustre_ui.
////
//// Renders a container with `role="group"` and flex layout for grouping
//// related buttons. Children are displayed in a row or column depending
//// on orientation.

import gleam/list
import lustre/attribute
import weft
import weft_lustre
import weft_lustre_ui/headless/button_group as headless_button_group
import weft_lustre_ui/theme

/// Styled button group orientation alias.
pub type ButtonGroupOrientation =
  headless_button_group.ButtonGroupOrientation

/// Styled button group configuration alias.
pub type ButtonGroupConfig(msg) =
  headless_button_group.ButtonGroupConfig(msg)

/// Horizontal orientation (default).
pub fn button_group_horizontal() -> ButtonGroupOrientation {
  headless_button_group.button_group_horizontal()
}

/// Vertical orientation.
pub fn button_group_vertical() -> ButtonGroupOrientation {
  headless_button_group.button_group_vertical()
}

/// Construct a default button group configuration.
pub fn button_group_config() -> ButtonGroupConfig(msg) {
  headless_button_group.button_group_config()
}

/// Set the button group orientation.
pub fn button_group_orientation(
  config config: ButtonGroupConfig(msg),
  orientation orientation: ButtonGroupOrientation,
) -> ButtonGroupConfig(msg) {
  headless_button_group.button_group_orientation(
    config: config,
    orientation: orientation,
  )
}

/// Append additional attributes to the button group.
pub fn button_group_attrs(
  config config: ButtonGroupConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ButtonGroupConfig(msg) {
  headless_button_group.button_group_attrs(config: config, attrs: attrs)
}

fn group_styles(
  theme theme: theme.Theme,
  orientation orientation: ButtonGroupOrientation,
) -> List(weft.Attribute) {
  let _font_families = theme.font_families(theme)
  let is_vertical =
    headless_button_group.button_group_orientation_is_vertical(
      orientation: orientation,
    )

  let layout = case is_vertical {
    True -> weft.column_layout()
    False -> weft.row_layout()
  }

  [
    layout,
    weft.display(value: weft.display_inline_flex()),
    weft.align_items(value: weft.align_items_stretch()),
    weft.width(length: weft.shrink()),
  ]
}

/// Render a styled button group.
pub fn button_group(
  theme theme: theme.Theme,
  config config: ButtonGroupConfig(msg),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let orientation =
    headless_button_group.button_group_config_orientation(config: config)
  let attrs = headless_button_group.button_group_config_attrs(config: config)

  let styled_attrs =
    list.flatten([
      [
        weft_lustre.html_attribute(attribute.role("group")),
        weft_lustre.styles(group_styles(theme: theme, orientation: orientation)),
      ],
      attrs,
    ])

  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.el_layout()],
    attrs: styled_attrs,
    children: children,
  )
}
