//// Styled compatibility facade for shadcn-style `form` module naming.
////
//// Canonical form APIs live in `weft_lustre_ui/forms`.

import weft_lustre
import weft_lustre_ui/forms as styled_forms
import weft_lustre_ui/input
import weft_lustre_ui/theme

/// Styled form container configuration alias.
pub type FormConfig(msg) =
  styled_forms.FormConfig(msg)

/// Styled field configuration alias.
pub type FieldConfig(msg) =
  styled_forms.FieldConfig(msg)

/// Construct a default form container configuration.
pub fn form_config(theme theme: theme.Theme) -> FormConfig(msg) {
  styled_forms.form_config(theme: theme)
}

/// Append root attributes.
pub fn form_attrs(
  theme theme: theme.Theme,
  config config: FormConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> FormConfig(msg) {
  styled_forms.form_attrs(theme: theme, config: config, attrs: attrs)
}

/// Render a styled form container.
pub fn form(
  theme theme: theme.Theme,
  config config: FormConfig(msg),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  styled_forms.form(theme: theme, config: config, children: children)
}

/// Render a field-wrapped controlled text input.
pub fn field_text_input(
  theme theme: theme.Theme,
  field_config field_config: FieldConfig(msg),
  input_config input_config: input.TextInputConfig(msg),
) -> weft_lustre.Element(msg) {
  styled_forms.field_text_input(
    theme: theme,
    field_config: field_config,
    input_config: input_config,
  )
}

/// Render a field-wrapped controlled textarea.
pub fn field_textarea(
  theme theme: theme.Theme,
  field_config field_config: FieldConfig(msg),
  textarea_config textarea_config: input.TextareaConfig(msg),
) -> weft_lustre.Element(msg) {
  styled_forms.field_textarea(
    theme: theme,
    field_config: field_config,
    textarea_config: textarea_config,
  )
}

/// Render a field-wrapped controlled select.
pub fn field_select(
  theme theme: theme.Theme,
  field_config field_config: FieldConfig(msg),
  select_config select_config: input.SelectConfig(msg),
) -> weft_lustre.Element(msg) {
  styled_forms.field_select(
    theme: theme,
    field_config: field_config,
    select_config: select_config,
  )
}
