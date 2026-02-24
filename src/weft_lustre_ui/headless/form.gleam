//// Headless compatibility facade for shadcn-style `form` module naming.
////
//// Canonical form APIs live in `weft_lustre_ui/headless/forms`.

import weft_lustre
import weft_lustre_ui/headless/forms as forms_helpers
import weft_lustre_ui/headless/input

/// Form container configuration alias.
pub type FormConfig(msg) =
  forms_helpers.FormConfig(msg)

/// A field configuration alias for form helpers.
pub type FieldConfig(msg) =
  forms_helpers.FieldConfig(msg)

/// Construct a default form container configuration.
pub fn form_config() -> FormConfig(msg) {
  forms_helpers.form_config()
}

/// Append root attributes.
pub fn form_attrs(
  config config: FormConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> FormConfig(msg) {
  forms_helpers.form_attrs(config: config, attrs: attrs)
}

/// Render a semantic `<form>` container.
pub fn form(
  config config: FormConfig(msg),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  forms_helpers.form(config: config, children: children)
}

/// Render a field-wrapped controlled text input.
pub fn field_text_input(
  field_config field_config: FieldConfig(msg),
  input_config input_config: input.TextInputConfig(msg),
) -> weft_lustre.Element(msg) {
  forms_helpers.field_text_input(
    field_config: field_config,
    input_config: input_config,
  )
}

/// Render a field-wrapped controlled textarea.
pub fn field_textarea(
  field_config field_config: FieldConfig(msg),
  textarea_config textarea_config: input.TextareaConfig(msg),
) -> weft_lustre.Element(msg) {
  forms_helpers.field_textarea(
    field_config: field_config,
    textarea_config: textarea_config,
  )
}

/// Render a field-wrapped controlled select.
pub fn field_select(
  field_config field_config: FieldConfig(msg),
  select_config select_config: input.SelectConfig(msg),
) -> weft_lustre.Element(msg) {
  forms_helpers.field_select(
    field_config: field_config,
    select_config: select_config,
  )
}
