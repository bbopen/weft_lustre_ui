//// Headless (unstyled) separator component for weft_lustre_ui.
////
//// The separator outputs structural HTML only. Styled wrappers are responsible for
//// visual appearance and spacing.

import gleam/list
import lustre/attribute
import weft
import weft_lustre

type Orientation {
  Horizontal
  Vertical
}

/// A separator orientation.
pub opaque type SeparatorOrientation {
  SeparatorOrientation(value: Orientation)
}

/// Horizontal orientation.
pub fn separator_horizontal() -> SeparatorOrientation {
  SeparatorOrientation(value: Horizontal)
}

/// Vertical orientation.
pub fn separator_vertical() -> SeparatorOrientation {
  SeparatorOrientation(value: Vertical)
}

/// Headless separator configuration.
pub opaque type SeparatorConfig(msg) {
  SeparatorConfig(
    orientation: SeparatorOrientation,
    decorative: Bool,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default separator configuration.
pub fn separator_config() -> SeparatorConfig(msg) {
  SeparatorConfig(
    orientation: separator_horizontal(),
    decorative: True,
    attrs: [],
  )
}

/// Set separator orientation.
pub fn separator_orientation(
  config config: SeparatorConfig(msg),
  orientation orientation: SeparatorOrientation,
) -> SeparatorConfig(msg) {
  SeparatorConfig(..config, orientation: orientation)
}

/// Set separator decorative mode.
///
/// Decorative separators are hidden from assistive technologies.
pub fn separator_decorative(
  config config: SeparatorConfig(msg),
  decorative decorative: Bool,
) -> SeparatorConfig(msg) {
  SeparatorConfig(..config, decorative: decorative)
}

/// Internal: read the orientation from a separator config.
@internal
pub fn separator_config_orientation(
  config config: SeparatorConfig(msg),
) -> SeparatorOrientation {
  case config {
    SeparatorConfig(orientation: orientation, ..) -> orientation
  }
}

/// Internal: read decorative mode from a separator config.
@internal
pub fn separator_config_decorative(config config: SeparatorConfig(msg)) -> Bool {
  case config {
    SeparatorConfig(decorative: decorative, ..) -> decorative
  }
}

/// Internal: read all configured attributes from a separator config.
@internal
pub fn separator_config_attrs(
  config config: SeparatorConfig(msg),
) -> List(weft_lustre.Attribute(msg)) {
  case config {
    SeparatorConfig(attrs: attrs, ..) -> attrs
  }
}

/// Internal: is the orientation horizontal?
@internal
pub fn separator_orientation_is_horizontal(
  orientation orientation: SeparatorOrientation,
) -> Bool {
  case orientation {
    SeparatorOrientation(value: Horizontal) -> True
    SeparatorOrientation(value: Vertical) -> False
  }
}

/// Internal: is the orientation vertical?
@internal
pub fn separator_orientation_is_vertical(
  orientation orientation: SeparatorOrientation,
) -> Bool {
  case orientation {
    SeparatorOrientation(value: Horizontal) -> False
    SeparatorOrientation(value: Vertical) -> True
  }
}

/// Append additional attributes to the separator.
pub fn separator_attrs(
  config config: SeparatorConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> SeparatorConfig(msg) {
  case config {
    SeparatorConfig(
      orientation: orientation,
      decorative: decorative,
      attrs: existing,
    ) ->
      SeparatorConfig(
        orientation: orientation,
        decorative: decorative,
        attrs: list.append(existing, attrs),
      )
  }
}

/// Render an unstyled separator.
pub fn separator(
  config config: SeparatorConfig(msg),
) -> weft_lustre.Element(msg) {
  case config {
    SeparatorConfig(orientation: _, decorative: decorative, attrs: attrs) -> {
      let required_html_attrs = case decorative {
        True -> [weft_lustre.html_attribute(attribute.aria_hidden(True))]
        False -> [weft_lustre.html_attribute(attribute.role("separator"))]
      }

      weft_lustre.element_tag(
        tag: "div",
        base_weft_attrs: [weft.el_layout()],
        attrs: list.append(required_html_attrs, attrs),
        children: [],
      )
    }
  }
}
