//// Headless form composition helpers for weft_lustre_ui.
////
//// These helpers compose headless fields with headless controls so required
//// wiring (id/ARIA/required/invalid) cannot be forgotten.

import weft_lustre
import weft_lustre_ui/headless/field
import weft_lustre_ui/headless/input

/// Compose a `field` with a `text_input`, ensuring required control attributes
/// are applied.
pub fn field_text_input(
  field_config field_config: field.FieldConfig(msg),
  input_config input_config: input.TextInputConfig(msg),
) -> weft_lustre.Element(msg) {
  field.field(config: field_config, control: fn(attrs) {
    input.text_input(
      config: input_config
      |> input.text_input_attrs(attrs),
    )
  })
}

/// Compose a `field` with a `textarea`, ensuring required control attributes are
/// applied.
pub fn field_textarea(
  field_config field_config: field.FieldConfig(msg),
  textarea_config textarea_config: input.TextareaConfig(msg),
) -> weft_lustre.Element(msg) {
  field.field(config: field_config, control: fn(attrs) {
    input.textarea(
      config: textarea_config
      |> input.textarea_attrs(attrs),
    )
  })
}

/// Compose a `field` with a `select`, ensuring required control attributes are
/// applied.
pub fn field_select(
  field_config field_config: field.FieldConfig(msg),
  select_config select_config: input.SelectConfig(msg),
) -> weft_lustre.Element(msg) {
  field.field(config: field_config, control: fn(attrs) {
    input.select(
      config: select_config
      |> input.select_attrs(attrs),
    )
  })
}
