//// Headless switch component for weft_lustre_ui.

import gleam/dynamic/decode
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

fn bool_to_string(value: Bool) -> String {
  case value {
    True -> "true"
    False -> "false"
  }
}

/// Internal: read the `checked` field from a `SwitchConfig`.
@internal
pub fn switch_config_checked(config config: SwitchConfig(msg)) -> Bool {
  case config {
    SwitchConfig(checked:, ..) -> checked
  }
}

/// Internal: read the `on_toggle` function from a `SwitchConfig`.
@internal
pub fn switch_config_on_toggle(
  config config: SwitchConfig(msg),
) -> fn(Bool) -> msg {
  case config {
    SwitchConfig(on_toggle:, ..) -> on_toggle
  }
}

/// Internal: read the `disabled` field from a `SwitchConfig`.
@internal
pub fn switch_config_disabled(config config: SwitchConfig(msg)) -> Bool {
  case config {
    SwitchConfig(disabled:, ..) -> disabled
  }
}

/// Internal: read the extra `attrs` from a `SwitchConfig`.
@internal
pub fn switch_config_attrs(
  config config: SwitchConfig(msg),
) -> List(weft_lustre.Attribute(msg)) {
  case config {
    SwitchConfig(attrs:, ..) -> attrs
  }
}

/// Render headless switch as a semantically correct ARIA toggle button.
pub fn switch(
  config config: SwitchConfig(msg),
  label label: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  case config {
    SwitchConfig(checked:, on_toggle:, disabled:, attrs:) -> {
      let button_attrs =
        list.flatten([
          [
            weft_lustre.html_attribute(attribute.attribute("role", "switch")),
            weft_lustre.html_attribute(attribute.attribute(
              "aria-checked",
              bool_to_string(checked),
            )),
            weft_lustre.html_attribute(attribute.attribute(
              "aria-disabled",
              bool_to_string(disabled),
            )),
          ],
          case disabled {
            True -> []
            False -> [
              weft_lustre.html_attribute(attribute.attribute("tabindex", "0")),
              weft_lustre.html_attribute(event.on_click(on_toggle(!checked))),
              weft_lustre.html_attribute(
                event.on("keydown", {
                  use key <- decode.field("key", decode.string)
                  case key {
                    " " -> decode.success(on_toggle(!checked))
                    _ -> decode.failure(on_toggle(!checked), "non-space key")
                  }
                }),
              ),
            ]
          },
        ])

      let track_wrapper =
        weft_lustre.element_tag(
          tag: "span",
          base_weft_attrs: [weft.el_layout()],
          attrs: [
            weft_lustre.html_attribute(attribute.attribute(
              "aria-hidden",
              "true",
            )),
          ],
          children: [
            weft_lustre.element_tag(
              tag: "span",
              base_weft_attrs: [weft.el_layout()],
              attrs: [],
              children: [],
            ),
          ],
        )

      weft_lustre.row(attrs: attrs, children: [
        weft_lustre.element_tag(
          tag: "button",
          base_weft_attrs: [weft.el_layout()],
          attrs: button_attrs,
          children: [track_wrapper],
        ),
        label,
      ])
    }
  }
}
