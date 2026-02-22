//// Styled, theme-driven radio group component for weft_lustre_ui.
////
//// Renders a `role="radiogroup"` container with flex layout direction
//// matching the chosen orientation, theme-driven gap spacing, and font
//// family. Items are caller-provided elements.

import gleam/list
import lustre/attribute
import weft
import weft_lustre
import weft_lustre_ui/headless/radio_group as headless_radio_group
import weft_lustre_ui/theme

/// Styled radio group configuration alias.
pub type RadioGroupConfig(msg) =
  headless_radio_group.RadioGroupConfig(msg)

/// Styled radio group orientation alias.
pub type RadioGroupOrientation =
  headless_radio_group.RadioGroupOrientation

/// Stack items vertically.
pub const vertical = headless_radio_group.Vertical

/// Lay out items horizontally.
pub const horizontal = headless_radio_group.Horizontal

/// Construct a radio group configuration.
pub fn radio_group_config(
  name name: String,
  value value: String,
  on_change on_change: fn(String) -> msg,
) -> RadioGroupConfig(msg) {
  headless_radio_group.radio_group_config(
    name: name,
    value: value,
    on_change: on_change,
  )
}

/// Disable the radio group.
pub fn radio_group_disabled(
  config config: RadioGroupConfig(msg),
) -> RadioGroupConfig(msg) {
  headless_radio_group.radio_group_disabled(config: config)
}

/// Set the orientation of the radio group.
pub fn radio_group_orientation(
  config config: RadioGroupConfig(msg),
  orientation orientation: RadioGroupOrientation,
) -> RadioGroupConfig(msg) {
  headless_radio_group.radio_group_orientation(
    config: config,
    orientation: orientation,
  )
}

/// Append additional attributes to the radio group.
pub fn radio_group_attrs(
  config config: RadioGroupConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> RadioGroupConfig(msg) {
  headless_radio_group.radio_group_attrs(config: config, attrs: attrs)
}

fn orientation_string(
  orientation: headless_radio_group.RadioGroupOrientation,
) -> String {
  case orientation {
    headless_radio_group.Vertical -> "vertical"
    headless_radio_group.Horizontal -> "horizontal"
  }
}

fn radio_group_styles(
  theme theme: theme.Theme,
  orientation orientation: headless_radio_group.RadioGroupOrientation,
) -> List(weft.Attribute) {
  let layout = case orientation {
    headless_radio_group.Vertical -> weft.column_layout()
    headless_radio_group.Horizontal -> weft.row_layout()
  }

  [
    layout,
    weft.spacing(pixels: 12),
    weft.font_family(families: theme.font_families(theme)),
  ]
}

/// Render a styled radio group container.
///
/// Applies flex layout matching the orientation, theme gap spacing, and
/// font family. Items are caller-provided elements.
pub fn radio_group(
  theme theme: theme.Theme,
  config config: RadioGroupConfig(msg),
  items items: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let orientation =
    headless_radio_group.radio_group_config_orientation(config: config)
  let disabled =
    headless_radio_group.radio_group_config_disabled(config: config)
  let attrs = headless_radio_group.radio_group_config_attrs(config: config)

  let aria_attrs = [
    weft_lustre.html_attribute(attribute.attribute("role", "radiogroup")),
    weft_lustre.html_attribute(attribute.attribute(
      "aria-orientation",
      orientation_string(orientation),
    )),
  ]

  let disabled_attrs = case disabled {
    True -> [
      weft_lustre.html_attribute(attribute.attribute("aria-disabled", "true")),
      weft_lustre.html_attribute(attribute.inert(True)),
    ]
    False -> []
  }

  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.el_layout()],
    attrs: list.flatten([
      [
        weft_lustre.styles(radio_group_styles(
          theme: theme,
          orientation: orientation,
        )),
      ],
      aria_attrs,
      disabled_attrs,
      attrs,
    ]),
    children: items,
  )
}
