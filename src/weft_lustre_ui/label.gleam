//// Styled, theme-driven label component for weft_lustre_ui.
////
//// The styled wrapper adds typography and spacing but keeps the required `for`
//// relationship behavior from the headless label component.

import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute
import weft
import weft_lustre
import weft_lustre_ui/theme

/// Styled label configuration.
pub opaque type LabelConfig(msg) {
  LabelConfig(
    html_for: Option(String),
    disabled: Bool,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default label configuration.
pub fn label_config() -> LabelConfig(msg) {
  LabelConfig(html_for: None, disabled: False, attrs: [])
}

/// Set the `for` target id.
pub fn label_for(
  config config: LabelConfig(msg),
  html_for html_for: String,
) -> LabelConfig(msg) {
  LabelConfig(..config, html_for: Some(html_for))
}

/// Mark this label as disabled for styling purposes.
pub fn label_disabled(config config: LabelConfig(msg)) -> LabelConfig(msg) {
  LabelConfig(..config, disabled: True)
}

/// Append additional attributes to the label wrapper.
pub fn label_attrs(
  config config: LabelConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> LabelConfig(msg) {
  case config {
    LabelConfig(html_for: html_for, disabled: disabled, attrs: existing) ->
      LabelConfig(
        html_for: html_for,
        disabled: disabled,
        attrs: list.append(existing, attrs),
      )
  }
}

fn label_styles(
  theme theme: theme.Theme,
  disabled disabled: Bool,
) -> List(weft.Attribute) {
  let #(_, surface_fg) = theme.surface(theme)

  list.flatten([
    [
      weft.display(value: weft.display_inline_flex()),
      weft.align_items(value: weft.align_items_center()),
      weft.font_family(families: theme.font_families(theme)),
      weft.font_size(size: weft.rem(rem: 0.875)),
      weft.line_height(height: weft.line_height_multiple(multiplier: 1.0)),
      weft.font_weight(weight: weft.font_weight_value(weight: 500)),
      weft.text_color(color: surface_fg),
      weft.user_select(value: weft.user_select_none()),
    ],
    case disabled {
      True -> [
        weft.cursor(cursor: weft.cursor_not_allowed()),
        weft.alpha(opacity: theme.disabled_opacity(theme)),
      ]
      False -> []
    },
    [
      weft.background(color: weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.0)),
      weft.text_color(color: surface_fg),
      weft.outline_none(),
    ],
  ])
}

/// Render a themed label with a required `for` attribute when configured.
pub fn label(
  theme theme: theme.Theme,
  config config: LabelConfig(msg),
  child child: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  case config {
    LabelConfig(html_for: html_for, disabled: disabled, attrs: attrs) -> {
      let required_html_attrs = case html_for {
        None -> []
        Some(value) -> [weft_lustre.html_attribute(attribute.for(value))]
      }

      let style =
        weft_lustre.styles(label_styles(theme: theme, disabled: disabled))

      weft_lustre.element_tag(
        tag: "label",
        base_weft_attrs: [weft.el_layout()],
        attrs: [style]
          |> list.append(required_html_attrs)
          |> list.append(attrs),
        children: [child],
      )
    }
  }
}
