//// Headless switch component for weft_lustre_ui.

import gleam/list
import lustre/attribute
import lustre/event
import weft
import weft_lustre

/// Switch configuration.
pub opaque type SwitchConfig(msg) {
  SwitchConfig(
    checked: Bool,
    on_toggle: fn(Bool) -> msg,
    disabled: Bool,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct switch configuration.
pub fn switch_config(
  checked checked: Bool,
  on_toggle on_toggle: fn(Bool) -> msg,
) -> SwitchConfig(msg) {
  SwitchConfig(
    checked: checked,
    on_toggle: on_toggle,
    disabled: False,
    attrs: [],
  )
}

/// Disable switch.
pub fn switch_disabled(config config: SwitchConfig(msg)) -> SwitchConfig(msg) {
  SwitchConfig(..config, disabled: True)
}

/// Append switch attributes.
pub fn switch_attrs(
  config config: SwitchConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> SwitchConfig(msg) {
  case config {
    SwitchConfig(attrs: existing, ..) ->
      SwitchConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Render headless switch.
pub fn switch(
  config config: SwitchConfig(msg),
  label label: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  case config {
    SwitchConfig(checked:, on_toggle:, disabled:, attrs:) -> {
      let input_attrs =
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

      weft_lustre.row(attrs: attrs, children: [
        weft_lustre.element_tag(
          tag: "input",
          base_weft_attrs: [weft.el_layout()],
          attrs: input_attrs,
          children: [],
        ),
        label,
      ])
    }
  }
}
