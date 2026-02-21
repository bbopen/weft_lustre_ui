//// Styled aspect ratio component for weft_lustre_ui.
////
//// Wraps content in a container with CSS `aspect-ratio` and overflow hidden
//// for containing replaced elements like images and video.

import gleam/list
import weft
import weft_lustre
import weft_lustre_ui/headless/aspect_ratio as headless_aspect_ratio

/// Styled aspect ratio configuration alias.
pub type AspectRatioConfig(msg) =
  headless_aspect_ratio.AspectRatioConfig(msg)

/// Construct an aspect ratio configuration with integer width and height.
///
/// For example, `aspect_ratio_config(width: 16, height: 9)` for a 16:9 ratio.
pub fn aspect_ratio_config(
  width width: Int,
  height height: Int,
) -> AspectRatioConfig(msg) {
  headless_aspect_ratio.aspect_ratio_config(width: width, height: height)
}

/// Append additional attributes to the aspect ratio container.
pub fn aspect_ratio_attrs(
  config config: AspectRatioConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> AspectRatioConfig(msg) {
  headless_aspect_ratio.aspect_ratio_attrs(config: config, attrs: attrs)
}

fn aspect_ratio_styles() -> List(weft.Attribute) {
  [
    weft.overflow(overflow: weft.overflow_hidden()),
    weft.width(length: weft.fill()),
  ]
}

/// Render a styled aspect ratio container.
pub fn aspect_ratio(
  config config: AspectRatioConfig(msg),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let width = headless_aspect_ratio.aspect_ratio_config_width(config: config)
  let height = headless_aspect_ratio.aspect_ratio_config_height(config: config)
  let attrs = headless_aspect_ratio.aspect_ratio_config_attrs(config: config)

  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [
      weft.el_layout(),
      weft.aspect_ratio(width: width, height: height),
    ],
    attrs: list.append([weft_lustre.styles(aspect_ratio_styles())], attrs),
    children: children,
  )
}
