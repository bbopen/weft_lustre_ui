//// Headless (unstyled) skeleton component for weft_lustre_ui.
////
//// This module only emits the structural `<span>` and width/height metadata used by
//// the styled wrapper.

import gleam/list
import gleam/option.{type Option, None, Some}
import weft
import weft_lustre

/// Headless skeleton configuration.
pub opaque type SkeletonConfig(msg) {
  SkeletonConfig(
    width: Option(weft.CssLength),
    height: Option(weft.CssLength),
    radius: Option(weft.CssLength),
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default skeleton configuration.
pub fn skeleton_config() -> SkeletonConfig(msg) {
  SkeletonConfig(width: None, height: None, radius: None, attrs: [])
}

/// Set the skeleton width.
pub fn skeleton_width(
  config config: SkeletonConfig(msg),
  width width: weft.CssLength,
) -> SkeletonConfig(msg) {
  SkeletonConfig(..config, width: Some(width))
}

/// Set the skeleton height.
pub fn skeleton_height(
  config config: SkeletonConfig(msg),
  height height: weft.CssLength,
) -> SkeletonConfig(msg) {
  SkeletonConfig(..config, height: Some(height))
}

/// Set the skeleton radius.
pub fn skeleton_radius(
  config config: SkeletonConfig(msg),
  radius radius: weft.CssLength,
) -> SkeletonConfig(msg) {
  SkeletonConfig(..config, radius: Some(radius))
}

/// Append additional attributes to the skeleton.
pub fn skeleton_attrs(
  config config: SkeletonConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> SkeletonConfig(msg) {
  case config {
    SkeletonConfig(
      width: width,
      height: height,
      radius: radius,
      attrs: existing,
    ) ->
      SkeletonConfig(
        width: width,
        height: height,
        radius: radius,
        attrs: list.append(existing, attrs),
      )
  }
}

/// Read the width configuration from a skeleton config.
pub fn skeleton_config_width(
  config config: SkeletonConfig(msg),
) -> Option(weft.CssLength) {
  case config {
    SkeletonConfig(width: width, ..) -> width
  }
}

/// Read the height configuration from a skeleton config.
pub fn skeleton_config_height(
  config config: SkeletonConfig(msg),
) -> Option(weft.CssLength) {
  case config {
    SkeletonConfig(height: height, ..) -> height
  }
}

/// Read the corner radius configuration from a skeleton config.
pub fn skeleton_config_radius(
  config config: SkeletonConfig(msg),
) -> Option(weft.CssLength) {
  case config {
    SkeletonConfig(radius: radius, ..) -> radius
  }
}

/// Read all configured attributes from a skeleton config.
pub fn skeleton_config_attrs(
  config config: SkeletonConfig(msg),
) -> List(weft_lustre.Attribute(msg)) {
  case config {
    SkeletonConfig(attrs: attrs, ..) -> attrs
  }
}

/// Render a `<span>` skeleton placeholder.
pub fn skeleton(config config: SkeletonConfig(msg)) -> weft_lustre.Element(msg) {
  case config {
    SkeletonConfig(width: _, height: _, radius: _, attrs: attrs) ->
      weft_lustre.element_tag(
        tag: "span",
        base_weft_attrs: [weft.el_layout()],
        attrs: attrs,
        children: [],
      )
  }
}
