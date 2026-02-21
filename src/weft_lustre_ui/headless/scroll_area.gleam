//// Headless (unstyled) scroll area component for weft_lustre_ui.
////
//// Renders a `<div>` with `data-slot="scroll-area"` and overflow behavior
//// controlled by the configured scroll orientation. Visual appearance is
//// not applied here; the styled wrapper handles rounded corners and
//// scrollbar theming.

import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute
import weft
import weft_lustre

/// Scroll orientation for the scroll area.
pub type ScrollOrientation {
  /// Allow scrolling on both axes.
  ScrollBoth
  /// Allow vertical scrolling only.
  ScrollVertical
  /// Allow horizontal scrolling only.
  ScrollHorizontal
}

/// Headless scroll area configuration.
pub opaque type ScrollAreaConfig(msg) {
  ScrollAreaConfig(
    orientation: ScrollOrientation,
    max_height: Option(weft.CssLength),
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default scroll area configuration.
///
/// Defaults to `ScrollBoth` orientation with no max height constraint.
pub fn scroll_area_config() -> ScrollAreaConfig(msg) {
  ScrollAreaConfig(orientation: ScrollBoth, max_height: None, attrs: [])
}

/// Set the scroll orientation.
pub fn scroll_area_orientation(
  config config: ScrollAreaConfig(msg),
  orientation orientation: ScrollOrientation,
) -> ScrollAreaConfig(msg) {
  ScrollAreaConfig(..config, orientation: orientation)
}

/// Set the maximum height for the scroll area.
pub fn scroll_area_max_height(
  config config: ScrollAreaConfig(msg),
  height height: weft.CssLength,
) -> ScrollAreaConfig(msg) {
  ScrollAreaConfig(..config, max_height: Some(height))
}

/// Append additional attributes to the scroll area.
pub fn scroll_area_attrs(
  config config: ScrollAreaConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ScrollAreaConfig(msg) {
  case config {
    ScrollAreaConfig(attrs: existing, ..) ->
      ScrollAreaConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Internal: read the orientation from a scroll area config.
@internal
pub fn scroll_area_config_orientation(
  config config: ScrollAreaConfig(msg),
) -> ScrollOrientation {
  case config {
    ScrollAreaConfig(orientation:, ..) -> orientation
  }
}

/// Internal: read the max height from a scroll area config.
@internal
pub fn scroll_area_config_max_height(
  config config: ScrollAreaConfig(msg),
) -> Option(weft.CssLength) {
  case config {
    ScrollAreaConfig(max_height:, ..) -> max_height
  }
}

/// Internal: read the attrs from a scroll area config.
@internal
pub fn scroll_area_config_attrs(
  config config: ScrollAreaConfig(msg),
) -> List(weft_lustre.Attribute(msg)) {
  case config {
    ScrollAreaConfig(attrs:, ..) -> attrs
  }
}

fn orientation_string(orientation: ScrollOrientation) -> String {
  case orientation {
    ScrollBoth -> "both"
    ScrollVertical -> "vertical"
    ScrollHorizontal -> "horizontal"
  }
}

fn overflow_styles(orientation: ScrollOrientation) -> List(weft.Attribute) {
  case orientation {
    ScrollBoth -> [weft.overflow(overflow: weft.overflow_auto())]
    ScrollVertical -> [
      weft.overflow_x(overflow: weft.overflow_hidden()),
      weft.overflow_y(overflow: weft.overflow_auto()),
    ]
    ScrollHorizontal -> [
      weft.overflow_x(overflow: weft.overflow_auto()),
      weft.overflow_y(overflow: weft.overflow_hidden()),
    ]
  }
}

/// Render an unstyled scroll area container.
///
/// Applies overflow behavior based on the scroll orientation and an
/// optional max-height constraint. Children are rendered inside the
/// scrollable viewport.
pub fn scroll_area(
  config config: ScrollAreaConfig(msg),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  case config {
    ScrollAreaConfig(orientation:, max_height:, attrs:) -> {
      let data_attrs = [
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "scroll-area",
        )),
        weft_lustre.html_attribute(attribute.attribute(
          "data-orientation",
          orientation_string(orientation),
        )),
      ]

      let height_styles = case max_height {
        Some(h) -> [
          weft.height(length: weft.maximum(base: weft.shrink(), max: h)),
        ]
        None -> []
      }

      let base_styles =
        list.flatten([
          overflow_styles(orientation),
          height_styles,
        ])

      weft_lustre.element_tag(
        tag: "div",
        base_weft_attrs: [weft.el_layout()],
        attrs: list.flatten([
          [weft_lustre.styles(base_styles)],
          data_attrs,
          attrs,
        ]),
        children: children,
      )
    }
  }
}
