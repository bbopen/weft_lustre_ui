//// Headless (unstyled) progress bar component for weft_lustre_ui.
////
//// This module provides a semantically correct progress bar with
//// `role="progressbar"` and ARIA value attributes. The visual indicator
//// position is controlled via a `transform: translateX(...)` pattern.

import gleam/float
import gleam/list
import lustre/attribute
import weft
import weft_lustre

/// Headless progress bar configuration.
pub opaque type ProgressConfig(msg) {
  ProgressConfig(
    value: Float,
    max: Float,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a progress bar configuration with the given value.
///
/// The value is clamped to `[0, max]` where max defaults to 100.0.
pub fn progress_config(value value: Float) -> ProgressConfig(msg) {
  ProgressConfig(value: value, max: 100.0, attrs: [])
}

/// Set the maximum value of the progress bar.
///
/// Max must be positive. Values less than or equal to zero are treated as 100.0.
pub fn progress_max(
  config config: ProgressConfig(msg),
  max max: Float,
) -> ProgressConfig(msg) {
  let clamped_max = case max >. 0.0 {
    True -> max
    False -> 100.0
  }
  ProgressConfig(..config, max: clamped_max)
}

/// Append additional attributes to the progress bar track.
pub fn progress_attrs(
  config config: ProgressConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ProgressConfig(msg) {
  case config {
    ProgressConfig(attrs: existing, ..) ->
      ProgressConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Internal: read the value from a ProgressConfig.
@internal
pub fn progress_config_value(config config: ProgressConfig(msg)) -> Float {
  case config {
    ProgressConfig(value:, ..) -> value
  }
}

/// Internal: read the max from a ProgressConfig.
@internal
pub fn progress_config_max(config config: ProgressConfig(msg)) -> Float {
  case config {
    ProgressConfig(max:, ..) -> max
  }
}

fn clamp_value(value: Float, max: Float) -> Float {
  case value <. 0.0 {
    True -> 0.0
    False ->
      case value >. max {
        True -> max
        False -> value
      }
  }
}

fn float_to_int_string(value: Float) -> String {
  // Round to nearest integer for ARIA attributes
  let rounded = float.round(value)
  case rounded {
    0 -> "0"
    1 -> "1"
    2 -> "2"
    3 -> "3"
    4 -> "4"
    5 -> "5"
    6 -> "6"
    7 -> "7"
    8 -> "8"
    9 -> "9"
    10 -> "10"
    20 -> "20"
    25 -> "25"
    30 -> "30"
    40 -> "40"
    50 -> "50"
    60 -> "60"
    70 -> "70"
    75 -> "75"
    80 -> "80"
    90 -> "90"
    100 -> "100"
    _ -> {
      // For arbitrary integers, use int module
      int_to_string(rounded)
    }
  }
}

fn int_to_string(n: Int) -> String {
  case n < 0 {
    True -> "-" <> positive_int_to_string(-n)
    False -> positive_int_to_string(n)
  }
}

fn positive_int_to_string(n: Int) -> String {
  case n < 10 {
    True -> digit_to_string(n)
    False -> positive_int_to_string(n / 10) <> digit_to_string(n % 10)
  }
}

fn digit_to_string(d: Int) -> String {
  case d {
    0 -> "0"
    1 -> "1"
    2 -> "2"
    3 -> "3"
    4 -> "4"
    5 -> "5"
    6 -> "6"
    7 -> "7"
    8 -> "8"
    _ -> "9"
  }
}

/// Render a headless progress bar.
///
/// The progress bar renders a track `div` with `role="progressbar"` and an
/// inner indicator `div` positioned via `transform: translateX(...)`.
pub fn progress(config config: ProgressConfig(msg)) -> weft_lustre.Element(msg) {
  case config {
    ProgressConfig(value: raw_value, max: max, attrs: attrs) -> {
      let value = clamp_value(raw_value, max)
      let percentage = value *. 100.0 /. max
      let offset = 0.0 -. { 100.0 -. percentage }

      let aria_attrs = [
        weft_lustre.html_attribute(attribute.role("progressbar")),
        weft_lustre.html_attribute(attribute.attribute(
          "aria-valuenow",
          float_to_int_string(value),
        )),
        weft_lustre.html_attribute(attribute.attribute("aria-valuemin", "0")),
        weft_lustre.html_attribute(attribute.attribute(
          "aria-valuemax",
          float_to_int_string(max),
        )),
      ]

      let track_styles = [
        weft.position(value: weft.position_relative()),
        weft.overflow(overflow: weft.overflow_hidden()),
        weft.width(length: weft.fill()),
      ]

      let indicator_styles = [
        weft.height(length: weft.fill()),
        weft.width(length: weft.fill()),
        weft.transform(items: [
          weft.translate(x: weft.pct(pct: offset), y: weft.px(pixels: 0)),
        ]),
      ]

      let indicator =
        weft_lustre.element_tag(
          tag: "div",
          base_weft_attrs: [weft.el_layout()],
          attrs: [weft_lustre.styles(indicator_styles)],
          children: [],
        )

      weft_lustre.element_tag(
        tag: "div",
        base_weft_attrs: [weft.el_layout()],
        attrs: list.flatten([
          [weft_lustre.styles(track_styles)],
          aria_attrs,
          attrs,
        ]),
        children: [indicator],
      )
    }
  }
}
