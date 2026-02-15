//// Headless (unstyled) button component for weft_lustre_ui.
////
//// This module renders a native `<button type="button">` and wires up:
//// - disabled behavior (HTML `disabled` attribute, click handler removed)
//// - user-provided attributes and children
////
//// Visual styling is the responsibility of the caller (or the styled wrapper
//// in `weft_lustre_ui/button`).

import gleam/list
import lustre/attribute
import lustre/event
import weft
import weft_lustre

/// Headless button configuration.
pub opaque type ButtonConfig(msg) {
  ButtonConfig(
    on_press: msg,
    disabled: Bool,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default headless button config.
pub fn button_config(on_press on_press: msg) -> ButtonConfig(msg) {
  ButtonConfig(on_press: on_press, disabled: False, attrs: [])
}

/// Disable the button.
pub fn button_disabled(config config: ButtonConfig(msg)) -> ButtonConfig(msg) {
  ButtonConfig(..config, disabled: True)
}

/// Append additional attributes to the button.
///
/// Attributes are appended, so later attributes can override earlier ones.
pub fn button_attrs(
  config config: ButtonConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ButtonConfig(msg) {
  case config {
    ButtonConfig(attrs: existing, ..) ->
      ButtonConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Render a headless button.
pub fn button(
  config config: ButtonConfig(msg),
  child child: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  case config {
    ButtonConfig(on_press: on_press, disabled: disabled, attrs: attrs) -> {
      let required_html_attrs =
        list.flatten([
          [weft_lustre.html_attribute(attribute.type_("button"))],
          case disabled {
            True -> [weft_lustre.html_attribute(attribute.disabled(True))]
            False -> []
          },
          case disabled {
            True -> []
            False -> [weft_lustre.html_attribute(event.on_click(on_press))]
          },
        ])

      weft_lustre.element_tag(
        tag: "button",
        base_weft_attrs: [weft.el_layout()],
        attrs: list.append(attrs, required_html_attrs),
        children: [child],
      )
    }
  }
}
