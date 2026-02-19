//// Headless toggle-group component for weft_lustre_ui.

import gleam/list
import lustre/attribute
import lustre/event
import weft
import weft_lustre

/// A toggle-group option.
pub opaque type ToggleItem {
  ToggleItem(value: String, label: String)
}

/// Construct toggle item.
pub fn toggle_item(value value: String, label label: String) -> ToggleItem {
  ToggleItem(value: value, label: label)
}

/// Toggle-group configuration.
pub opaque type ToggleGroupConfig(msg) {
  ToggleGroupConfig(
    value: String,
    on_change: fn(String) -> msg,
    attrs: List(weft_lustre.Attribute(msg)),
    active_item_attrs: List(weft_lustre.Attribute(msg)),
    inactive_item_attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct toggle-group configuration.
pub fn toggle_group_config(
  value value: String,
  on_change on_change: fn(String) -> msg,
) -> ToggleGroupConfig(msg) {
  ToggleGroupConfig(
    value: value,
    on_change: on_change,
    attrs: [],
    active_item_attrs: [],
    inactive_item_attrs: [],
  )
}

/// Append root attributes.
pub fn toggle_group_attrs(
  config config: ToggleGroupConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ToggleGroupConfig(msg) {
  case config {
    ToggleGroupConfig(attrs: existing, ..) ->
      ToggleGroupConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Append active item attributes.
pub fn toggle_group_active_item_attrs(
  config config: ToggleGroupConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ToggleGroupConfig(msg) {
  case config {
    ToggleGroupConfig(active_item_attrs: existing, ..) ->
      ToggleGroupConfig(
        ..config,
        active_item_attrs: list.append(existing, attrs),
      )
  }
}

/// Append inactive item attributes.
pub fn toggle_group_inactive_item_attrs(
  config config: ToggleGroupConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ToggleGroupConfig(msg) {
  case config {
    ToggleGroupConfig(inactive_item_attrs: existing, ..) ->
      ToggleGroupConfig(
        ..config,
        inactive_item_attrs: list.append(existing, attrs),
      )
  }
}

/// Render headless toggle-group.
pub fn toggle_group(
  config config: ToggleGroupConfig(msg),
  items items: List(ToggleItem),
) -> weft_lustre.Element(msg) {
  case config {
    ToggleGroupConfig(
      value: active,
      on_change:,
      attrs: attrs,
      active_item_attrs: active_item_attrs,
      inactive_item_attrs: inactive_item_attrs,
    ) ->
      weft_lustre.row(
        attrs: attrs,
        children: list.map(items, fn(item) {
          case item {
            ToggleItem(value: value, label: label) -> {
              let state_attrs = case value == active {
                True -> active_item_attrs
                False -> inactive_item_attrs
              }

              weft_lustre.element_tag(
                tag: "button",
                base_weft_attrs: [weft.el_layout()],
                attrs: [
                  weft_lustre.html_attribute(attribute.type_("button")),
                  weft_lustre.html_attribute(
                    attribute.aria_pressed(case value == active {
                      True -> "true"
                      False -> "false"
                    }),
                  ),
                  weft_lustre.html_attribute(event.on_click(on_change(value))),
                  ..state_attrs
                ],
                children: [weft_lustre.text(content: label)],
              )
            }
          }
        }),
      )
  }
}
