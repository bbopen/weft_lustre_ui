//// Styled, theme-driven accordion component for weft_lustre_ui.
////
//// This wrapper maps accordion structure to theme token-driven colors and
//// border styling. Items receive a bottom border (except the last) and
//// trigger buttons get themed text, hover underline, and disabled opacity.

import gleam/list
import lustre/attribute
import lustre/event
import weft
import weft_lustre
import weft_lustre_ui/headless/accordion as headless_accordion
import weft_lustre_ui/theme

/// Styled accordion mode — delegates to the headless type.
pub type AccordionMode =
  headless_accordion.AccordionMode

/// Styled accordion item configuration — delegates to the headless type.
pub type AccordionItemConfig =
  headless_accordion.AccordionItemConfig

/// Styled accordion configuration.
pub opaque type AccordionConfig(msg) {
  AccordionConfig(
    mode: AccordionMode,
    open_items: List(String),
    on_toggle: fn(List(String)) -> msg,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct accordion configuration.
pub fn accordion_config(
  mode mode: AccordionMode,
  open_items open_items: List(String),
  on_toggle on_toggle: fn(List(String)) -> msg,
) -> AccordionConfig(msg) {
  AccordionConfig(
    mode: mode,
    open_items: open_items,
    on_toggle: on_toggle,
    attrs: [],
  )
}

/// Append root attributes to the accordion container.
pub fn accordion_attrs(
  config config: AccordionConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> AccordionConfig(msg) {
  case config {
    AccordionConfig(attrs: existing, ..) ->
      AccordionConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Construct an accordion item configuration.
pub fn accordion_item_config(
  value value: String,
  title title: String,
) -> AccordionItemConfig {
  headless_accordion.accordion_item_config(value: value, title: title)
}

/// Disable an accordion item so it cannot be toggled.
pub fn accordion_item_disabled(
  config config: AccordionItemConfig,
) -> AccordionItemConfig {
  headless_accordion.accordion_item_disabled(config: config)
}

fn accordion_item_styles() -> List(weft.Attribute) {
  [weft.width(length: weft.fill())]
}

fn accordion_trigger_styles(
  theme theme: theme.Theme,
  is_open _is_open: Bool,
  disabled disabled: Bool,
) -> List(weft.Attribute) {
  let #(_, surface_fg) = theme.surface(theme)

  list.flatten([
    [
      weft.display(value: weft.display_flex()),
      weft.align_items(value: weft.align_items_center()),
      weft.justify_content(value: weft.justify_space_between()),
      weft.width(length: weft.fill()),
      weft.padding_xy(x: 0, y: 12),
      weft.font_family(families: theme.font_families(theme)),
      weft.font_size(size: weft.rem(rem: 0.875)),
      weft.font_weight(weight: weft.font_weight_value(weight: 500)),
      weft.text_color(color: surface_fg),
      weft.background(color: weft.transparent()),
      weft.border(
        width: weft.px(pixels: 0),
        style: weft.border_style_none(),
        color: weft.transparent(),
      ),
      weft.cursor(cursor: weft.cursor_pointer()),
      weft.outline_none(),
      weft.appearance(value: weft.appearance_none()),
      weft.text_decoration(value: weft.text_decoration_none()),
    ],
    [
      weft.mouse_over(attrs: [
        weft.text_decoration(value: weft.text_decoration_underline()),
      ]),
    ],
    case disabled {
      True -> [
        weft.alpha(opacity: theme.disabled_opacity(theme)),
        weft.cursor(cursor: weft.cursor_not_allowed()),
      ]
      False -> []
    },
  ])
}

fn accordion_content_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  let muted = theme.muted_text(theme)

  [
    weft.padding_xy(x: 0, y: 0),
    weft.font_family(families: theme.font_families(theme)),
    weft.font_size(size: weft.rem(rem: 0.875)),
    weft.text_color(color: muted),
    weft.overflow(overflow: weft.overflow_hidden()),
  ]
}

fn separator_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  let border_color = theme.border_color(theme)

  [
    weft.display(value: weft.display_block()),
    weft.height(length: weft.fixed(length: weft.px(pixels: 1))),
    weft.width(length: weft.fill()),
    weft.background(color: border_color),
  ]
}

fn chevron_indicator(is_open is_open: Bool) -> weft_lustre.Element(msg) {
  let rotation = case is_open {
    True -> weft.transform(items: [weft.rotate_degrees(deg: 180.0)])
    False -> weft.transform(items: [weft.rotate_degrees(deg: 0.0)])
  }

  weft_lustre.element_tag(
    tag: "span",
    base_weft_attrs: [weft.el_layout()],
    attrs: [
      weft_lustre.html_attribute(attribute.attribute("aria-hidden", "true")),
      weft_lustre.styles([
        weft.display(value: weft.display_inline_flex()),
        weft.align_items(value: weft.align_items_center()),
        weft.justify_content(value: weft.justify_center()),
        weft.width(length: weft.fixed(length: weft.px(pixels: 16))),
        weft.height(length: weft.fixed(length: weft.px(pixels: 16))),
        weft.font_size(size: weft.rem(rem: 0.75)),
        rotation,
        weft.transition(
          property: weft.transition_property_transform(),
          duration: weft.ms(milliseconds: 200),
          easing: weft.ease(),
        ),
      ]),
    ],
    children: [weft_lustre.text(content: "\u{25BE}")],
  )
}

fn compute_toggled_items(
  mode mode: AccordionMode,
  open_items open_items: List(String),
  value value: String,
) -> List(String) {
  let is_open = list.contains(open_items, any: value)
  case is_open {
    True -> list.filter(open_items, fn(v) { v != value })
    False ->
      case mode {
        headless_accordion.Single -> [value]
        headless_accordion.Multiple -> list.append(open_items, [value])
      }
  }
}

fn render_styled_item(
  theme theme: theme.Theme,
  mode mode: AccordionMode,
  open_items open_items: List(String),
  on_toggle on_toggle: fn(List(String)) -> msg,
  item_config item_config: AccordionItemConfig,
  content content: weft_lustre.Element(msg),
  is_last is_last: Bool,
) -> List(weft_lustre.Element(msg)) {
  let value =
    headless_accordion.accordion_item_config_value(config: item_config)
  let title =
    headless_accordion.accordion_item_config_title(config: item_config)
  let disabled =
    headless_accordion.accordion_item_config_is_disabled(config: item_config)

  let is_open = list.contains(open_items, any: value)
  let trigger_id = "accordion-trigger-" <> value
  let content_id = "accordion-content-" <> value

  let data_state = case is_open {
    True -> "open"
    False -> "closed"
  }

  let button_attrs =
    list.flatten([
      [
        weft_lustre.html_attribute(attribute.type_("button")),
        weft_lustre.html_attribute(attribute.id(trigger_id)),
        weft_lustre.html_attribute(attribute.aria_expanded(is_open)),
        weft_lustre.html_attribute(attribute.aria_controls(content_id)),
        weft_lustre.html_attribute(attribute.attribute("data-state", data_state)),
        weft_lustre.styles(accordion_trigger_styles(
          theme: theme,
          is_open: is_open,
          disabled: disabled,
        )),
      ],
      case disabled {
        True -> [weft_lustre.html_attribute(attribute.disabled(True))]
        False -> [
          weft_lustre.html_attribute(
            event.on_click(
              on_toggle(compute_toggled_items(
                mode: mode,
                open_items: open_items,
                value: value,
              )),
            ),
          ),
        ]
      },
    ])

  let trigger =
    weft_lustre.element_tag(
      tag: "button",
      base_weft_attrs: [weft.row_layout()],
      attrs: button_attrs,
      children: [
        weft_lustre.text(content: title),
        chevron_indicator(is_open: is_open),
      ],
    )

  let panel = case is_open {
    True ->
      weft_lustre.element_tag(
        tag: "div",
        base_weft_attrs: [weft.el_layout()],
        attrs: [
          weft_lustre.html_attribute(attribute.id(content_id)),
          weft_lustre.html_attribute(attribute.role("region")),
          weft_lustre.html_attribute(attribute.aria_labelledby(trigger_id)),
          weft_lustre.html_attribute(attribute.attribute("data-state", "open")),
          weft_lustre.styles(accordion_content_styles(theme: theme)),
        ],
        children: [content],
      )
    False -> weft_lustre.none()
  }

  let item =
    weft_lustre.column(
      attrs: [
        weft_lustre.html_attribute(attribute.attribute("data-state", data_state)),
        weft_lustre.styles(accordion_item_styles()),
      ],
      children: [trigger, panel],
    )

  case is_last {
    True -> [item]
    False -> [
      item,
      weft_lustre.element_tag(
        tag: "div",
        base_weft_attrs: [weft.el_layout()],
        attrs: [
          weft_lustre.html_attribute(attribute.attribute("aria-hidden", "true")),
          weft_lustre.styles(separator_styles(theme: theme)),
        ],
        children: [],
      ),
    ]
  }
}

/// Render a styled accordion with theme-driven borders, typography, and
/// animated chevron indicators.
pub fn accordion(
  theme theme: theme.Theme,
  config config: AccordionConfig(msg),
  items items: List(#(AccordionItemConfig, weft_lustre.Element(msg))),
) -> weft_lustre.Element(msg) {
  case config {
    AccordionConfig(mode:, open_items:, on_toggle:, attrs:) -> {
      let item_count = list.length(of: items)

      let children =
        items
        |> list.index_map(fn(item, index) {
          let #(item_config, content) = item
          let is_last = index == item_count - 1
          render_styled_item(
            theme: theme,
            mode: mode,
            open_items: open_items,
            on_toggle: on_toggle,
            item_config: item_config,
            content: content,
            is_last: is_last,
          )
        })
        |> list.flatten

      weft_lustre.column(
        attrs: [weft_lustre.styles([weft.width(length: weft.fill())]), ..attrs],
        children: children,
      )
    }
  }
}
