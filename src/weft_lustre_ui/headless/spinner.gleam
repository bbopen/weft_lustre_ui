//// Headless (unstyled) spinner component for weft_lustre_ui.
////
//// Renders a loading indicator with correct ARIA semantics.
//// Visual appearance is not applied here; the styled wrapper handles sizing and color.

import gleam/list
import lustre/attribute
import weft
import weft_lustre

type Size {
  Small
  Medium
  Large
}

/// Spinner size token.
pub opaque type SpinnerSize {
  SpinnerSize(value: Size)
}

/// Small spinner size.
pub fn spinner_small() -> SpinnerSize {
  SpinnerSize(value: Small)
}

/// Medium spinner size (default).
pub fn spinner_medium() -> SpinnerSize {
  SpinnerSize(value: Medium)
}

/// Large spinner size.
pub fn spinner_large() -> SpinnerSize {
  SpinnerSize(value: Large)
}

/// Headless spinner configuration.
pub opaque type SpinnerConfig(msg) {
  SpinnerConfig(
    size: SpinnerSize,
    label: String,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default spinner configuration.
pub fn spinner_config() -> SpinnerConfig(msg) {
  SpinnerConfig(size: spinner_medium(), label: "Loading", attrs: [])
}

/// Set the spinner size.
pub fn spinner_size(
  config config: SpinnerConfig(msg),
  size size: SpinnerSize,
) -> SpinnerConfig(msg) {
  SpinnerConfig(..config, size: size)
}

/// Set the accessible label for the spinner.
pub fn spinner_label(
  config config: SpinnerConfig(msg),
  label label: String,
) -> SpinnerConfig(msg) {
  SpinnerConfig(..config, label: label)
}

/// Append additional attributes to the spinner.
pub fn spinner_attrs(
  config config: SpinnerConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> SpinnerConfig(msg) {
  case config {
    SpinnerConfig(attrs: existing, ..) ->
      SpinnerConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Internal: read the size from a spinner config.
@internal
pub fn spinner_config_size(config config: SpinnerConfig(msg)) -> SpinnerSize {
  case config {
    SpinnerConfig(size:, ..) -> size
  }
}

/// Internal: read the label from a spinner config.
@internal
pub fn spinner_config_label(config config: SpinnerConfig(msg)) -> String {
  case config {
    SpinnerConfig(label:, ..) -> label
  }
}

/// Internal: read the attrs from a spinner config.
@internal
pub fn spinner_config_attrs(
  config config: SpinnerConfig(msg),
) -> List(weft_lustre.Attribute(msg)) {
  case config {
    SpinnerConfig(attrs:, ..) -> attrs
  }
}

/// Internal: map a spinner size to its pixel value.
@internal
pub fn spinner_size_pixels(size size: SpinnerSize) -> Int {
  case size {
    SpinnerSize(value: Small) -> 16
    SpinnerSize(value: Medium) -> 24
    SpinnerSize(value: Large) -> 32
  }
}

/// Render an unstyled spinner with ARIA status role.
pub fn spinner(config config: SpinnerConfig(msg)) -> weft_lustre.Element(msg) {
  case config {
    SpinnerConfig(label:, attrs: attrs, ..) -> {
      let aria_attrs = [
        weft_lustre.html_attribute(attribute.attribute("role", "status")),
        weft_lustre.html_attribute(attribute.attribute("aria-label", label)),
      ]

      weft_lustre.element_tag(
        tag: "div",
        base_weft_attrs: [weft.el_layout()],
        attrs: list.append(aria_attrs, attrs),
        children: [],
      )
    }
  }
}
