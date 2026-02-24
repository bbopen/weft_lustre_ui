//// Canonical themed form primitives and composition helpers.
////
//// This module owns the styled form container and field+control helper APIs.
//// `weft_lustre_ui/form` is kept as a compatibility facade.

import weft
import weft_lustre
import weft_lustre_ui/field
import weft_lustre_ui/headless/forms as headless_forms
import weft_lustre_ui/input
import weft_lustre_ui/theme

/// Styled form container configuration alias.
pub type FormConfig(msg) =
  headless_forms.FormConfig(msg)

/// Styled field configuration alias.
pub type FieldConfig(msg) =
  field.FieldConfig(msg)

/// Construct a default form container configuration.
pub fn form_config(theme _theme: theme.Theme) -> FormConfig(msg) {
  headless_forms.form_config()
}

/// Append root attributes.
pub fn form_attrs(
  theme _theme: theme.Theme,
  config config: FormConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> FormConfig(msg) {
  headless_forms.form_attrs(config: config, attrs: attrs)
}

fn form_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  [
    weft.spacing(pixels: theme.space_md(theme)),
    weft.font_family(families: theme.font_families(theme)),
    weft.width(length: weft.fill()),
  ]
}

/// Render a styled form container.
pub fn form(
  theme theme: theme.Theme,
  config config: FormConfig(msg),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  headless_forms.form(
    config: config
      |> headless_forms.form_attrs(attrs: [
        weft_lustre.styles(form_styles(theme: theme)),
      ]),
    children: children,
  )
}

/// Render a field-wrapped controlled text input.
pub fn field_text_input(
  theme theme: theme.Theme,
  field_config field_config: FieldConfig(msg),
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
  field_config field_config: FieldConfig(msg),
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
  field_config field_config: FieldConfig(msg),
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
