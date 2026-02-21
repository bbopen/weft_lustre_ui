//// Styled, theme-driven slider component for weft_lustre_ui.
////
//// Wraps a native `<input type="range">` with theme-driven layout styling
//// including full-width fill, touch-target height, accent color matching
//// the theme primary, and disabled state opacity. Track and thumb rendering
//// rely on the native control since vendor pseudo-elements are outside
//// the weft typed API boundary.

import gleam/dynamic/decode
import gleam/float
import gleam/list
import lustre/attribute
import lustre/event
import weft
import weft_lustre
import weft_lustre_ui/headless/slider as headless_slider
import weft_lustre_ui/theme

/// Styled slider configuration alias.
pub type SliderConfig(msg) =
  headless_slider.SliderConfig(msg)

/// Styled slider orientation alias.
pub type SliderOrientation =
  headless_slider.SliderOrientation

/// Horizontal slider orientation.
pub const slider_horizontal = headless_slider.SliderHorizontal

/// Vertical slider orientation.
pub const slider_vertical = headless_slider.SliderVertical

/// Construct a slider configuration.
pub fn slider_config(
  value value: Float,
  min min: Float,
  max max: Float,
  on_change on_change: fn(Float) -> msg,
) -> SliderConfig(msg) {
  headless_slider.slider_config(
    value: value,
    min: min,
    max: max,
    on_change: on_change,
  )
}

/// Set the step increment for the slider.
pub fn slider_step(
  config config: SliderConfig(msg),
  step step: Float,
) -> SliderConfig(msg) {
  headless_slider.slider_step(config: config, step: step)
}

/// Disable the slider.
pub fn slider_disabled(config config: SliderConfig(msg)) -> SliderConfig(msg) {
  headless_slider.slider_disabled(config: config)
}

/// Set the orientation of the slider.
pub fn slider_orientation(
  config config: SliderConfig(msg),
  orientation orientation: SliderOrientation,
) -> SliderConfig(msg) {
  headless_slider.slider_orientation(config: config, orientation: orientation)
}

/// Append additional attributes to the slider.
pub fn slider_attrs(
  config config: SliderConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> SliderConfig(msg) {
  headless_slider.slider_attrs(config: config, attrs: attrs)
}

fn orientation_string(orientation: headless_slider.SliderOrientation) -> String {
  case orientation {
    headless_slider.SliderHorizontal -> "horizontal"
    headless_slider.SliderVertical -> "vertical"
  }
}

fn slider_styles(
  theme theme: theme.Theme,
  disabled disabled: Bool,
) -> List(weft.Attribute) {
  let #(primary_bg, _) = theme.primary(theme)

  list.flatten([
    [
      weft.width(length: weft.fill()),
      weft.height(length: weft.fixed(length: weft.px(pixels: 36))),
      weft.appearance(value: weft.appearance_none()),
      weft.accent_color(color: primary_bg),
      weft.outline_none(),
    ],
    case disabled {
      True -> [
        weft.alpha(opacity: theme.disabled_opacity(theme)),
        weft.cursor(cursor: weft.cursor_not_allowed()),
      ]
      False -> [weft.cursor(cursor: weft.cursor_pointer())]
    },
  ])
}

/// Render a styled slider.
///
/// Wraps the native range input with theme-driven layout, accent color,
/// and disabled state styling. The native control provides keyboard and
/// screen reader accessibility.
pub fn slider(
  theme theme: theme.Theme,
  config config: SliderConfig(msg),
) -> weft_lustre.Element(msg) {
  let value = headless_slider.slider_config_value(config: config)
  let min = headless_slider.slider_config_min(config: config)
  let max = headless_slider.slider_config_max(config: config)
  let step = headless_slider.slider_config_step(config: config)
  let on_change = headless_slider.slider_config_on_change(config: config)
  let disabled = headless_slider.slider_config_disabled(config: config)
  let orientation = headless_slider.slider_config_orientation(config: config)
  let attrs = headless_slider.slider_config_attrs(config: config)

  let value_str = float.to_string(value)
  let min_str = float.to_string(min)
  let max_str = float.to_string(max)
  let step_str = float.to_string(step)

  let base_attrs = [
    weft_lustre.html_attribute(attribute.type_("range")),
    weft_lustre.html_attribute(attribute.attribute("role", "slider")),
    weft_lustre.html_attribute(attribute.attribute("min", min_str)),
    weft_lustre.html_attribute(attribute.attribute("max", max_str)),
    weft_lustre.html_attribute(attribute.attribute("step", step_str)),
    weft_lustre.html_attribute(attribute.value(value_str)),
    weft_lustre.html_attribute(attribute.attribute("aria-valuenow", value_str)),
    weft_lustre.html_attribute(attribute.attribute("aria-valuemin", min_str)),
    weft_lustre.html_attribute(attribute.attribute("aria-valuemax", max_str)),
    weft_lustre.html_attribute(attribute.attribute(
      "aria-orientation",
      orientation_string(orientation),
    )),
    weft_lustre.styles(slider_styles(theme: theme, disabled: disabled)),
  ]

  let event_attrs = case disabled {
    True -> [weft_lustre.html_attribute(attribute.disabled(True))]
    False -> [
      weft_lustre.html_attribute(
        event.on("input", {
          use value_str <- decode.subfield(["target", "value"], decode.string)
          case float.parse(value_str) {
            Ok(v) -> decode.success(on_change(v))
            Error(_) -> decode.failure(on_change(value), "float")
          }
        }),
      ),
    ]
  }

  weft_lustre.element_tag(
    tag: "input",
    base_weft_attrs: [weft.el_layout()],
    attrs: list.flatten([base_attrs, event_attrs, attrs]),
    children: [],
  )
}
