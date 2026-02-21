//// Styled, theme-driven spinner component for weft_lustre_ui.
////
//// Renders a loading indicator with theme-driven primary color and correct
//// ARIA status semantics. The spinner displays as a circular element sized
//// according to the chosen size token.
////
//// Note: CSS keyframe animations are not yet available in the weft primitive
//// model. Consumers can add a spin animation via `weft_lustre.html_attribute`
//// if needed for their target environment.

import gleam/list
import lustre/attribute
import weft
import weft_lustre
import weft_lustre_ui/headless/spinner as headless_spinner
import weft_lustre_ui/theme

/// Styled spinner configuration alias.
pub type SpinnerConfig(msg) =
  headless_spinner.SpinnerConfig(msg)

/// Styled spinner size alias.
pub type SpinnerSize =
  headless_spinner.SpinnerSize

/// Small spinner size.
pub fn spinner_small() -> SpinnerSize {
  headless_spinner.spinner_small()
}

/// Medium spinner size (default).
pub fn spinner_medium() -> SpinnerSize {
  headless_spinner.spinner_medium()
}

/// Large spinner size.
pub fn spinner_large() -> SpinnerSize {
  headless_spinner.spinner_large()
}

/// Construct a default spinner configuration.
pub fn spinner_config() -> SpinnerConfig(msg) {
  headless_spinner.spinner_config()
}

/// Set the spinner size.
pub fn spinner_size(
  config config: SpinnerConfig(msg),
  size size: SpinnerSize,
) -> SpinnerConfig(msg) {
  headless_spinner.spinner_size(config: config, size: size)
}

/// Set the accessible label for the spinner.
pub fn spinner_label(
  config config: SpinnerConfig(msg),
  label label: String,
) -> SpinnerConfig(msg) {
  headless_spinner.spinner_label(config: config, label: label)
}

/// Append additional attributes to the spinner.
pub fn spinner_attrs(
  config config: SpinnerConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> SpinnerConfig(msg) {
  headless_spinner.spinner_attrs(config: config, attrs: attrs)
}

fn spinner_styles(
  theme theme: theme.Theme,
  size size: SpinnerSize,
) -> List(weft.Attribute) {
  let #(primary_bg, _) = theme.primary(theme)
  let pixels = headless_spinner.spinner_size_pixels(size: size)

  [
    weft.display(value: weft.display_inline_flex()),
    weft.align_items(value: weft.align_items_center()),
    weft.justify_content(value: weft.justify_center()),
    weft.width(length: weft.fixed(length: weft.px(pixels: pixels))),
    weft.height(length: weft.fixed(length: weft.px(pixels: pixels))),
    weft.border(
      width: weft.px(pixels: 2),
      style: weft.border_style_solid(),
      color: primary_bg,
    ),
    weft.rounded(radius: weft.px(pixels: 9999)),
  ]
}

/// Render a styled spinner.
pub fn spinner(
  theme theme: theme.Theme,
  config config: SpinnerConfig(msg),
) -> weft_lustre.Element(msg) {
  let size = headless_spinner.spinner_config_size(config: config)
  let label = headless_spinner.spinner_config_label(config: config)
  let attrs = headless_spinner.spinner_config_attrs(config: config)

  let styled_attrs = [
    weft_lustre.html_attribute(attribute.attribute("role", "status")),
    weft_lustre.html_attribute(attribute.attribute("aria-label", label)),
    weft_lustre.styles(spinner_styles(theme: theme, size: size)),
  ]

  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.el_layout()],
    attrs: list.append(styled_attrs, attrs),
    children: [],
  )
}
