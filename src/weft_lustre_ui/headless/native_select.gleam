//// Headless (unstyled) native select component for weft_lustre_ui.
////
//// Renders a native `<select>` element with `<option>` children.
//// Visual appearance is not applied here; the styled wrapper handles
//// input-like borders, padding, and chevron indicator.

import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute
import lustre/event
import weft
import weft_lustre

/// A native select option.
pub opaque type NativeSelectOption {
  NativeSelectOption(value: String, label: String, disabled: Bool)
}

/// Construct a native select option.
pub fn native_select_option(
  value value: String,
  label label: String,
) -> NativeSelectOption {
  NativeSelectOption(value: value, label: label, disabled: False)
}

/// Mark a native select option as disabled.
pub fn native_select_option_disabled(
  option option: NativeSelectOption,
) -> NativeSelectOption {
  NativeSelectOption(..option, disabled: True)
}

/// Headless native select configuration.
pub opaque type NativeSelectConfig(msg) {
  NativeSelectConfig(
    options: List(NativeSelectOption),
    value: Option(String),
    on_change: fn(String) -> msg,
    disabled: Bool,
    placeholder: Option(String),
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a native select configuration.
pub fn native_select_config(
  options options: List(NativeSelectOption),
  value value: Option(String),
  on_change on_change: fn(String) -> msg,
) -> NativeSelectConfig(msg) {
  NativeSelectConfig(
    options: options,
    value: value,
    on_change: on_change,
    disabled: False,
    placeholder: None,
    attrs: [],
  )
}

/// Set a placeholder option for the native select.
pub fn native_select_placeholder(
  config config: NativeSelectConfig(msg),
  placeholder placeholder: String,
) -> NativeSelectConfig(msg) {
  NativeSelectConfig(..config, placeholder: Some(placeholder))
}

/// Disable the native select.
pub fn native_select_disabled(
  config config: NativeSelectConfig(msg),
) -> NativeSelectConfig(msg) {
  NativeSelectConfig(..config, disabled: True)
}

/// Append additional attributes to the native select.
pub fn native_select_attrs(
  config config: NativeSelectConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> NativeSelectConfig(msg) {
  case config {
    NativeSelectConfig(attrs: existing, ..) ->
      NativeSelectConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Internal: read the options from a native select config.
@internal
pub fn native_select_config_options(
  config config: NativeSelectConfig(msg),
) -> List(NativeSelectOption) {
  case config {
    NativeSelectConfig(options:, ..) -> options
  }
}

/// Internal: read the value from a native select config.
@internal
pub fn native_select_config_value(
  config config: NativeSelectConfig(msg),
) -> Option(String) {
  case config {
    NativeSelectConfig(value:, ..) -> value
  }
}

/// Internal: read the disabled state from a native select config.
@internal
pub fn native_select_config_disabled(
  config config: NativeSelectConfig(msg),
) -> Bool {
  case config {
    NativeSelectConfig(disabled:, ..) -> disabled
  }
}

/// Internal: read the placeholder from a native select config.
@internal
pub fn native_select_config_placeholder(
  config config: NativeSelectConfig(msg),
) -> Option(String) {
  case config {
    NativeSelectConfig(placeholder:, ..) -> placeholder
  }
}

/// Internal: read the attrs from a native select config.
@internal
pub fn native_select_config_attrs(
  config config: NativeSelectConfig(msg),
) -> List(weft_lustre.Attribute(msg)) {
  case config {
    NativeSelectConfig(attrs:, ..) -> attrs
  }
}

fn render_option(
  opt: NativeSelectOption,
  selected_value: Option(String),
) -> weft_lustre.Element(msg) {
  case opt {
    NativeSelectOption(value: value, label: label, disabled: is_disabled) -> {
      let is_selected = case selected_value {
        Some(sel) -> sel == value
        None -> False
      }

      let option_attrs =
        list.flatten([
          [
            weft_lustre.html_attribute(attribute.value(value)),
          ],
          case is_selected {
            True -> [
              weft_lustre.html_attribute(attribute.selected(True)),
            ]
            False -> []
          },
          case is_disabled {
            True -> [
              weft_lustre.html_attribute(attribute.disabled(True)),
            ]
            False -> []
          },
        ])

      weft_lustre.element_tag(
        tag: "option",
        base_weft_attrs: [],
        attrs: option_attrs,
        children: [weft_lustre.text(content: label)],
      )
    }
  }
}

/// Render an unstyled native `<select>` element.
pub fn native_select(
  config config: NativeSelectConfig(msg),
) -> weft_lustre.Element(msg) {
  case config {
    NativeSelectConfig(
      options:,
      value:,
      on_change:,
      disabled:,
      placeholder:,
      attrs:,
    ) -> {
      let placeholder_option = case placeholder {
        Some(text) -> [
          weft_lustre.element_tag(
            tag: "option",
            base_weft_attrs: [],
            attrs: [
              weft_lustre.html_attribute(attribute.value("")),
              weft_lustre.html_attribute(attribute.disabled(True)),
              case value {
                None -> weft_lustre.html_attribute(attribute.selected(True))
                Some(_) ->
                  weft_lustre.html_attribute(attribute.attribute(
                    "data-placeholder",
                    "true",
                  ))
              },
            ],
            children: [weft_lustre.text(content: text)],
          ),
        ]
        None -> []
      }

      let option_elements =
        list.map(options, fn(opt) { render_option(opt, value) })

      let select_attrs =
        list.flatten([
          case disabled {
            True -> [weft_lustre.html_attribute(attribute.disabled(True))]
            False -> [
              weft_lustre.html_attribute(event.on_input(fn(v) { on_change(v) })),
            ]
          },
          attrs,
        ])

      weft_lustre.element_tag(
        tag: "select",
        base_weft_attrs: [weft.el_layout()],
        attrs: select_attrs,
        children: list.append(placeholder_option, option_elements),
      )
    }
  }
}
