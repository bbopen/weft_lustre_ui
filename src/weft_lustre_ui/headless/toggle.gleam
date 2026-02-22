//// Headless (unstyled) toggle button component for weft_lustre_ui.
////
//// Renders a `<button>` element with `aria-pressed` for toggle semantics.
//// Visual appearance is not applied here; the styled wrapper handles colors
//// and state transitions.

import gleam/dynamic/decode
import gleam/list
import lustre/attribute
import lustre/event
import weft
import weft_lustre

/// Headless toggle configuration.
pub opaque type ToggleConfig(msg) {
  ToggleConfig(
    pressed: Bool,
    on_toggle: fn(Bool) -> msg,
    disabled: Bool,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a toggle configuration.
pub fn toggle_config(
  pressed pressed: Bool,
  on_toggle on_toggle: fn(Bool) -> msg,
) -> ToggleConfig(msg) {
  ToggleConfig(
    pressed: pressed,
    on_toggle: on_toggle,
    disabled: False,
    attrs: [],
  )
}

/// Disable the toggle.
pub fn toggle_disabled(config config: ToggleConfig(msg)) -> ToggleConfig(msg) {
  ToggleConfig(..config, disabled: True)
}

/// Append additional attributes to the toggle.
pub fn toggle_attrs(
  config config: ToggleConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ToggleConfig(msg) {
  case config {
    ToggleConfig(attrs: existing, ..) ->
      ToggleConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Internal: read the pressed state from a toggle config.
@internal
pub fn toggle_config_pressed(config config: ToggleConfig(msg)) -> Bool {
  case config {
    ToggleConfig(pressed:, ..) -> pressed
  }
}

/// Internal: read the on_toggle callback from a toggle config.
@internal
pub fn toggle_config_on_toggle(
  config config: ToggleConfig(msg),
) -> fn(Bool) -> msg {
  case config {
    ToggleConfig(on_toggle:, ..) -> on_toggle
  }
}

/// Internal: read the disabled state from a toggle config.
@internal
pub fn toggle_config_disabled(config config: ToggleConfig(msg)) -> Bool {
  case config {
    ToggleConfig(disabled:, ..) -> disabled
  }
}

/// Internal: read the attrs from a toggle config.
@internal
pub fn toggle_config_attrs(
  config config: ToggleConfig(msg),
) -> List(weft_lustre.Attribute(msg)) {
  case config {
    ToggleConfig(attrs:, ..) -> attrs
  }
}

fn bool_to_string(value: Bool) -> String {
  case value {
    True -> "true"
    False -> "false"
  }
}

/// Render an unstyled toggle button with aria-pressed.
pub fn toggle(
  config config: ToggleConfig(msg),
  child child: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  case config {
    ToggleConfig(pressed:, on_toggle:, disabled:, attrs:) -> {
      let button_attrs =
        list.flatten([
          [
            weft_lustre.html_attribute(attribute.type_("button")),
            weft_lustre.html_attribute(attribute.attribute(
              "aria-pressed",
              bool_to_string(pressed),
            )),
          ],
          case disabled {
            True -> [
              weft_lustre.html_attribute(attribute.disabled(True)),
            ]
            False -> [
              weft_lustre.html_attribute(event.on_click(on_toggle(!pressed))),
              weft_lustre.html_attribute(
                event.advanced("keydown", {
                  use key <- decode.field("key", decode.string)
                  case key {
                    " " | "Enter" ->
                      decode.success(event.handler(
                        dispatch: on_toggle(!pressed),
                        prevent_default: True,
                        stop_propagation: False,
                      ))
                    _ ->
                      decode.failure(
                        event.handler(
                          dispatch: on_toggle(!pressed),
                          prevent_default: False,
                          stop_propagation: False,
                        ),
                        "non-toggle key",
                      )
                  }
                }),
              ),
            ]
          },
          attrs,
        ])

      weft_lustre.element_tag(
        tag: "button",
        base_weft_attrs: [weft.el_layout()],
        attrs: button_attrs,
        children: [child],
      )
    }
  }
}
