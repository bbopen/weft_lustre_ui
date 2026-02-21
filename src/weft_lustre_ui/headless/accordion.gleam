//// Headless accordion component for weft_lustre_ui.
////
//// Provides an accessible accordion with correct ARIA wiring: trigger buttons
//// with `aria-expanded` and `aria-controls`, and content regions with
//// `role="region"` and `aria-labelledby`. Supports both single (one panel
//// open at a time) and multiple (any combination) expansion modes.

import gleam/list
import lustre/attribute
import lustre/event
import weft
import weft_lustre

/// Mode for accordion expansion behavior.
pub type AccordionMode {
  /// Only one item can be open at a time.
  Single
  /// Multiple items can be open simultaneously.
  Multiple
}

/// Configuration for an accordion item.
pub opaque type AccordionItemConfig {
  AccordionItemConfig(value: String, title: String, disabled: Bool)
}

/// Construct an accordion item configuration.
pub fn accordion_item_config(
  value value: String,
  title title: String,
) -> AccordionItemConfig {
  AccordionItemConfig(value: value, title: title, disabled: False)
}

/// Disable an accordion item so it cannot be toggled.
pub fn accordion_item_disabled(
  config config: AccordionItemConfig,
) -> AccordionItemConfig {
  AccordionItemConfig(..config, disabled: True)
}

/// Configuration for the accordion.
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

/// Internal: read the mode from an AccordionConfig.
@internal
pub fn accordion_config_mode(
  config config: AccordionConfig(msg),
) -> AccordionMode {
  case config {
    AccordionConfig(mode:, ..) -> mode
  }
}

/// Internal: read the open items from an AccordionConfig.
@internal
pub fn accordion_config_open_items(
  config config: AccordionConfig(msg),
) -> List(String) {
  case config {
    AccordionConfig(open_items:, ..) -> open_items
  }
}

/// Internal: read the on_toggle callback from an AccordionConfig.
@internal
pub fn accordion_config_on_toggle(
  config config: AccordionConfig(msg),
) -> fn(List(String)) -> msg {
  case config {
    AccordionConfig(on_toggle:, ..) -> on_toggle
  }
}

/// Internal: read the attrs from an AccordionConfig.
@internal
pub fn accordion_config_attrs(
  config config: AccordionConfig(msg),
) -> List(weft_lustre.Attribute(msg)) {
  case config {
    AccordionConfig(attrs:, ..) -> attrs
  }
}

/// Internal: read the value from an AccordionItemConfig.
@internal
pub fn accordion_item_config_value(config config: AccordionItemConfig) -> String {
  case config {
    AccordionItemConfig(value:, ..) -> value
  }
}

/// Internal: read the title from an AccordionItemConfig.
@internal
pub fn accordion_item_config_title(config config: AccordionItemConfig) -> String {
  case config {
    AccordionItemConfig(title:, ..) -> title
  }
}

/// Internal: check if an AccordionItemConfig is disabled.
@internal
pub fn accordion_item_config_is_disabled(
  config config: AccordionItemConfig,
) -> Bool {
  case config {
    AccordionItemConfig(disabled:, ..) -> disabled
  }
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
        Single -> [value]
        Multiple -> list.append(open_items, [value])
      }
  }
}

fn render_item(
  mode mode: AccordionMode,
  open_items open_items: List(String),
  on_toggle on_toggle: fn(List(String)) -> msg,
  item_config item_config: AccordionItemConfig,
  content content: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  case item_config {
    AccordionItemConfig(value:, title:, disabled:) -> {
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
            weft_lustre.html_attribute(attribute.attribute(
              "data-state",
              data_state,
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
          children: [weft_lustre.text(content: title)],
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
              weft_lustre.html_attribute(attribute.attribute(
                "data-state",
                "open",
              )),
            ],
            children: [content],
          )
        False -> weft_lustre.none()
      }

      weft_lustre.column(
        attrs: [
          weft_lustre.html_attribute(attribute.attribute(
            "data-state",
            data_state,
          )),
        ],
        children: [trigger, panel],
      )
    }
  }
}

/// Render a headless accordion.
///
/// Each item is a tuple of its configuration and the content element to show
/// when that item is expanded. The accordion manages toggle logic according
/// to the configured mode.
pub fn accordion(
  config config: AccordionConfig(msg),
  items items: List(#(AccordionItemConfig, weft_lustre.Element(msg))),
) -> weft_lustre.Element(msg) {
  case config {
    AccordionConfig(mode:, open_items:, on_toggle:, attrs:) -> {
      let children =
        list.map(items, fn(item) {
          let #(item_config, content) = item
          render_item(
            mode: mode,
            open_items: open_items,
            on_toggle: on_toggle,
            item_config: item_config,
            content: content,
          )
        })

      weft_lustre.column(attrs: attrs, children: children)
    }
  }
}
