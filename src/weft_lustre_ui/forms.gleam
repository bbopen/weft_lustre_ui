//// Ergonomic form composition helpers (themed).
////
//// These helpers compose `weft_lustre_ui/field` with the concrete form controls
//// in `weft_lustre_ui/input`, ensuring required wiring (id, describedby,
//// invalid/required state) is applied correctly.

import weft_lustre
import weft_lustre_ui/field
import weft_lustre_ui/input
import weft_lustre_ui/theme

/// Render a field-wrapped controlled text input.
pub fn field_text_input(
  theme theme: theme.Theme,
  field_config field_config: field.FieldConfig(msg),
  input_config input_config: input.TextInputConfig(msg),
) -> weft_lustre.Element(msg) {
  field.field(theme: theme, config: field_config, control: fn(attrs) {
    input.text_input(
      theme: theme,
      config: input_config
        |> input.text_input_attrs(attrs),
    )
  })
}

/// Render a field-wrapped controlled textarea.
pub fn field_textarea(
  theme theme: theme.Theme,
  field_config field_config: field.FieldConfig(msg),
  textarea_config textarea_config: input.TextareaConfig(msg),
) -> weft_lustre.Element(msg) {
  field.field(theme: theme, config: field_config, control: fn(attrs) {
    input.textarea(
      theme: theme,
      config: textarea_config
        |> input.textarea_attrs(attrs),
    )
  })
}

/// Render a field-wrapped controlled select.
pub fn field_select(
  theme theme: theme.Theme,
  field_config field_config: field.FieldConfig(msg),
  select_config select_config: input.SelectConfig(msg),
) -> weft_lustre.Element(msg) {
  field.field(theme: theme, config: field_config, control: fn(attrs) {
    input.select(
      theme: theme,
      config: select_config
        |> input.select_attrs(attrs),
    )
  })
}
