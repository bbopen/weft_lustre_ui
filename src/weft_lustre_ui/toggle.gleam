//// Styled, theme-driven toggle button component for weft_lustre_ui.
////
//// Renders a button with `aria-pressed` and theme-driven visual states:
//// accent background when pressed, muted hover when not pressed,
//// ghost-like transparent default state.

import gleam/dynamic/decode
import gleam/list
import lustre/attribute
import lustre/event
import weft
import weft_lustre
import weft_lustre_ui/headless/toggle as headless_toggle
import weft_lustre_ui/theme

/// Styled toggle configuration alias.
pub type ToggleConfig(msg) =
  headless_toggle.ToggleConfig(msg)

/// Construct a toggle configuration.
pub fn toggle_config(
  pressed pressed: Bool,
  on_toggle on_toggle: fn(Bool) -> msg,
) -> ToggleConfig(msg) {
  headless_toggle.toggle_config(pressed: pressed, on_toggle: on_toggle)
}

/// Disable the toggle.
pub fn toggle_disabled(config config: ToggleConfig(msg)) -> ToggleConfig(msg) {
  headless_toggle.toggle_disabled(config: config)
}

/// Append additional attributes to the toggle.
pub fn toggle_attrs(
  config config: ToggleConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ToggleConfig(msg) {
  headless_toggle.toggle_attrs(config: config, attrs: attrs)
}

fn bool_to_string(value: Bool) -> String {
  case value {
    True -> "true"
    False -> "false"
  }
}

fn toggle_styles(
  theme theme: theme.Theme,
  pressed pressed: Bool,
  disabled disabled: Bool,
) -> List(weft.Attribute) {
  let #(accent_bg, accent_fg) = theme.accent(theme)
  let transparent = weft.transparent()
  let #(_, surface_fg) = theme.surface(theme)
  let radius = theme.radius_md(theme)

  let #(bg, fg) = case pressed {
    True -> #(accent_bg, accent_fg)
    False -> #(transparent, surface_fg)
  }

  list.flatten([
    [
      weft.display(value: weft.display_inline_flex()),
      weft.align_items(value: weft.align_items_center()),
      weft.justify_content(value: weft.justify_center()),
      weft.spacing(pixels: 8),
      weft.height(length: weft.fixed(length: weft.px(pixels: 36))),
      weft.width(length: weft.minimum(
        base: weft.shrink(),
        min: weft.px(pixels: 36),
      )),
      weft.padding_xy(x: 8, y: 0),
      weft.rounded(radius: radius),
      weft.font_size(size: weft.rem(rem: 0.875)),
      weft.font_weight(weight: weft.font_weight_value(weight: 500)),
      weft.font_family(families: theme.font_families(theme)),
      weft.text_color(color: fg),
      weft.background(color: bg),
      weft.border(
        width: weft.px(pixels: 0),
        style: weft.border_style_none(),
        color: transparent,
      ),
      weft.cursor(cursor: weft.cursor_pointer()),
      weft.outline_none(),
      weft.appearance(value: weft.appearance_none()),
      weft.transition(
        property: weft.transition_property_background_color(),
        duration: weft.ms(milliseconds: 150),
        easing: weft.ease(),
      ),
    ],
    case pressed {
      False -> [
        weft.mouse_over(attrs: [
          weft.background(color: theme.hover_surface(theme)),
          weft.text_color(color: theme.muted_text(theme)),
        ]),
      ]
      True -> []
    },
    case disabled {
      True -> [
        weft.alpha(opacity: theme.disabled_opacity(theme)),
        weft.cursor(cursor: weft.cursor_not_allowed()),
      ]
      False -> []
    },
  ])
}

/// Render a styled toggle button.
pub fn toggle(
  theme theme: theme.Theme,
  config config: ToggleConfig(msg),
  child child: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  let pressed = headless_toggle.toggle_config_pressed(config: config)
  let on_toggle = headless_toggle.toggle_config_on_toggle(config: config)
  let disabled = headless_toggle.toggle_config_disabled(config: config)
  let attrs = headless_toggle.toggle_config_attrs(config: config)

  let button_attrs =
    list.flatten([
      [
        weft_lustre.html_attribute(attribute.type_("button")),
        weft_lustre.html_attribute(attribute.attribute(
          "aria-pressed",
          bool_to_string(pressed),
        )),
        weft_lustre.styles(toggle_styles(
          theme: theme,
          pressed: pressed,
          disabled: disabled,
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
