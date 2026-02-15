//// Headless (unstyled) checkbox component for weft_lustre_ui.
////
//// The checkbox renders a native `<input type="checkbox">` wrapped in a
//// `<label>` so the full label area is clickable, preserving native keyboard
//// semantics.
////
//// Visual styling is the responsibility of the caller (or the styled wrapper
//// in `weft_lustre_ui/checkbox`).

import gleam/list
import lustre/attribute
import lustre/event
import weft
import weft_lustre

/// Headless checkbox configuration.
pub opaque type CheckboxConfig(msg) {
  CheckboxConfig(
    checked: Bool,
    on_toggle: fn(Bool) -> msg,
    disabled: Bool,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default checkbox config.
pub fn checkbox_config(
  checked checked: Bool,
  on_toggle on_toggle: fn(Bool) -> msg,
) -> CheckboxConfig(msg) {
  CheckboxConfig(
    checked: checked,
    on_toggle: on_toggle,
    disabled: False,
    attrs: [],
  )
}

/// Disable the checkbox.
pub fn checkbox_disabled(
  config config: CheckboxConfig(msg),
) -> CheckboxConfig(msg) {
  CheckboxConfig(..config, disabled: True)
}

/// Append additional attributes to the checkbox wrapper.
///
/// Attributes are appended, so later attributes can override earlier ones.
pub fn checkbox_attrs(
  config config: CheckboxConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> CheckboxConfig(msg) {
  case config {
    CheckboxConfig(attrs: existing, ..) ->
      CheckboxConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Render a controlled checkbox.
pub fn checkbox(
  config config: CheckboxConfig(msg),
  label label: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  case config {
    CheckboxConfig(checked:, on_toggle:, disabled:, attrs:) -> {
      let required_input_attrs =
        list.flatten([
          [weft_lustre.html_attribute(attribute.type_("checkbox"))],
          [weft_lustre.html_attribute(attribute.checked(checked))],
          case disabled {
            True -> [weft_lustre.html_attribute(attribute.disabled(True))]
            False -> []
          },
          case disabled {
            True -> []
            False -> [weft_lustre.html_attribute(event.on_check(on_toggle))]
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
