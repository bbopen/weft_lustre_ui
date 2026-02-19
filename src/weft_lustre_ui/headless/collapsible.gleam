//// Headless collapsible component for weft_lustre_ui.

import gleam/list
import lustre/attribute
import lustre/event
import weft
import weft_lustre

/// Collapsible configuration.
pub opaque type CollapsibleConfig(msg) {
  CollapsibleConfig(
    open: Bool,
    on_toggle: fn(Bool) -> msg,
    attrs: List(weft_lustre.Attribute(msg)),
    trigger_attrs: List(weft_lustre.Attribute(msg)),
    content_attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a collapsible configuration.
pub fn collapsible_config(
  open open: Bool,
  on_toggle on_toggle: fn(Bool) -> msg,
) -> CollapsibleConfig(msg) {
  CollapsibleConfig(
    open: open,
    on_toggle: on_toggle,
    attrs: [],
    trigger_attrs: [],
    content_attrs: [],
  )
}

/// Append root attributes.
pub fn collapsible_attrs(
  config config: CollapsibleConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> CollapsibleConfig(msg) {
  case config {
    CollapsibleConfig(attrs: existing, ..) ->
      CollapsibleConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Append attributes for the trigger button.
pub fn collapsible_trigger_attrs(
  config config: CollapsibleConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> CollapsibleConfig(msg) {
  case config {
    CollapsibleConfig(trigger_attrs: existing, ..) ->
      CollapsibleConfig(..config, trigger_attrs: list.append(existing, attrs))
  }
}

/// Append attributes for the content panel.
pub fn collapsible_content_attrs(
  config config: CollapsibleConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> CollapsibleConfig(msg) {
  case config {
    CollapsibleConfig(content_attrs: existing, ..) ->
      CollapsibleConfig(..config, content_attrs: list.append(existing, attrs))
  }
}

/// Render headless collapsible content.
pub fn collapsible(
  config config: CollapsibleConfig(msg),
  trigger trigger: weft_lustre.Element(msg),
  content content: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  case config {
    CollapsibleConfig(
      open: open,
      on_toggle: on_toggle,
      attrs: attrs,
      trigger_attrs: trigger_attrs,
      content_attrs: content_attrs,
    ) -> {
      let button_attrs = [
        weft_lustre.html_attribute(attribute.type_("button")),
        weft_lustre.html_attribute(attribute.aria_expanded(open)),
        weft_lustre.html_attribute(event.on_click(on_toggle(!open))),
        ..trigger_attrs
      ]

      let panel = case open {
        True -> weft_lustre.el(attrs: content_attrs, child: content)
        False -> weft_lustre.none()
      }

      weft_lustre.column(attrs: attrs, children: [
        weft_lustre.element_tag(
          tag: "button",
          base_weft_attrs: [weft.row_layout()],
          attrs: button_attrs,
          children: [trigger],
        ),
        panel,
      ])
    }
  }
}
