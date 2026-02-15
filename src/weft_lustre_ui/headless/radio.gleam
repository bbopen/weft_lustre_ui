//// Headless (unstyled) radio component for weft_lustre_ui.
////
//// The radio renders a native `<input type="radio">` wrapped in a `<label>`
//// so the full label area is clickable, preserving native keyboard semantics.
////
//// Visual styling is the responsibility of the caller (or the styled wrapper
//// in `weft_lustre_ui/radio`).

import gleam/list
import lustre/attribute
import lustre/event
import weft
import weft_lustre

/// Headless radio configuration.
pub opaque type RadioConfig(msg) {
  RadioConfig(
    name: String,
    value: String,
    checked: Bool,
    on_select: fn(String) -> msg,
    disabled: Bool,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default radio config.
pub fn radio_config(
  name name: String,
  value value: String,
  checked checked: Bool,
  on_select on_select: fn(String) -> msg,
) -> RadioConfig(msg) {
  RadioConfig(
    name: name,
    value: value,
    checked: checked,
    on_select: on_select,
    disabled: False,
    attrs: [],
  )
}

/// Disable the radio.
pub fn radio_disabled(config config: RadioConfig(msg)) -> RadioConfig(msg) {
  RadioConfig(..config, disabled: True)
}

/// Append additional attributes to the radio wrapper.
///
/// Attributes are appended, so later attributes can override earlier ones.
pub fn radio_attrs(
  config config: RadioConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> RadioConfig(msg) {
  case config {
    RadioConfig(attrs: existing, ..) ->
      RadioConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Render a controlled radio.
pub fn radio(
  config config: RadioConfig(msg),
  label label: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  case config {
    RadioConfig(name:, value:, checked:, on_select:, disabled:, attrs:) -> {
      let required_input_attrs =
        list.flatten([
          [weft_lustre.html_attribute(attribute.type_("radio"))],
          [weft_lustre.html_attribute(attribute.name(name))],
          [weft_lustre.html_attribute(attribute.value(value))],
          [weft_lustre.html_attribute(attribute.checked(checked))],
          case disabled {
            True -> [weft_lustre.html_attribute(attribute.disabled(True))]
            False -> []
          },
          case disabled {
            True -> []
            False -> [weft_lustre.html_attribute(event.on_change(on_select))]
          },
        ])

      let input_node =
        weft_lustre.element_tag(
          tag: "input",
          base_weft_attrs: [weft.el_layout()],
          attrs: required_input_attrs,
          children: [],
        )

      weft_lustre.element_tag(
        tag: "label",
        base_weft_attrs: [weft.el_layout()],
        attrs: attrs,
        children: [input_node, label],
      )
    }
  }
}
