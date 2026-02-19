//// Headless tabs primitives for weft_lustre_ui.

import gleam/list
import lustre/attribute
import weft_lustre
import weft_lustre_ui/headless/button as headless_button

/// A tabs trigger item.
pub opaque type TabItem {
  TabItem(value: String, label: String)
}

/// Construct a tabs trigger item.
pub fn tab_item(value value: String, label label: String) -> TabItem {
  TabItem(value: value, label: label)
}

/// Tabs configuration.
pub opaque type TabsConfig(msg) {
  TabsConfig(
    value: String,
    on_change: fn(String) -> msg,
    attrs: List(weft_lustre.Attribute(msg)),
    list_attrs: List(weft_lustre.Attribute(msg)),
    trigger_attrs: List(weft_lustre.Attribute(msg)),
    active_trigger_attrs: List(weft_lustre.Attribute(msg)),
    inactive_trigger_attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct tabs configuration.
pub fn tabs_config(
  value value: String,
  on_change on_change: fn(String) -> msg,
) -> TabsConfig(msg) {
  TabsConfig(
    value: value,
    on_change: on_change,
    attrs: [],
    list_attrs: [],
    trigger_attrs: [],
    active_trigger_attrs: [],
    inactive_trigger_attrs: [],
  )
}

/// Append tabs root attributes.
pub fn tabs_attrs(
  config config: TabsConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> TabsConfig(msg) {
  case config {
    TabsConfig(attrs: existing, ..) ->
      TabsConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Append tablist attributes.
pub fn tabs_list_attrs(
  config config: TabsConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> TabsConfig(msg) {
  case config {
    TabsConfig(list_attrs: existing, ..) ->
      TabsConfig(..config, list_attrs: list.append(existing, attrs))
  }
}

/// Append tab trigger attributes.
pub fn tabs_trigger_attrs(
  config config: TabsConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> TabsConfig(msg) {
  case config {
    TabsConfig(trigger_attrs: existing, ..) ->
      TabsConfig(..config, trigger_attrs: list.append(existing, attrs))
  }
}

/// Append active trigger attributes.
pub fn tabs_active_trigger_attrs(
  config config: TabsConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> TabsConfig(msg) {
  case config {
    TabsConfig(active_trigger_attrs: existing, ..) ->
      TabsConfig(..config, active_trigger_attrs: list.append(existing, attrs))
  }
}

/// Append inactive trigger attributes.
pub fn tabs_inactive_trigger_attrs(
  config config: TabsConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> TabsConfig(msg) {
  case config {
    TabsConfig(inactive_trigger_attrs: existing, ..) ->
      TabsConfig(..config, inactive_trigger_attrs: list.append(existing, attrs))
  }
}

/// Render headless tabs.
pub fn tabs(
  config config: TabsConfig(msg),
  items items: List(TabItem),
  content content: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  case config {
    TabsConfig(
      value: active,
      on_change:,
      attrs: attrs,
      list_attrs: list_attrs,
      trigger_attrs: trigger_attrs,
      active_trigger_attrs: active_trigger_attrs,
      inactive_trigger_attrs: inactive_trigger_attrs,
    ) -> {
      let trigger_nodes =
        list.map(items, fn(item) {
          case item {
            TabItem(value: item_value, label: item_label) -> {
              let on_press = on_change(item_value)
              let state_attrs = case item_value == active {
                True -> active_trigger_attrs
                False -> inactive_trigger_attrs
              }

              headless_button.button(
                config: headless_button.button_config(on_press: on_press)
                  |> headless_button.button_attrs(
                    attrs: list.flatten([
                      [
                        weft_lustre.html_attribute(attribute.role("tab")),
                        weft_lustre.html_attribute(attribute.aria_selected(
                          item_value == active,
                        )),
                      ],
                      trigger_attrs,
                      state_attrs,
                    ]),
                  ),
                child: weft_lustre.text(content: item_label),
              )
            }
          }
        })

      weft_lustre.column(attrs: attrs, children: [
        weft_lustre.row(
          attrs: [
            weft_lustre.html_attribute(attribute.role("tablist")),
            ..list_attrs
          ],
          children: trigger_nodes,
        ),
        content,
      ])
    }
  }
}
