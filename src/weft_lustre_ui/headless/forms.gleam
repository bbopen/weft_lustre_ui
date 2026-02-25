//// Canonical headless form primitives and composition helpers.
////
//// This module owns the headless form container surface and field+control
//// helpers. `headless/form` is kept as a compatibility facade.

import gleam/list
import weft
import weft_lustre
import weft_lustre_ui/headless/field
import weft_lustre_ui/headless/input

/// Form container configuration.
pub opaque type FormConfig(msg) {
  FormConfig(attrs: List(weft_lustre.Attribute(msg)))
}

/// A field configuration alias for form helpers.
pub type FieldConfig(msg) =
  field.FieldConfig(msg)

/// Construct a default form container configuration.
pub fn form_config() -> FormConfig(msg) {
  FormConfig(attrs: [])
}

/// Append root attributes.
pub fn form_attrs(
  config config: FormConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> FormConfig(msg) {
  case config {
    FormConfig(attrs: existing) ->
      FormConfig(attrs: list.append(existing, attrs))
  }
}

/// Render a semantic `<form>` container.
pub fn form(
  config config: FormConfig(msg),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  case config {
    FormConfig(attrs: attrs) ->
      weft_lustre.element_tag(
        tag: "form",
        base_weft_attrs: [weft.column_layout()],
        attrs: attrs,
        children: children,
      )
  }
}

/// Compose a `field` with a `text_input`, ensuring required control attributes
/// are applied.
pub fn field_text_input(
  field_config field_config: FieldConfig(msg),
  input_config input_config: input.TextInputConfig(msg),
) -> weft_lustre.Element(msg) {
  field.field(config: field_config, control: fn(attrs) {
    input.text_input(config: input_config |> input.text_input_attrs(attrs))
  })
}

/// Compose a `field` with a `textarea`, ensuring required control attributes are
/// applied.
pub fn field_textarea(
  field_config field_config: FieldConfig(msg),
  textarea_config textarea_config: input.TextareaConfig(msg),
) -> weft_lustre.Element(msg) {
  field.field(config: field_config, control: fn(attrs) {
    input.textarea(config: textarea_config |> input.textarea_attrs(attrs))
  })
}

/// Compose a `field` with a `select`, ensuring required control attributes are
/// applied.
pub fn field_select(
  field_config field_config: FieldConfig(msg),
  select_config select_config: input.SelectConfig(msg),
) -> weft_lustre.Element(msg) {
  field.field(config: field_config, control: fn(attrs) {
    input.select(config: select_config |> input.select_attrs(attrs))
  })
}
