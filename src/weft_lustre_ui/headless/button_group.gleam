//// Headless (unstyled) button group component for weft_lustre_ui.
////
//// Renders a container with `role="group"` for grouping related buttons.
//// Visual appearance is not applied here; the styled wrapper handles
//// border overlapping and rounded corner treatment.

import gleam/list
import lustre/attribute
import weft
import weft_lustre

type Orientation {
  Horizontal
  Vertical
}

/// Button group orientation token.
pub opaque type ButtonGroupOrientation {
  ButtonGroupOrientation(value: Orientation)
}

/// Horizontal orientation (default).
pub fn button_group_horizontal() -> ButtonGroupOrientation {
  ButtonGroupOrientation(value: Horizontal)
}

/// Vertical orientation.
pub fn button_group_vertical() -> ButtonGroupOrientation {
  ButtonGroupOrientation(value: Vertical)
}

/// Headless button group configuration.
pub opaque type ButtonGroupConfig(msg) {
  ButtonGroupConfig(
    orientation: ButtonGroupOrientation,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default button group configuration.
pub fn button_group_config() -> ButtonGroupConfig(msg) {
  ButtonGroupConfig(orientation: button_group_horizontal(), attrs: [])
}

/// Set the button group orientation.
pub fn button_group_orientation(
  config config: ButtonGroupConfig(msg),
  orientation orientation: ButtonGroupOrientation,
) -> ButtonGroupConfig(msg) {
  ButtonGroupConfig(..config, orientation: orientation)
}

/// Append additional attributes to the button group.
pub fn button_group_attrs(
  config config: ButtonGroupConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ButtonGroupConfig(msg) {
  case config {
    ButtonGroupConfig(attrs: existing, ..) ->
      ButtonGroupConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Internal: read the orientation from a button group config.
@internal
pub fn button_group_config_orientation(
  config config: ButtonGroupConfig(msg),
) -> ButtonGroupOrientation {
  case config {
    ButtonGroupConfig(orientation:, ..) -> orientation
  }
}

/// Internal: read the attrs from a button group config.
@internal
pub fn button_group_config_attrs(
  config config: ButtonGroupConfig(msg),
) -> List(weft_lustre.Attribute(msg)) {
  case config {
    ButtonGroupConfig(attrs:, ..) -> attrs
  }
}

/// Internal: check if the orientation is horizontal.
@internal
pub fn button_group_orientation_is_horizontal(
  orientation orientation: ButtonGroupOrientation,
) -> Bool {
  case orientation {
    ButtonGroupOrientation(value: Horizontal) -> True
    ButtonGroupOrientation(value: Vertical) -> False
  }
}

/// Internal: check if the orientation is vertical.
@internal
pub fn button_group_orientation_is_vertical(
  orientation orientation: ButtonGroupOrientation,
) -> Bool {
  case orientation {
    ButtonGroupOrientation(value: Horizontal) -> False
    ButtonGroupOrientation(value: Vertical) -> True
  }
}

/// Render an unstyled button group with role="group".
pub fn button_group(
  config config: ButtonGroupConfig(msg),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  case config {
    ButtonGroupConfig(attrs: attrs, ..) -> {
      let group_attrs = [
        weft_lustre.html_attribute(attribute.role("group")),
      ]

      weft_lustre.element_tag(
        tag: "div",
        base_weft_attrs: [weft.el_layout()],
        attrs: list.append(group_attrs, attrs),
        children: children,
      )
    }
  }
}
