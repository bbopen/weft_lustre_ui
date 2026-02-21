//// Headless (unstyled) slider component for weft_lustre_ui.
////
//// Renders a native `<input type="range">` element with ARIA attributes for
//// value, min, max, and orientation. Keyboard accessibility (arrow keys,
//// Home, End) and screen reader support come free from the native control.
//// Visual appearance is not applied here; the styled wrapper handles
//// track and thumb theming.

import gleam/dynamic/decode
import gleam/float
import gleam/list
import lustre/attribute
import lustre/event
import weft
import weft_lustre

/// Slider orientation.
pub type SliderOrientation {
  /// Horizontal slider (default).
  SliderHorizontal
  /// Vertical slider.
  SliderVertical
}

/// Headless slider configuration.
pub opaque type SliderConfig(msg) {
  SliderConfig(
    value: Float,
    min: Float,
    max: Float,
    step: Float,
    on_change: fn(Float) -> msg,
    disabled: Bool,
    orientation: SliderOrientation,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a slider configuration.
///
/// Defaults to step 1.0, horizontal orientation, enabled.
pub fn slider_config(
  value value: Float,
  min min: Float,
  max max: Float,
  on_change on_change: fn(Float) -> msg,
) -> SliderConfig(msg) {
  SliderConfig(
    value: value,
    min: min,
    max: max,
    step: 1.0,
    on_change: on_change,
    disabled: False,
    orientation: SliderHorizontal,
    attrs: [],
  )
}

/// Set the step increment for the slider.
pub fn slider_step(
  config config: SliderConfig(msg),
  step step: Float,
) -> SliderConfig(msg) {
  SliderConfig(..config, step: step)
}

/// Disable the slider.
pub fn slider_disabled(config config: SliderConfig(msg)) -> SliderConfig(msg) {
  SliderConfig(..config, disabled: True)
}

/// Set the orientation of the slider.
pub fn slider_orientation(
  config config: SliderConfig(msg),
  orientation orientation: SliderOrientation,
) -> SliderConfig(msg) {
  SliderConfig(..config, orientation: orientation)
}

/// Append additional attributes to the slider.
pub fn slider_attrs(
  config config: SliderConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> SliderConfig(msg) {
  case config {
    SliderConfig(attrs: existing, ..) ->
      SliderConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Internal: read the value from a slider config.
@internal
pub fn slider_config_value(config config: SliderConfig(msg)) -> Float {
  case config {
    SliderConfig(value:, ..) -> value
  }
}

/// Internal: read the min from a slider config.
@internal
pub fn slider_config_min(config config: SliderConfig(msg)) -> Float {
  case config {
    SliderConfig(min:, ..) -> min
  }
}

/// Internal: read the max from a slider config.
@internal
pub fn slider_config_max(config config: SliderConfig(msg)) -> Float {
  case config {
    SliderConfig(max:, ..) -> max
  }
}

/// Internal: read the step from a slider config.
@internal
pub fn slider_config_step(config config: SliderConfig(msg)) -> Float {
  case config {
    SliderConfig(step:, ..) -> step
  }
}

/// Internal: read the on_change callback from a slider config.
@internal
pub fn slider_config_on_change(
  config config: SliderConfig(msg),
) -> fn(Float) -> msg {
  case config {
    SliderConfig(on_change:, ..) -> on_change
  }
}

/// Internal: read the disabled state from a slider config.
@internal
pub fn slider_config_disabled(config config: SliderConfig(msg)) -> Bool {
  case config {
    SliderConfig(disabled:, ..) -> disabled
  }
}

/// Internal: read the orientation from a slider config.
@internal
pub fn slider_config_orientation(
  config config: SliderConfig(msg),
) -> SliderOrientation {
  case config {
    SliderConfig(orientation:, ..) -> orientation
  }
}

/// Internal: read the attrs from a slider config.
@internal
pub fn slider_config_attrs(
  config config: SliderConfig(msg),
) -> List(weft_lustre.Attribute(msg)) {
  case config {
    SliderConfig(attrs:, ..) -> attrs
  }
}

fn orientation_string(orientation: SliderOrientation) -> String {
  case orientation {
    SliderHorizontal -> "horizontal"
    SliderVertical -> "vertical"
  }
}

/// Render an unstyled native range input.
///
/// Produces `<input type="range">` with ARIA attributes for value, min, max,
/// and orientation. The `on_change` callback fires on the `input` event,
/// decoding the target value as a float.
pub fn slider(config config: SliderConfig(msg)) -> weft_lustre.Element(msg) {
  case config {
    SliderConfig(
      value:,
      min:,
      max:,
      step:,
      on_change:,
      disabled:,
      orientation:,
      attrs:,
    ) -> {
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
        weft_lustre.html_attribute(attribute.attribute(
          "aria-valuenow",
          value_str,
        )),
        weft_lustre.html_attribute(attribute.attribute("aria-valuemin", min_str)),
        weft_lustre.html_attribute(attribute.attribute("aria-valuemax", max_str)),
        weft_lustre.html_attribute(attribute.attribute(
          "aria-orientation",
          orientation_string(orientation),
        )),
      ]

      let event_attrs = case disabled {
        True -> [weft_lustre.html_attribute(attribute.disabled(True))]
        False -> [
          weft_lustre.html_attribute(
            event.on("input", {
              use value_str <- decode.subfield(
                ["target", "value"],
                decode.string,
              )
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
  }
}
