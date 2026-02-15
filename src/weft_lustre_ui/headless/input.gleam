//// Headless (unstyled) form controls for weft_lustre_ui.
////
//// These components render native form controls (`input`, `textarea`, `select`)
//// and keep SSR behavior correct (for example textarea values are rendered as
//// text content, and the selected option is marked for SSR).
////
//// Visual styling is the responsibility of the caller (or the styled wrappers
//// in `weft_lustre_ui/input`).

import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute
import lustre/event
import weft
import weft_lustre

/// Mark a form control as required.
pub fn input_required() -> weft_lustre.Attribute(msg) {
  weft_lustre.html_attribute(attribute.required(True))
}

/// Attach a `name` attribute to a form control.
pub fn input_name(value value: String) -> weft_lustre.Attribute(msg) {
  weft_lustre.html_attribute(attribute.name(value))
}

/// Attach an `autocomplete` hint to a form control.
pub fn input_autocomplete(value value: String) -> weft_lustre.Attribute(msg) {
  weft_lustre.html_attribute(attribute.autocomplete(value))
}

/// Attach an `inputmode` hint to a form control.
pub fn input_inputmode(value value: String) -> weft_lustre.Attribute(msg) {
  weft_lustre.html_attribute(attribute.inputmode(value))
}

/// Enable spellchecking for a form control.
pub fn input_spellcheck_enabled() -> weft_lustre.Attribute(msg) {
  weft_lustre.html_attribute(attribute.spellcheck(True))
}

/// Disable spellchecking for a form control.
pub fn input_spellcheck_disabled() -> weft_lustre.Attribute(msg) {
  weft_lustre.html_attribute(attribute.spellcheck(False))
}

/// Focus a form control on initial page load (SSR) and when toggled true
/// (client).
pub fn input_autofocus() -> weft_lustre.Attribute(msg) {
  weft_lustre.html_attribute(attribute.autofocus(True))
}

type Kind {
  Text
  Email
  Password
  Search
  Url
  Tel
  Number
}

/// An `<input>` type for `text_input`.
pub opaque type TextInputType {
  TextInputType(value: Kind)
}

/// Input type `"text"`.
pub fn input_type_text() -> TextInputType {
  TextInputType(value: Text)
}

/// Input type `"email"`.
pub fn input_type_email() -> TextInputType {
  TextInputType(value: Email)
}

/// Input type `"password"`.
pub fn input_type_password() -> TextInputType {
  TextInputType(value: Password)
}

/// Input type `"search"`.
pub fn input_type_search() -> TextInputType {
  TextInputType(value: Search)
}

/// Input type `"url"`.
pub fn input_type_url() -> TextInputType {
  TextInputType(value: Url)
}

/// Input type `"tel"`.
pub fn input_type_tel() -> TextInputType {
  TextInputType(value: Tel)
}

/// Input type `"number"`.
pub fn input_type_number() -> TextInputType {
  TextInputType(value: Number)
}

fn kind_value(kind: Kind) -> String {
  case kind {
    Text -> "text"
    Email -> "email"
    Password -> "password"
    Search -> "search"
    Url -> "url"
    Tel -> "tel"
    Number -> "number"
  }
}

fn input_type_value(value: TextInputType) -> String {
  case value {
    TextInputType(value:) -> kind_value(value)
  }
}

