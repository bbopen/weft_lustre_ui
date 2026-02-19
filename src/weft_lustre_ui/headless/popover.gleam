//// Headless popover component for weft_lustre_ui.

import gleam/list
import lustre/attribute
import lustre/event
import weft
import weft_lustre

/// Popover configuration.
pub opaque type PopoverConfig(msg) {
  PopoverConfig(
    open: Bool,
    on_toggle: fn(Bool) -> msg,
    attrs: List(weft_lustre.Attribute(msg)),
    trigger_attrs: List(weft_lustre.Attribute(msg)),
    panel_attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct popover configuration.
pub fn popover_config(
  open open: Bool,
  on_toggle on_toggle: fn(Bool) -> msg,
) -> PopoverConfig(msg) {
  PopoverConfig(
    open: open,
    on_toggle: on_toggle,
    attrs: [],
    trigger_attrs: [],
    panel_attrs: [],
  )
}

/// Append root attributes.
pub fn popover_attrs(
  config config: PopoverConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> PopoverConfig(msg) {
  case config {
    PopoverConfig(attrs: existing, ..) ->
      PopoverConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Append trigger attributes.
pub fn popover_trigger_attrs(
  config config: PopoverConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> PopoverConfig(msg) {
  case config {
    PopoverConfig(trigger_attrs: existing, ..) ->
      PopoverConfig(..config, trigger_attrs: list.append(existing, attrs))
  }
}

/// Append panel attributes.
pub fn popover_panel_attrs(
  config config: PopoverConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> PopoverConfig(msg) {
  case config {
    PopoverConfig(panel_attrs: existing, ..) ->
      PopoverConfig(..config, panel_attrs: list.append(existing, attrs))
  }
}

/// Render headless popover.
pub fn popover(
  config config: PopoverConfig(msg),
  trigger trigger: weft_lustre.Element(msg),
  panel panel: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  case config {
    PopoverConfig(
      open: open,
      on_toggle: on_toggle,
      attrs: attrs,
      trigger_attrs: trigger_attrs,
      panel_attrs: panel_attrs,
    ) -> {
      let content = case open {
        True -> weft_lustre.el(attrs: panel_attrs, child: panel)
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
            tag: "button",
            base_weft_attrs: [weft.el_layout()],
            attrs: [
              weft_lustre.styles([
                weft.display(value: weft.display_inline_flex()),
                weft.align_items(value: weft.align_items_center()),
                weft.justify_content(value: weft.justify_center()),
              ]),
              weft_lustre.html_attribute(attribute.type_("button")),
              weft_lustre.html_attribute(event.on_click(on_toggle(!open))),
              ..trigger_attrs
            ],
            children: [trigger],
          ),
          content,
        ],
      )
    }
  }
}
