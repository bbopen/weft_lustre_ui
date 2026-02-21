//// Styled, theme-driven scroll area component for weft_lustre_ui.
////
//// Renders a scrollable container with theme-driven rounded corners and
//// overflow behavior matching the configured scroll orientation. An optional
//// max-height constraint is supported.

import gleam/list
import gleam/option.{type Option, Some}
import lustre/attribute
import weft
import weft_lustre
import weft_lustre_ui/headless/scroll_area as headless_scroll_area
import weft_lustre_ui/theme

/// Styled scroll area configuration alias.
pub type ScrollAreaConfig(msg) =
  headless_scroll_area.ScrollAreaConfig(msg)

/// Styled scroll orientation alias.
pub type ScrollOrientation =
  headless_scroll_area.ScrollOrientation

/// Allow scrolling on both axes.
pub const scroll_both = headless_scroll_area.ScrollBoth

/// Allow vertical scrolling only.
pub const scroll_vertical = headless_scroll_area.ScrollVertical

/// Allow horizontal scrolling only.
pub const scroll_horizontal = headless_scroll_area.ScrollHorizontal

/// Construct a default scroll area configuration.
pub fn scroll_area_config() -> ScrollAreaConfig(msg) {
  headless_scroll_area.scroll_area_config()
}

/// Set the scroll orientation.
pub fn scroll_area_orientation(
  config config: ScrollAreaConfig(msg),
  orientation orientation: ScrollOrientation,
) -> ScrollAreaConfig(msg) {
  headless_scroll_area.scroll_area_orientation(
    config: config,
    orientation: orientation,
  )
}

/// Set the maximum height for the scroll area.
pub fn scroll_area_max_height(
  config config: ScrollAreaConfig(msg),
  height height: weft.CssLength,
) -> ScrollAreaConfig(msg) {
  headless_scroll_area.scroll_area_max_height(config: config, height: height)
}

/// Append additional attributes to the scroll area.
pub fn scroll_area_attrs(
  config config: ScrollAreaConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ScrollAreaConfig(msg) {
  headless_scroll_area.scroll_area_attrs(config: config, attrs: attrs)
}

fn orientation_string(
  orientation: headless_scroll_area.ScrollOrientation,
) -> String {
  case orientation {
    headless_scroll_area.ScrollBoth -> "both"
    headless_scroll_area.ScrollVertical -> "vertical"
    headless_scroll_area.ScrollHorizontal -> "horizontal"
  }
}

fn overflow_styles(
  orientation: headless_scroll_area.ScrollOrientation,
) -> List(weft.Attribute) {
  case orientation {
    headless_scroll_area.ScrollBoth -> [
      weft.overflow(overflow: weft.overflow_auto()),
    ]
    headless_scroll_area.ScrollVertical -> [
      weft.overflow_x(overflow: weft.overflow_hidden()),
      weft.overflow_y(overflow: weft.overflow_auto()),
    ]
    headless_scroll_area.ScrollHorizontal -> [
      weft.overflow_x(overflow: weft.overflow_auto()),
      weft.overflow_y(overflow: weft.overflow_hidden()),
    ]
  }
}

fn scroll_area_styles(
  theme theme: theme.Theme,
  orientation orientation: headless_scroll_area.ScrollOrientation,
  max_height max_height: Option(weft.CssLength),
) -> List(weft.Attribute) {
  let radius = theme.radius_md(theme)

  let height_styles = case max_height {
    Some(h) -> [
      weft.height(length: weft.maximum(base: weft.shrink(), max: h)),
    ]
    option.None -> []
  }

  list.flatten([
    overflow_styles(orientation),
    [weft.rounded(radius: radius)],
    height_styles,
  ])
}

/// Render a styled scroll area container.
///
/// Applies theme-driven rounded corners, overflow behavior matching the
/// orientation, and an optional max-height constraint. Children are rendered
/// inside the scrollable viewport.
pub fn scroll_area(
  theme theme: theme.Theme,
  config config: ScrollAreaConfig(msg),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let orientation =
    headless_scroll_area.scroll_area_config_orientation(config: config)
  let max_height =
    headless_scroll_area.scroll_area_config_max_height(config: config)
  let attrs = headless_scroll_area.scroll_area_config_attrs(config: config)

  let data_attrs = [
    weft_lustre.html_attribute(attribute.attribute("data-slot", "scroll-area")),
    weft_lustre.html_attribute(attribute.attribute(
      "data-orientation",
      orientation_string(orientation),
    )),
  ]

  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.el_layout()],
    attrs: list.flatten([
      [
        weft_lustre.styles(scroll_area_styles(
          theme: theme,
          orientation: orientation,
          max_height: max_height,
        )),
      ],
      data_attrs,
      attrs,
    ]),
    children: children,
  )
}
