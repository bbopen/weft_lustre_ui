//// Headless (unstyled) aspect ratio component for weft_lustre_ui.
////
//// Wraps content in a container with a CSS `aspect-ratio` property.
//// Visual appearance is not applied here; the styled wrapper handles
//// overflow and additional layout.

import gleam/list
import weft
import weft_lustre

/// Headless aspect ratio configuration.
pub opaque type AspectRatioConfig(msg) {
  AspectRatioConfig(
    width: Int,
    height: Int,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct an aspect ratio configuration with integer width and height.
///
/// For example, `aspect_ratio_config(width: 16, height: 9)` for a 16:9 ratio.
pub fn aspect_ratio_config(
  width width: Int,
  height height: Int,
) -> AspectRatioConfig(msg) {
  AspectRatioConfig(width: width, height: height, attrs: [])
}

/// Append additional attributes to the aspect ratio container.
pub fn aspect_ratio_attrs(
  config config: AspectRatioConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> AspectRatioConfig(msg) {
  case config {
    AspectRatioConfig(attrs: existing, ..) ->
      AspectRatioConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Internal: read the width from an aspect ratio config.
@internal
pub fn aspect_ratio_config_width(config config: AspectRatioConfig(msg)) -> Int {
  case config {
    AspectRatioConfig(width:, ..) -> width
  }
}

/// Internal: read the height from an aspect ratio config.
@internal
pub fn aspect_ratio_config_height(config config: AspectRatioConfig(msg)) -> Int {
  case config {
    AspectRatioConfig(height:, ..) -> height
  }
}

/// Internal: read the attrs from an aspect ratio config.
@internal
pub fn aspect_ratio_config_attrs(
  config config: AspectRatioConfig(msg),
) -> List(weft_lustre.Attribute(msg)) {
  case config {
    AspectRatioConfig(attrs:, ..) -> attrs
  }
}

/// Render an unstyled aspect ratio container.
pub fn aspect_ratio(
  config config: AspectRatioConfig(msg),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  case config {
    AspectRatioConfig(width:, height:, attrs:) ->
      weft_lustre.element_tag(
        tag: "div",
        base_weft_attrs: [
          weft.el_layout(),
          weft.aspect_ratio(width: width, height: height),
        ],
        attrs: attrs,
        children: children,
      )
  }
}
