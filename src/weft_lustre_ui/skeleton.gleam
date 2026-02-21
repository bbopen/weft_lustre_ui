//// Styled skeleton component for weft_lustre_ui.
////
//// This module composes `headless/skeleton` with theme-driven sizing and
//// rendering defaults suitable for loading states.

import gleam/list
import gleam/option.{type Option, None, Some}
import weft
import weft_lustre
import weft_lustre_ui/headless/skeleton as headless_skeleton
import weft_lustre_ui/theme

/// Skeleton configuration — aliased from headless.
pub type SkeletonConfig(msg) =
  headless_skeleton.SkeletonConfig(msg)

/// Construct a default skeleton configuration.
pub fn skeleton_config() -> SkeletonConfig(msg) {
  headless_skeleton.skeleton_config()
}

/// Set the skeleton width.
pub fn skeleton_width(
  config config: SkeletonConfig(msg),
  width width: weft.CssLength,
) -> SkeletonConfig(msg) {
  headless_skeleton.skeleton_width(config:, width:)
}

/// Set the skeleton height.
pub fn skeleton_height(
  config config: SkeletonConfig(msg),
  height height: weft.CssLength,
) -> SkeletonConfig(msg) {
  headless_skeleton.skeleton_height(config:, height:)
}

/// Set the skeleton radius.
pub fn skeleton_radius(
  config config: SkeletonConfig(msg),
  radius radius: weft.CssLength,
) -> SkeletonConfig(msg) {
  headless_skeleton.skeleton_radius(config:, radius:)
}

/// Append additional attributes to the skeleton.
pub fn skeleton_attrs(
  config config: SkeletonConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> SkeletonConfig(msg) {
  headless_skeleton.skeleton_attrs(config:, attrs:)
}

fn skeleton_styles(
  theme theme: theme.Theme,
  width width: Option(weft.CssLength),
  height height: Option(weft.CssLength),
  radius radius: Option(weft.CssLength),
) -> List(weft.Attribute) {
  let width_style = case width {
    None -> [
      weft.width(length: weft.fixed(length: weft.pct(pct: 100.0))),
    ]
    Some(value) -> [weft.width(length: weft.fixed(length: value))]
  }

  let height_style = case height {
    None -> [weft.height(length: weft.fixed(length: weft.rem(rem: 1.0)))]
    Some(value) -> [weft.height(length: weft.fixed(length: value))]
  }

  let radius_style = case radius {
    None -> [weft.rounded(radius: theme.radius_md(theme))]
    Some(value) -> [weft.rounded(radius: value)]
  }

  list.flatten([
    [weft.display(value: weft.display_block())],
    [weft.background(color: theme.muted_text(theme))],
    width_style,
    height_style,
    radius_style,
  ])
}

/// Render a styled skeleton placeholder.
pub fn skeleton(
  theme theme: theme.Theme,
  config config: SkeletonConfig(msg),
) -> weft_lustre.Element(msg) {
  let width = headless_skeleton.skeleton_config_width(config: config)
  let height = headless_skeleton.skeleton_config_height(config: config)
  let radius = headless_skeleton.skeleton_config_radius(config: config)

  let styled =
    headless_skeleton.skeleton_attrs(config: config, attrs: [
      weft_lustre.styles(skeleton_styles(
        theme: theme,
        width: width,
        height: height,
        radius: radius,
      )),
    ])

  headless_skeleton.skeleton(config: styled)
}
