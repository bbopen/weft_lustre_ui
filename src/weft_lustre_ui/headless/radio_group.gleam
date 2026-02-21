//// Headless (unstyled) radio group component for weft_lustre_ui.
////
//// Renders a `<div>` with `role="radiogroup"` and `aria-orientation` for
//// grouping radio items. Visual appearance is not applied here; the styled
//// wrapper handles layout direction and spacing.

import gleam/list
import lustre/attribute
import weft
import weft_lustre

/// Orientation of the radio group layout.
pub type RadioGroupOrientation {
  /// Stack items vertically.
  Vertical
  /// Lay out items horizontally.
  Horizontal
}

/// Headless radio group configuration.
pub opaque type RadioGroupConfig(msg) {
  RadioGroupConfig(
    name: String,
    value: String,
    on_change: fn(String) -> msg,
    disabled: Bool,
    orientation: RadioGroupOrientation,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a radio group configuration.
pub fn radio_group_config(
  name name: String,
  value value: String,
  on_change on_change: fn(String) -> msg,
) -> RadioGroupConfig(msg) {
  RadioGroupConfig(
    name: name,
    value: value,
    on_change: on_change,
    disabled: False,
    orientation: Vertical,
    attrs: [],
  )
}

/// Disable the radio group.
pub fn radio_group_disabled(
  config config: RadioGroupConfig(msg),
) -> RadioGroupConfig(msg) {
  RadioGroupConfig(..config, disabled: True)
}

/// Set the orientation of the radio group.
pub fn radio_group_orientation(
  config config: RadioGroupConfig(msg),
  orientation orientation: RadioGroupOrientation,
) -> RadioGroupConfig(msg) {
  RadioGroupConfig(..config, orientation: orientation)
}

/// Append additional attributes to the radio group.
pub fn radio_group_attrs(
  config config: RadioGroupConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> RadioGroupConfig(msg) {
  case config {
    RadioGroupConfig(attrs: existing, ..) ->
      RadioGroupConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Internal: read the name from a radio group config.
@internal
pub fn radio_group_config_name(config config: RadioGroupConfig(msg)) -> String {
  case config {
    RadioGroupConfig(name:, ..) -> name
  }
}

/// Internal: read the value from a radio group config.
@internal
pub fn radio_group_config_value(config config: RadioGroupConfig(msg)) -> String {
  case config {
    RadioGroupConfig(value:, ..) -> value
  }
}

/// Internal: read the on_change callback from a radio group config.
@internal
pub fn radio_group_config_on_change(
  config config: RadioGroupConfig(msg),
) -> fn(String) -> msg {
  case config {
    RadioGroupConfig(on_change:, ..) -> on_change
  }
}

/// Internal: read the disabled state from a radio group config.
@internal
pub fn radio_group_config_disabled(config config: RadioGroupConfig(msg)) -> Bool {
  case config {
    RadioGroupConfig(disabled:, ..) -> disabled
  }
}

/// Internal: read the orientation from a radio group config.
@internal
pub fn radio_group_config_orientation(
  config config: RadioGroupConfig(msg),
) -> RadioGroupOrientation {
  case config {
    RadioGroupConfig(orientation:, ..) -> orientation
  }
}

/// Internal: read the attrs from a radio group config.
@internal
pub fn radio_group_config_attrs(
  config config: RadioGroupConfig(msg),
) -> List(weft_lustre.Attribute(msg)) {
  case config {
    RadioGroupConfig(attrs:, ..) -> attrs
  }
}

fn orientation_string(orientation: RadioGroupOrientation) -> String {
  case orientation {
    Vertical -> "vertical"
    Horizontal -> "horizontal"
  }
}

/// Render an unstyled radio group container.
///
/// Items are caller-provided elements (typically using an existing radio
/// component). The container applies `role="radiogroup"` and
/// `aria-orientation` for assistive technology.
pub fn radio_group(
  config config: RadioGroupConfig(msg),
  items items: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  case config {
    RadioGroupConfig(orientation:, disabled:, attrs:, ..) -> {
      let aria_attrs = [
        weft_lustre.html_attribute(attribute.attribute("role", "radiogroup")),
        weft_lustre.html_attribute(attribute.attribute(
          "aria-orientation",
          orientation_string(orientation),
        )),
      ]

      let disabled_attrs = case disabled {
        True -> [
          weft_lustre.html_attribute(attribute.attribute(
            "aria-disabled",
            "true",
          )),
        ]
        False -> []
      }

      weft_lustre.element_tag(
        tag: "div",
        base_weft_attrs: [weft.el_layout()],
        attrs: list.flatten([aria_attrs, disabled_attrs, attrs]),
        children: items,
      )
    }
  }
}
