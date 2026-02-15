//// Field wrapper for labeled form controls (themed).
////
//// `weft_lustre_ui/field` provides an accessible wrapper that wires up:
//// - `<label for="...">`
//// - `id="..."`
//// - `aria-describedby="..."`
//// - `aria-invalid="true"` when an error is present
////
//// The field does not render a specific control by itself. Instead it passes
//// the required attributes to a caller-provided control builder function.

import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import lustre/attribute
import weft
import weft_lustre
import weft_lustre_ui/theme

/// Configuration for an accessible field wrapper.
pub opaque type FieldConfig(msg) {
  FieldConfig(
    id: String,
    required: Bool,
    label: Option(weft_lustre.Element(msg)),
    help: Option(weft_lustre.Element(msg)),
    error: Option(weft_lustre.Element(msg)),
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default field config for the given control `id`.
pub fn field_config(id id: String) -> FieldConfig(msg) {
  FieldConfig(
    id: id,
    required: False,
    label: None,
    help: None,
    error: None,
    attrs: [],
  )
}

/// Mark the field as required.
pub fn field_required(config config: FieldConfig(msg)) -> FieldConfig(msg) {
  FieldConfig(..config, required: True)
}

/// Mark the field as optional (default).
pub fn field_optional(config config: FieldConfig(msg)) -> FieldConfig(msg) {
  FieldConfig(..config, required: False)
}

/// Set the field label node.
pub fn field_label(
  config config: FieldConfig(msg),
  label label: weft_lustre.Element(msg),
) -> FieldConfig(msg) {
  FieldConfig(..config, label: Some(label))
}

/// Set the field label as plain text.
pub fn field_label_text(
  config config: FieldConfig(msg),
  text text: String,
) -> FieldConfig(msg) {
  field_label(config: config, label: weft_lustre.text(content: text))
}

/// Set optional help text displayed below the control.
pub fn field_help(
  config config: FieldConfig(msg),
  help help: weft_lustre.Element(msg),
) -> FieldConfig(msg) {
  FieldConfig(..config, help: Some(help))
}

/// Set optional help text as plain text.
pub fn field_help_text(
  config config: FieldConfig(msg),
  text text: String,
) -> FieldConfig(msg) {
  field_help(config: config, help: weft_lustre.text(content: text))
}

/// Set optional error text displayed below the control.
pub fn field_error(
  config config: FieldConfig(msg),
  error error: weft_lustre.Element(msg),
) -> FieldConfig(msg) {
  FieldConfig(..config, error: Some(error))
}

/// Set optional error text as plain text.
pub fn field_error_text(
  config config: FieldConfig(msg),
  text text: String,
) -> FieldConfig(msg) {
  field_error(config: config, error: weft_lustre.text(content: text))
}

/// Append additional weft_lustre attributes to the field wrapper.
///
/// Attributes are appended, so later attributes can override earlier ones.
pub fn field_attrs(
  config config: FieldConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> FieldConfig(msg) {
  case config {
    FieldConfig(attrs: existing, ..) ->
      FieldConfig(..config, attrs: list.append(existing, attrs))
  }
}

fn max_int(a: Int, b: Int) -> Int {
  case a >= b {
    True -> a
    False -> b
  }
}

fn describedby_value(ids: List(String)) -> Option(String) {
  case ids {
    [] -> None
    ids -> Some(string.join(ids, with: " "))
  }
}

fn error_styles(t: theme.Theme) -> List(weft.Attribute) {
  let #(danger_bg, _) = theme.danger(t)

  [
    weft.border(
      width: weft.px(pixels: 1),
      style: weft.border_style_solid(),
      color: danger_bg,
    ),
    weft.focus_visible(attrs: [
      weft.outline(width: weft.px(pixels: 2), color: danger_bg),
      weft.outline_offset(length: weft.px(pixels: 2)),
    ]),
    // Match the theme even when showing errors (font is inherited).
    weft.font_family(families: theme.font_families(t)),
  ]
}

fn label_styles(t: theme.Theme) -> List(weft.Attribute) {
  let #(_, surface_fg) = theme.surface(t)

  [
    weft.font_family(families: theme.font_families(t)),
    weft.font_weight(weight: weft.font_weight_value(weight: 500)),
    weft.font_size(size: weft.rem(rem: 0.875)),
    weft.line_height(height: weft.line_height_multiple(multiplier: 1.2)),
    weft.text_color(color: surface_fg),
  ]
}

fn help_styles(t: theme.Theme) -> List(weft.Attribute) {
  [
    weft.font_family(families: theme.font_families(t)),
    weft.font_size(size: weft.rem(rem: 0.8125)),
    weft.line_height(height: weft.line_height_multiple(multiplier: 1.25)),
    weft.text_color(color: theme.muted_text(t)),
  ]
}

fn error_text_styles(t: theme.Theme) -> List(weft.Attribute) {
  let #(danger_bg, _) = theme.danger(t)

  [
    weft.font_family(families: theme.font_families(t)),
    weft.font_size(size: weft.rem(rem: 0.8125)),
    weft.line_height(height: weft.line_height_multiple(multiplier: 1.25)),
    weft.font_weight(weight: weft.font_weight_value(weight: 500)),
    weft.text_color(color: danger_bg),
  ]
}

/// Render a labeled field wrapper.
///
/// The `control` callback receives required control attributes such as `id`,
/// `aria-describedby`, and `aria-invalid` when an error exists. The callback
/// must apply these attributes to the rendered control element.
pub fn field(
  theme theme: theme.Theme,
  config config: FieldConfig(msg),
  control control: fn(List(weft_lustre.Attribute(msg))) ->
    weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  case config {
    FieldConfig(id:, required:, label:, help:, error:, attrs:) -> {
      let help_id = id <> "--help"
      let error_id = id <> "--error"

      let described_ids =
        list.flatten([
          case help {
            None -> []
            Some(_) -> [help_id]
          },
          case error {
            None -> []
            Some(_) -> [error_id]
          },
        ])

      let describedby_attr = case describedby_value(described_ids) {
        None -> []
        Some(value) -> [attribute.aria_describedby(value)]
      }

      let invalid_attr = case error {
        None -> []
        Some(_) -> [attribute.aria_invalid("true")]
      }

      let required_attr = case required {
        True -> [
          attribute.required(True),
          attribute.aria_required(True),
        ]
        False -> []
      }

      let control_html_attrs =
        [attribute.id(id), ..describedby_attr]
        |> list.append(invalid_attr)
        |> list.append(required_attr)

      let control_attrs =
        list.map(control_html_attrs, weft_lustre.html_attribute)
        |> list.append(case error {
          None -> []
          Some(_) -> [weft_lustre.styles(error_styles(theme))]
        })

      let control_node = control(control_attrs)

      let label_node = case label {
        None -> []
        Some(label) -> [
          weft_lustre.element_tag(
            tag: "label",
            base_weft_attrs: [weft.el_layout()],
            attrs: [
              weft_lustre.styles(label_styles(theme)),
              weft_lustre.html_attribute(attribute.for(id)),
            ],
            children: [label],
          ),
        ]
      }

      let help_node = case help {
        None -> []
        Some(help) -> [
          weft_lustre.element_tag(
            tag: "div",
            base_weft_attrs: [weft.el_layout()],
            attrs: [
              weft_lustre.styles(help_styles(theme)),
              weft_lustre.html_attribute(attribute.id(help_id)),
            ],
            children: [help],
          ),
        ]
      }

      let error_node = case error {
        None -> []
        Some(error) -> [
          weft_lustre.element_tag(
            tag: "div",
            base_weft_attrs: [weft.el_layout()],
            attrs: [
              weft_lustre.styles(error_text_styles(theme)),
              weft_lustre.html_attribute(attribute.id(error_id)),
              weft_lustre.html_attribute(attribute.role("alert")),
            ],
            children: [error],
          ),
        ]
      }

      let gap = max_int(6, theme.space_md(theme) - 6)

      weft_lustre.column(
        attrs: [
          weft_lustre.styles([
            weft.spacing(pixels: gap),
            weft.align_items(value: weft.align_items_stretch()),
          ]),
          ..attrs
        ],
        children: list.flatten([
          label_node,
          [control_node],
          help_node,
          error_node,
        ]),
      )
    }
  }
}
