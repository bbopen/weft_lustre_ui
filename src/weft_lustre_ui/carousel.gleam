//// Styled carousel primitives for shadcn compatibility.
////
//// Applies theme-driven visuals to `headless/carousel` slots.

import weft
import weft_lustre
import weft_lustre_ui/headless/carousel as headless_carousel
import weft_lustre_ui/theme

/// Carousel orientation token alias.
pub type CarouselOrientation =
  headless_carousel.CarouselOrientation

/// Styled carousel root configuration alias.
pub type CarouselConfig(msg) =
  headless_carousel.CarouselConfig(msg)

/// Styled carousel content configuration alias.
pub type CarouselContentConfig(msg) =
  headless_carousel.CarouselContentConfig(msg)

/// Styled carousel item configuration alias.
pub type CarouselItemConfig(msg) =
  headless_carousel.CarouselItemConfig(msg)

/// Styled carousel control configuration alias.
pub type CarouselControlConfig(msg) =
  headless_carousel.CarouselControlConfig(msg)

/// Horizontal carousel orientation.
pub fn carousel_horizontal(theme _theme: theme.Theme) -> CarouselOrientation {
  headless_carousel.carousel_horizontal()
}

/// Vertical carousel orientation.
pub fn carousel_vertical(theme _theme: theme.Theme) -> CarouselOrientation {
  headless_carousel.carousel_vertical()
}

/// Construct a default carousel configuration.
pub fn carousel_config(theme _theme: theme.Theme) -> CarouselConfig(msg) {
  headless_carousel.carousel_config()
}

/// Set carousel orientation.
pub fn carousel_orientation(
  theme _theme: theme.Theme,
  config config: CarouselConfig(msg),
  orientation orientation: CarouselOrientation,
) -> CarouselConfig(msg) {
  headless_carousel.carousel_orientation(
    config: config,
    orientation: orientation,
  )
}

