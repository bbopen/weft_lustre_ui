//// Styled textarea component adapter for shadcn compatibility.
////
//// This module intentionally re-exports textarea helpers from `input`
//// so users can import a dedicated `textarea` module.

import weft_lustre
import weft_lustre_ui/input
import weft_lustre_ui/theme

/// Styled textarea configuration alias.
pub type TextareaConfig(msg) =
  input.TextareaConfig(msg)

/// Construct a default textarea config.
pub fn textarea_config(
  theme _theme: theme.Theme,
  value value: String,
  on_input on_input: fn(String) -> msg,
) -> TextareaConfig(msg) {
  input.textarea_config(value: value, on_input: on_input)
}

/// Set an optional placeholder string.
pub fn textarea_placeholder(
  theme _theme: theme.Theme,
  config config: TextareaConfig(msg),
  value value: String,
) -> TextareaConfig(msg) {
  input.textarea_placeholder(config: config, value: value)
}

/// Set the textarea `rows` attribute.
pub fn textarea_rows(
  theme _theme: theme.Theme,
  config config: TextareaConfig(msg),
  rows rows: Int,
) -> TextareaConfig(msg) {
  input.textarea_rows(config: config, rows: rows)
}

/// Disable the textarea.
pub fn textarea_disabled(
  theme _theme: theme.Theme,
  config config: TextareaConfig(msg),
) -> TextareaConfig(msg) {
  input.textarea_disabled(config: config)
}

/// Append additional weft_lustre attributes to the textarea.
pub fn textarea_attrs(
  theme _theme: theme.Theme,
  config config: TextareaConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> TextareaConfig(msg) {
  input.textarea_attrs(config: config, attrs: attrs)
}

/// Render a styled controlled textarea.
pub fn textarea(
  theme theme: theme.Theme,
  config config: TextareaConfig(msg),
) -> weft_lustre.Element(msg) {
  input.textarea(theme: theme, config: config)
}
