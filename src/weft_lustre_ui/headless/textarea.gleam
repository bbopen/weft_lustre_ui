//// Headless textarea component adapter for shadcn compatibility.
////
//// This module intentionally re-exports textarea helpers from
//// `headless/input` so users can import a dedicated `textarea` module.

import weft_lustre
import weft_lustre_ui/headless/input as headless_input

/// Headless textarea configuration alias.
pub type TextareaConfig(msg) =
  headless_input.TextareaConfig(msg)

/// Construct a default textarea config.
pub fn textarea_config(
  value value: String,
  on_input on_input: fn(String) -> msg,
) -> TextareaConfig(msg) {
  headless_input.textarea_config(value: value, on_input: on_input)
}

/// Set an optional placeholder string.
pub fn textarea_placeholder(
  config config: TextareaConfig(msg),
  value value: String,
) -> TextareaConfig(msg) {
  headless_input.textarea_placeholder(config: config, value: value)
}

/// Set the textarea `rows` attribute.
pub fn textarea_rows(
  config config: TextareaConfig(msg),
  rows rows: Int,
) -> TextareaConfig(msg) {
  headless_input.textarea_rows(config: config, rows: rows)
}

/// Disable the textarea.
pub fn textarea_disabled(
  config config: TextareaConfig(msg),
) -> TextareaConfig(msg) {
  headless_input.textarea_disabled(config: config)
}

/// Append additional weft_lustre attributes to the textarea.
pub fn textarea_attrs(
  config config: TextareaConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> TextareaConfig(msg) {
  headless_input.textarea_attrs(config: config, attrs: attrs)
}

/// Render a controlled textarea.
pub fn textarea(config config: TextareaConfig(msg)) -> weft_lustre.Element(msg) {
  headless_input.textarea(config: config)
}