/// Configuration for a controlled text input.
pub opaque type TextInputConfig(msg) {
  TextInputConfig(
    value: String,
    on_input: fn(String) -> msg,
    input_type: TextInputType,
    placeholder: Option(String),
    disabled: Bool,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default text input config.
pub fn text_input_config(
  value value: String,
  on_input on_input: fn(String) -> msg,
) -> TextInputConfig(msg) {
  TextInputConfig(
    value: value,
    on_input: on_input,
    input_type: input_type_text(),
    placeholder: None,
    disabled: False,
    attrs: [],
  )
}

/// Set the `<input type="...">` value.
pub fn text_input_type(
  config config: TextInputConfig(msg),
  input_type input_type: TextInputType,
) -> TextInputConfig(msg) {
  TextInputConfig(..config, input_type: input_type)
}

/// Set an optional placeholder string.
pub fn text_input_placeholder(
  config config: TextInputConfig(msg),
  value value: String,
) -> TextInputConfig(msg) {
  TextInputConfig(..config, placeholder: Some(value))
}

/// Disable the input.
pub fn text_input_disabled(
  config config: TextInputConfig(msg),
) -> TextInputConfig(msg) {
  TextInputConfig(..config, disabled: True)
}

/// Append additional weft_lustre attributes to the input.
///
/// Attributes are appended, so later attributes can override earlier ones.
pub fn text_input_attrs(
  config config: TextInputConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> TextInputConfig(msg) {
  case config {
    TextInputConfig(attrs: existing, ..) ->
      TextInputConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Render a controlled text input.
pub fn text_input(
  config config: TextInputConfig(msg),
) -> weft_lustre.Element(msg) {
  case config {
    TextInputConfig(
      value: value,
      on_input: on_input,
      input_type: input_type,
      placeholder: placeholder,
      disabled: disabled,
      attrs: attrs,
    ) -> {
      let required_html_attrs =
        list.flatten([
          [
            weft_lustre.html_attribute(
              attribute.type_(input_type_value(input_type)),
            ),
          ],
          [weft_lustre.html_attribute(attribute.value(value))],
          [weft_lustre.html_attribute(event.on_input(on_input))],
          case placeholder {
            None -> []
            Some(p) -> [weft_lustre.html_attribute(attribute.placeholder(p))]
          },
          case disabled {
            True -> [weft_lustre.html_attribute(attribute.disabled(True))]
            False -> []
          },
        ])

      weft_lustre.element_tag(
        tag: "input",
        base_weft_attrs: [weft.el_layout()],
        attrs: list.append(attrs, required_html_attrs),
        children: [],
      )
    }
  }
}

/// Configuration for a controlled textarea.
pub opaque type TextareaConfig(msg) {
  TextareaConfig(
    value: String,
    on_input: fn(String) -> msg,
    placeholder: Option(String),
    rows: Option(Int),
    disabled: Bool,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default textarea config.
pub fn textarea_config(
  value value: String,
  on_input on_input: fn(String) -> msg,
) -> TextareaConfig(msg) {
  TextareaConfig(
    value: value,
    on_input: on_input,
    placeholder: None,
    rows: None,
    disabled: False,
    attrs: [],
  )
}

/// Set an optional placeholder string.
pub fn textarea_placeholder(
  config config: TextareaConfig(msg),
  value value: String,
) -> TextareaConfig(msg) {
  TextareaConfig(..config, placeholder: Some(value))
}

/// Set the textarea `rows` attribute.
pub fn textarea_rows(
  config config: TextareaConfig(msg),
  rows rows: Int,
) -> TextareaConfig(msg) {
  TextareaConfig(..config, rows: Some(rows))
}

/// Disable the textarea.
pub fn textarea_disabled(
  config config: TextareaConfig(msg),
) -> TextareaConfig(msg) {
  TextareaConfig(..config, disabled: True)
}

/// Append additional weft_lustre attributes to the textarea.
///
/// Attributes are appended, so later attributes can override earlier ones.
pub fn textarea_attrs(
  config config: TextareaConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> TextareaConfig(msg) {
  case config {
    TextareaConfig(attrs: existing, ..) ->
      TextareaConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Render a controlled textarea.
pub fn textarea(config config: TextareaConfig(msg)) -> weft_lustre.Element(msg) {
  case config {
    TextareaConfig(
      value: value,
      on_input: on_input,
      placeholder: placeholder,
      rows: rows,
      disabled: disabled,
      attrs: attrs,
    ) -> {
      let required_html_attrs =
        list.flatten([
          // Ensure controlled updates work on the client.
          [weft_lustre.html_attribute(attribute.value(value))],
          [weft_lustre.html_attribute(event.on_input(on_input))],
          case placeholder {
            None -> []
            Some(p) -> [weft_lustre.html_attribute(attribute.placeholder(p))]
          },
          case rows {
            None -> []
            Some(r) -> [weft_lustre.html_attribute(attribute.rows(r))]
          },
          case disabled {
            True -> [weft_lustre.html_attribute(attribute.disabled(True))]
            False -> []
          },
        ])

      // For SSR, the textarea value must be rendered as text content.
      let content = weft_lustre.text(content: value)

      weft_lustre.element_tag(
        tag: "textarea",
        base_weft_attrs: [weft.el_layout()],
        attrs: list.append(attrs, required_html_attrs),
        children: [content],
      )
    }
  }
}

/// A select option for the `select` component.
pub opaque type SelectOption {
  SelectOption(value: String, label: String, disabled: Bool)
}

/// Construct a select option.
pub fn select_option(value value: String, label label: String) -> SelectOption {
  SelectOption(value: value, label: label, disabled: False)
}

/// Disable a select option.
pub fn select_option_disabled(option option: SelectOption) -> SelectOption {
  SelectOption(..option, disabled: True)
}

fn option_value(option: SelectOption) -> String {
  case option {
    SelectOption(value:, ..) -> value
  }
}

fn option_label(option: SelectOption) -> String {
  case option {
    SelectOption(label:, ..) -> label
  }
}

fn option_disabled(option: SelectOption) -> Bool {
  case option {
    SelectOption(disabled:, ..) -> disabled
  }
}

/// Configuration for a controlled select.
pub opaque type SelectConfig(msg) {
  SelectConfig(
    value: String,
    on_change: fn(String) -> msg,
    options: List(SelectOption),
    disabled: Bool,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default select config.
pub fn select_config(
  value value: String,
  on_change on_change: fn(String) -> msg,
  options options: List(SelectOption),
) -> SelectConfig(msg) {
  SelectConfig(
    value: value,
    on_change: on_change,
    options: options,
    disabled: False,
    attrs: [],
  )
}

/// Disable the select.
pub fn select_disabled(config config: SelectConfig(msg)) -> SelectConfig(msg) {
  SelectConfig(..config, disabled: True)
}

/// Append additional weft_lustre attributes to the select.
///
/// Attributes are appended, so later attributes can override earlier ones.
pub fn select_attrs(
  config config: SelectConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> SelectConfig(msg) {
  case config {
    SelectConfig(attrs: existing, ..) ->
      SelectConfig(..config, attrs: list.append(existing, attrs))
  }
}

fn option_node(
  option: SelectOption,
  selected_value: String,
) -> weft_lustre.Element(msg) {
  let value = option_value(option)

  let attrs =
    list.flatten([
      [weft_lustre.html_attribute(attribute.value(value))],
      // For SSR, mark the matching option as selected.
      case value == selected_value {
        True -> [weft_lustre.html_attribute(attribute.selected(True))]
        False -> []
      },
      case option_disabled(option) {
        True -> [weft_lustre.html_attribute(attribute.disabled(True))]
        False -> []
      },
    ])

  weft_lustre.element_tag(
    tag: "option",
    base_weft_attrs: [],
    attrs: attrs,
    children: [weft_lustre.text(content: option_label(option))],
  )
}

/// Render a controlled select.
pub fn select(config config: SelectConfig(msg)) -> weft_lustre.Element(msg) {
  case config {
    SelectConfig(value:, on_change:, options:, disabled:, attrs:) -> {
      let required_html_attrs =
        list.flatten([
          // Ensure controlled updates work on the client.
          [weft_lustre.html_attribute(attribute.value(value))],
          [weft_lustre.html_attribute(event.on_change(on_change))],
          case disabled {
            True -> [weft_lustre.html_attribute(attribute.disabled(True))]
            False -> []
          },
        ])

      let children = list.map(options, option_node(_, value))

      weft_lustre.element_tag(
        tag: "select",
        base_weft_attrs: [weft.el_layout()],
        attrs: list.append(attrs, required_html_attrs),
        children: children,
      )
    }
  }
}
