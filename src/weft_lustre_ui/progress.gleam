//// Styled, theme-driven progress bar component for weft_lustre_ui.
////
//// This wrapper maps progress bar styling to theme token-driven colors and
//// keeps all styling composed from `weft` attributes. The indicator position
//// is controlled via `transform: translateX(...)` following the shadcn pattern.

import gleam/float
import gleam/list
import lustre/attribute
import weft
import weft_lustre
import weft_lustre_ui/theme

/// Styled progress bar configuration.
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
  let rounded = float.round(value)
  int_to_string(rounded)
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

fn track_styles(t: theme.Theme) -> List(weft.Attribute) {
  let #(muted_bg, _muted_fg) = theme.muted(t)

  [
    weft.position(value: weft.position_relative()),
    weft.overflow(overflow: weft.overflow_hidden()),
    weft.width(length: weft.fill()),
    weft.height(length: weft.fixed(length: weft.px(pixels: 8))),
    weft.rounded(radius: weft.px(pixels: 9999)),
    weft.background(color: muted_bg),
  ]
}

fn indicator_styles(t: theme.Theme, offset: Float) -> List(weft.Attribute) {
  let #(primary_bg, _primary_fg) = theme.primary(t)

  [
    weft.height(length: weft.fill()),
    weft.width(length: weft.fill()),
    weft.background(color: primary_bg),
    weft.rounded(radius: weft.px(pixels: 9999)),
    weft.transform(items: [
      weft.translate(x: weft.pct(pct: offset), y: weft.px(pixels: 0)),
    ]),
    weft.transition(
      property: weft.transition_property_transform(),
      duration: weft.ms(milliseconds: 200),
      easing: weft.ease_in_out(),
    ),
  ]
}

/// Render a styled progress bar.
///
/// The progress bar renders a themed track with a primary-colored indicator.
/// The indicator position is animated via transform.
pub fn progress(
  theme theme: theme.Theme,
  config config: ProgressConfig(msg),
) -> weft_lustre.Element(msg) {
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

      let indicator =
        weft_lustre.element_tag(
          tag: "div",
          base_weft_attrs: [weft.el_layout()],
          attrs: [weft_lustre.styles(indicator_styles(theme, offset))],
          children: [],
        )

      weft_lustre.element_tag(
        tag: "div",
        base_weft_attrs: [weft.el_layout()],
        attrs: list.flatten([
          [weft_lustre.styles(track_styles(theme))],
          aria_attrs,
          attrs,
        ]),
        children: [indicator],
      )
    }
  }
}
