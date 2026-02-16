//// Headless (unstyled) label component for weft_lustre_ui.
////
//// This module renders a native `<label>` and preserves HTML `for` wiring when
//// requested. It intentionally applies no theme-level visual styling.

import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute
import weft
import weft_lustre

/// Headless label configuration.
pub opaque type LabelConfig(msg) {
  LabelConfig(html_for: Option(String), attrs: List(weft_lustre.Attribute(msg)))
}

/// Construct a default label configuration.
pub fn label_config() -> LabelConfig(msg) {
  LabelConfig(html_for: None, attrs: [])
}

/// Set the control id referenced by `for`.
pub fn label_for(
  config config: LabelConfig(msg),
  html_for html_for: String,
) -> LabelConfig(msg) {
  LabelConfig(..config, html_for: Some(html_for))
}

/// Append additional attributes to the label wrapper.
pub fn label_attrs(
  config config: LabelConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> LabelConfig(msg) {
  case config {
    LabelConfig(html_for: html_for, attrs: existing) ->
      LabelConfig(html_for: html_for, attrs: list.append(existing, attrs))
  }
}

/// Render a native `<label>`.
pub fn label(
  config config: LabelConfig(msg),
  child child: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  case config {
    LabelConfig(html_for: html_for, attrs: attrs) -> {
      let required_html_attrs = case html_for {
        None -> []
        Some(value) -> [weft_lustre.html_attribute(attribute.for(value))]
      }

      weft_lustre.element_tag(
        tag: "label",
        base_weft_attrs: [weft.el_layout()],
        attrs: list.append(required_html_attrs, attrs),
        children: [child],
      )
    }
  }
}
