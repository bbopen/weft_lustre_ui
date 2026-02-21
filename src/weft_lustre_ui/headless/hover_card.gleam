//// Headless hover card component for weft_lustre_ui.
////
//// A hover card shows rich content when hovering over a trigger element.
//// Unlike a popover, it is triggered on mouseenter/mouseleave rather than click.

import gleam/dynamic/decode
import gleam/list
import lustre/attribute
import lustre/event
import weft
import weft_lustre

/// Hover card configuration.
pub opaque type HoverCardConfig(msg) {
  HoverCardConfig(
    open: Bool,
    on_open_change: fn(Bool) -> msg,
    attrs: List(weft_lustre.Attribute(msg)),
    trigger_attrs: List(weft_lustre.Attribute(msg)),
    content_attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct hover card configuration.
pub fn hover_card_config(
  open open: Bool,
  on_open_change on_open_change: fn(Bool) -> msg,
) -> HoverCardConfig(msg) {
  HoverCardConfig(
    open: open,
    on_open_change: on_open_change,
    attrs: [],
    trigger_attrs: [],
    content_attrs: [],
  )
}

/// Append root attributes.
pub fn hover_card_attrs(
  config config: HoverCardConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> HoverCardConfig(msg) {
  case config {
    HoverCardConfig(attrs: existing, ..) ->
      HoverCardConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Append trigger attributes.
pub fn hover_card_trigger_attrs(
  config config: HoverCardConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> HoverCardConfig(msg) {
  case config {
    HoverCardConfig(trigger_attrs: existing, ..) ->
      HoverCardConfig(..config, trigger_attrs: list.append(existing, attrs))
  }
}

/// Append content attributes.
pub fn hover_card_content_attrs(
  config config: HoverCardConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> HoverCardConfig(msg) {
  case config {
    HoverCardConfig(content_attrs: existing, ..) ->
      HoverCardConfig(..config, content_attrs: list.append(existing, attrs))
  }
}

/// Internal: read the `open` field from a `HoverCardConfig`.
@internal
pub fn hover_card_config_open(config config: HoverCardConfig(msg)) -> Bool {
  case config {
    HoverCardConfig(open:, ..) -> open
  }
}

/// Internal: read the `on_open_change` function from a `HoverCardConfig`.
@internal
pub fn hover_card_config_on_open_change(
  config config: HoverCardConfig(msg),
) -> fn(Bool) -> msg {
  case config {
    HoverCardConfig(on_open_change:, ..) -> on_open_change
  }
}

/// Render headless hover card.
pub fn hover_card(
  config config: HoverCardConfig(msg),
  trigger trigger: weft_lustre.Element(msg),
  content content: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  case config {
    HoverCardConfig(
      open: open,
      on_open_change: on_open_change,
      attrs: attrs,
      trigger_attrs: trigger_attrs,
      content_attrs: content_attrs,
    ) -> {
      let content_el = case open {
        True ->
          weft_lustre.element_tag(
            tag: "div",
            base_weft_attrs: [weft.el_layout()],
            attrs: [
              weft_lustre.html_attribute(attribute.attribute(
                "data-slot",
                "hover-card-content",
              )),
              weft_lustre.html_attribute(attribute.role("tooltip")),
              ..content_attrs
            ],
            children: [content],
          )
        False -> weft_lustre.none()
      }

      weft_lustre.column(
        attrs: [
          weft_lustre.styles([
            weft.display(value: weft.display_inline_flex()),
            weft.align_items(value: weft.align_items_start()),
          ]),
          ..attrs
        ],
        children: [
          weft_lustre.element_tag(
            tag: "div",
            base_weft_attrs: [weft.el_layout()],
            attrs: [
              weft_lustre.html_attribute(event.on(
                "mouseenter",
                decode.success(on_open_change(True)),
              )),
              weft_lustre.html_attribute(event.on(
                "mouseleave",
                decode.success(on_open_change(False)),
              )),
              ..trigger_attrs
            ],
            children: [trigger],
          ),
          content_el,
        ],
      )
    }
  }
}
