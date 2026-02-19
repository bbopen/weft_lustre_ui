//// Headless select compatibility wrappers for weft_lustre_ui.

import weft_lustre
import weft_lustre_ui/headless/input

/// Headless select option.
pub type SelectOption =
  input.SelectOption

/// Headless select configuration.
pub type SelectConfig(msg) =
  input.SelectConfig(msg)

/// Construct a select option.
pub fn select_option(value value: String, label label: String) -> SelectOption {
  input.select_option(value: value, label: label)
}

/// Disable a select option.
pub fn select_option_disabled(option option: SelectOption) -> SelectOption {
  input.select_option_disabled(option: option)
}

/// Construct select configuration.
pub fn select_config(
  value value: String,
  on_change on_change: fn(String) -> msg,
  options options: List(SelectOption),
) -> SelectConfig(msg) {
  input.select_config(value: value, on_change: on_change, options: options)
}

/// Disable select.
pub fn select_disabled(config config: SelectConfig(msg)) -> SelectConfig(msg) {
  input.select_disabled(config: config)
}

/// Append select attributes.
pub fn select_attrs(
  config config: SelectConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> SelectConfig(msg) {
  input.select_attrs(config: config, attrs: attrs)
}

/// Render headless select.
pub fn select(config config: SelectConfig(msg)) -> weft_lustre.Element(msg) {
  input.select(config: config)
}
