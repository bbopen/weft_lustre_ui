//// Styled switch component for weft_lustre_ui.

import gleam/dynamic/decode
import gleam/list
import lustre/attribute
import lustre/event
import weft
import weft_lustre
import weft_lustre_ui/headless/switch as headless_switch
import weft_lustre_ui/theme

/// Styled switch configuration alias.
pub type SwitchConfig(msg) =
  headless_switch.SwitchConfig(msg)

/// Construct switch configuration.
pub fn switch_config(
  checked checked: Bool,
  on_toggle on_toggle: fn(Bool) -> msg,
) -> SwitchConfig(msg) {
  headless_switch.switch_config(checked: checked, on_toggle: on_toggle)
}

/// Disable switch.
pub fn switch_disabled(config config: SwitchConfig(msg)) -> SwitchConfig(msg) {
  headless_switch.switch_disabled(config: config)
}

/// Append switch attributes.
pub fn switch_attrs(
  config config: SwitchConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> SwitchConfig(msg) {
  headless_switch.switch_attrs(config: config, attrs: attrs)
}

fn bool_to_string(value: Bool) -> String {
  case value {
    True -> "true"
    False -> "false"
  }
}

fn track_styles(
  t: theme.Theme,
  checked: Bool,
  disabled: Bool,
) -> List(weft.Attribute) {
  let bg = case checked {
    True -> {
      let #(primary_bg, _) = theme.primary(t)
      primary_bg
    }
    False -> theme.border_color(t)
  }

  let cursor = case disabled {
    True -> weft.cursor_not_allowed()
    False -> weft.cursor_pointer()
  }

  list.flatten([
    [
      weft.width(length: weft.fixed(length: weft.px(pixels: 36))),
      weft.height(length: weft.fixed(length: weft.px(pixels: 20))),
      weft.rounded(radius: weft.px(pixels: 9999)),
      weft.background(color: bg),
      weft.border(
        width: weft.px(pixels: 0),
        style: weft.border_style_none(),
        color: weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.0),
      ),
      weft.padding(pixels: 2),
      weft.display(value: weft.display_inline_flex()),
      weft.align_items(value: weft.align_items_center()),
      weft.cursor(cursor: cursor),
      weft.outline_none(),
      weft.appearance(value: weft.appearance_none()),
      weft.transition(
        property: weft.transition_property_background_color(),
        duration: weft.ms(milliseconds: 150),
        easing: weft.ease(),
      ),
    ],
    case disabled {
      True -> [weft.alpha(opacity: theme.disabled_opacity(t))]
      False -> []
    },
  ])
}

fn thumb_styles(checked: Bool) -> List(weft.Attribute) {
  let translate = case checked {
    True ->
      weft.transform([
        weft.translate(x: weft.px(pixels: 16), y: weft.px(pixels: 0)),
      ])
    False ->
      weft.transform([
        weft.translate(x: weft.px(pixels: 0), y: weft.px(pixels: 0)),
      ])
  }

  [
    weft.width(length: weft.fixed(length: weft.px(pixels: 16))),
    weft.height(length: weft.fixed(length: weft.px(pixels: 16))),
    weft.rounded(radius: weft.px(pixels: 9999)),
    weft.background(color: weft.rgb(red: 255, green: 255, blue: 255)),
    weft.display(value: weft.display_block()),
    translate,
    weft.transition(
      property: weft.transition_property_transform(),
      duration: weft.ms(milliseconds: 150),
      easing: weft.ease(),
    ),
  ]
}

fn track_wrapper_styles() -> List(weft.Attribute) {
  [
    weft.display(value: weft.display_inline_flex()),
    weft.align_items(value: weft.align_items_center()),
  ]
}

fn row_styles(t: theme.Theme) -> List(weft.Attribute) {
  [
    weft.spacing(pixels: 8),
    weft.align_items(value: weft.align_items_center()),
    weft.font_family(families: theme.font_families(t)),
    weft.font_size(size: weft.rem(rem: 0.875)),
  ]
}

/// Render styled switch.
pub fn switch(
  theme theme: theme.Theme,
  config config: SwitchConfig(msg),
  label label: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  let checked = headless_switch.switch_config_checked(config: config)
  let on_toggle = headless_switch.switch_config_on_toggle(config: config)
  let disabled = headless_switch.switch_config_disabled(config: config)
  let attrs = headless_switch.switch_config_attrs(config: config)

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
        weft_lustre.styles(track_styles(theme, checked, disabled)),
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

  let thumb =
    weft_lustre.element_tag(
      tag: "span",
      base_weft_attrs: [weft.el_layout()],
      attrs: [weft_lustre.styles(thumb_styles(checked))],
      children: [],
    )

  let track_wrapper =
    weft_lustre.element_tag(
      tag: "span",
      base_weft_attrs: [weft.el_layout()],
      attrs: [
        weft_lustre.html_attribute(attribute.attribute("aria-hidden", "true")),
        weft_lustre.styles(track_wrapper_styles()),
      ],
      children: [thumb],
    )

  let row_attrs = [weft_lustre.styles(row_styles(theme)), ..attrs]

  weft_lustre.row(attrs: row_attrs, children: [
    weft_lustre.element_tag(
      tag: "button",
      base_weft_attrs: [weft.el_layout()],
      attrs: button_attrs,
      children: [track_wrapper],
    ),
    label,
  ])
}
