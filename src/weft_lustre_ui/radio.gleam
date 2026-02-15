//// Radio component for weft_lustre_ui (themed).
////
//// The radio renders a native `<input type="radio">` wrapped in a `<label>`
//// so the full label area is clickable. Styling uses weft primitives and keeps
//// native keyboard semantics intact.

import gleam/list
import lustre/attribute
import lustre/event
import weft
import weft_lustre
import weft_lustre_ui/theme

/// Radio configuration.
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

/// Append additional weft_lustre attributes to the radio wrapper.
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

fn max_int(a: Int, b: Int) -> Int {
  case a >= b {
    True -> a
    False -> b
  }
}

fn wrapper_styles(t: theme.Theme, disabled: Bool) -> List(weft.Attribute) {
  let #(_, surface_fg) = theme.surface(t)

  let cursor = case disabled {
    True -> weft.cursor_not_allowed()
    False -> weft.cursor_pointer()
  }

  list.flatten([
    [
      weft.align_items(value: weft.align_items_center()),
      weft.spacing(pixels: max_int(8, theme.space_md(t) - 4)),
      weft.font_family(families: theme.font_families(t)),
      weft.font_size(size: weft.rem(rem: 0.9375)),
      weft.line_height(height: weft.line_height_multiple(multiplier: 1.25)),
      weft.text_color(color: surface_fg),
      weft.user_select(value: weft.user_select_none()),
      weft.cursor(cursor: cursor),
    ],
    case disabled {
      True -> [weft.alpha(opacity: theme.disabled_opacity(t))]
      False -> []
    },
  ])
}

fn input_styles(t: theme.Theme) -> List(weft.Attribute) {
  [
    weft.width(length: weft.fixed(length: weft.rem(rem: 1.0))),
    weft.height(length: weft.fixed(length: weft.rem(rem: 1.0))),
    weft.accent_color(color: theme.focus_ring_color(t)),
    weft.cursor(cursor: weft.cursor_pointer()),
    weft.outline_none(),
    weft.focus_visible(attrs: [
      weft.outline(width: weft.px(pixels: 2), color: theme.focus_ring_color(t)),
      weft.outline_offset(length: weft.px(pixels: 2)),
    ]),
    weft.transitions(transitions: [
      weft.transition_item(
        property: weft.transition_property_all(),
        duration: weft.ms(milliseconds: 120),
        easing: weft.ease_out(),
      ),
    ]),
    weft.when(query: weft.prefers_reduced_motion(), attrs: [
      weft.transitions(transitions: []),
    ]),
  ]
}

/// Render a controlled radio.
pub fn radio(
  theme theme: theme.Theme,
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
          attrs: [
            weft_lustre.styles(input_styles(theme)),
            ..required_input_attrs
          ],
          children: [],
        )

      let wrapper_attrs = [
        weft_lustre.styles(wrapper_styles(theme, disabled)),
        ..attrs
      ]

      weft_lustre.element_tag(
        tag: "label",
        base_weft_attrs: [weft.row_layout()],
        attrs: wrapper_attrs,
        children: [input_node, label],
      )
    }
  }
}