/// Append carousel root attributes.
pub fn carousel_attrs(
  theme _theme: theme.Theme,
  config config: CarouselConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> CarouselConfig(msg) {
  headless_carousel.carousel_attrs(config: config, attrs: attrs)
}

/// Construct a default carousel content configuration.
pub fn carousel_content_config(
  theme _theme: theme.Theme,
) -> CarouselContentConfig(msg) {
  headless_carousel.carousel_content_config()
}

/// Set carousel content orientation.
pub fn carousel_content_orientation(
  theme _theme: theme.Theme,
  config config: CarouselContentConfig(msg),
  orientation orientation: CarouselOrientation,
) -> CarouselContentConfig(msg) {
  headless_carousel.carousel_content_orientation(
    config: config,
    orientation: orientation,
  )
}

/// Append carousel content attributes.
pub fn carousel_content_attrs(
  theme _theme: theme.Theme,
  config config: CarouselContentConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> CarouselContentConfig(msg) {
  headless_carousel.carousel_content_attrs(config: config, attrs: attrs)
}

/// Construct a default carousel item configuration.
pub fn carousel_item_config(
  theme _theme: theme.Theme,
) -> CarouselItemConfig(msg) {
  headless_carousel.carousel_item_config()
}

/// Set carousel item orientation.
pub fn carousel_item_orientation(
  theme _theme: theme.Theme,
  config config: CarouselItemConfig(msg),
  orientation orientation: CarouselOrientation,
) -> CarouselItemConfig(msg) {
  headless_carousel.carousel_item_orientation(
    config: config,
    orientation: orientation,
  )
}

/// Append carousel item attributes.
pub fn carousel_item_attrs(
  theme _theme: theme.Theme,
  config config: CarouselItemConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> CarouselItemConfig(msg) {
  headless_carousel.carousel_item_attrs(config: config, attrs: attrs)
}

/// Construct a default carousel control configuration.
pub fn carousel_control_config(
  theme _theme: theme.Theme,
) -> CarouselControlConfig(msg) {
  headless_carousel.carousel_control_config()
}

/// Mark a carousel control disabled.
pub fn carousel_control_disabled(
  theme _theme: theme.Theme,
  config config: CarouselControlConfig(msg),
) -> CarouselControlConfig(msg) {
  headless_carousel.carousel_control_disabled(config: config)
}

/// Set carousel control click message.
pub fn carousel_control_on_press(
  theme _theme: theme.Theme,
  config config: CarouselControlConfig(msg),
  on_press on_press: msg,
) -> CarouselControlConfig(msg) {
  headless_carousel.carousel_control_on_press(
    config: config,
    on_press: on_press,
  )
}

/// Append carousel control attributes.
pub fn carousel_control_attrs(
  theme _theme: theme.Theme,
  config config: CarouselControlConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> CarouselControlConfig(msg) {
  headless_carousel.carousel_control_attrs(config: config, attrs: attrs)
}

/// Check whether carousel orientation is vertical.
pub fn carousel_orientation_is_vertical(
  theme _theme: theme.Theme,
  orientation orientation: CarouselOrientation,
) -> Bool {
  headless_carousel.carousel_orientation_is_vertical(orientation: orientation)
}

/// Read orientation from a carousel root config.
pub fn carousel_config_orientation(
  theme _theme: theme.Theme,
  config config: CarouselConfig(msg),
) -> CarouselOrientation {
  headless_carousel.carousel_config_orientation(config: config)
}

/// Read orientation from a carousel content config.
pub fn carousel_content_config_orientation(
  theme _theme: theme.Theme,
  config config: CarouselContentConfig(msg),
) -> CarouselOrientation {
  headless_carousel.carousel_content_config_orientation(config: config)
}

/// Read orientation from a carousel item config.
pub fn carousel_item_config_orientation(
  theme _theme: theme.Theme,
  config config: CarouselItemConfig(msg),
) -> CarouselOrientation {
  headless_carousel.carousel_item_config_orientation(config: config)
}

fn root_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  [
    weft.position(value: weft.position_relative()),
    weft.width(length: weft.fill()),
    weft.font_family(families: theme.font_families(theme)),
  ]
}

/// Render the styled carousel root.
pub fn carousel(
  theme theme: theme.Theme,
  config config: CarouselConfig(msg),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  headless_carousel.carousel(
    config: config
      |> headless_carousel.carousel_attrs(attrs: [
        weft_lustre.styles(root_styles(theme: theme)),
      ]),
    children: children,
  )
}

fn content_styles(orientation: CarouselOrientation) -> List(weft.Attribute) {
  case
    headless_carousel.carousel_orientation_is_vertical(orientation: orientation)
  {
    True -> [
      weft.column_layout(),
      weft.spacing(pixels: 16),
      weft.overflow(overflow: weft.overflow_hidden()),
    ]
    False -> [
      weft.row_layout(),
      weft.spacing(pixels: 16),
      weft.overflow(overflow: weft.overflow_hidden()),
    ]
  }
}

/// Render styled carousel content.
pub fn carousel_content(
  theme _theme: theme.Theme,
  config config: CarouselContentConfig(msg),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let orientation =
    headless_carousel.carousel_content_config_orientation(config: config)

  headless_carousel.carousel_content(
    config: config
      |> headless_carousel.carousel_content_attrs(attrs: [
        weft_lustre.styles(content_styles(orientation)),
      ]),
    children: children,
  )
}

fn item_styles(orientation: CarouselOrientation) -> List(weft.Attribute) {
  case
    headless_carousel.carousel_orientation_is_vertical(orientation: orientation)
  {
    True -> [weft.width(length: weft.fill())]
    False -> [weft.width(length: weft.fill())]
  }
}

/// Render a styled carousel item.
pub fn carousel_item(
  theme _theme: theme.Theme,
  config config: CarouselItemConfig(msg),
  child child: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  let orientation =
    headless_carousel.carousel_item_config_orientation(config: config)

  headless_carousel.carousel_item(
    config: config
      |> headless_carousel.carousel_item_attrs(attrs: [
        weft_lustre.styles(item_styles(orientation)),
      ]),
    child: child,
  )
}

fn control_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  let #(surface_bg, surface_fg) = theme.surface(theme)

  [
    weft.display(value: weft.display_inline_flex()),
    weft.align_items(value: weft.align_items_center()),
    weft.justify_content(value: weft.justify_center()),
    weft.padding_xy(x: 10, y: 8),
    weft.rounded(radius: theme.radius_md(theme)),
    weft.border(
      width: weft.px(pixels: 1),
      style: weft.border_style_solid(),
      color: theme.border_color(theme),
    ),
    weft.background(color: surface_bg),
    weft.text_color(color: surface_fg),
    weft.font_family(families: theme.font_families(theme)),
  ]
}

/// Render a styled previous-slide button.
pub fn carousel_previous(
  theme theme: theme.Theme,
  config config: CarouselControlConfig(msg),
) -> weft_lustre.Element(msg) {
  headless_carousel.carousel_previous(
    config: config
    |> headless_carousel.carousel_control_attrs(attrs: [
      weft_lustre.styles(control_styles(theme: theme)),
    ]),
  )
}

/// Render a styled next-slide button.
pub fn carousel_next(
  theme theme: theme.Theme,
  config config: CarouselControlConfig(msg),
) -> weft_lustre.Element(msg) {
  headless_carousel.carousel_next(
    config: config
    |> headless_carousel.carousel_control_attrs(attrs: [
      weft_lustre.styles(control_styles(theme: theme)),
    ]),
  )
}
