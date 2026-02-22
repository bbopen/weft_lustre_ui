//// Headless context menu component for weft_lustre_ui.
////
//// A context menu is triggered by right-click (the `contextmenu` event). It
//// shows a menu panel and includes a transparent scrim to close the menu when
//// clicking outside.

import gleam/dynamic/decode
import gleam/list
import lustre/attribute
import lustre/event
import weft
import weft_lustre

/// Context menu item variant.
pub type ContextMenuItemVariant {
  /// Default menu item style.
  DefaultItem
  /// Destructive / danger menu item style.
  DestructiveItem
}

/// Context menu configuration.
pub opaque type ContextMenuConfig(msg) {
  ContextMenuConfig(
    open: Bool,
    on_open_change: fn(Bool) -> msg,
    attrs: List(weft_lustre.Attribute(msg)),
    trigger_attrs: List(weft_lustre.Attribute(msg)),
    content_attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Context menu item configuration.
pub opaque type ContextMenuItemConfig(msg) {
  ContextMenuItemConfig(
    on_click: fn() -> msg,
    disabled: Bool,
    variant: ContextMenuItemVariant,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct context menu configuration.
pub fn context_menu_config(
  open open: Bool,
  on_open_change on_open_change: fn(Bool) -> msg,
) -> ContextMenuConfig(msg) {
  ContextMenuConfig(
    open: open,
    on_open_change: on_open_change,
    attrs: [],
    trigger_attrs: [],
    content_attrs: [],
  )
}

/// Append root attributes.
pub fn context_menu_attrs(
  config config: ContextMenuConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ContextMenuConfig(msg) {
  case config {
    ContextMenuConfig(attrs: existing, ..) ->
      ContextMenuConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Append trigger attributes.
pub fn context_menu_trigger_attrs(
  config config: ContextMenuConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ContextMenuConfig(msg) {
  case config {
    ContextMenuConfig(trigger_attrs: existing, ..) ->
      ContextMenuConfig(..config, trigger_attrs: list.append(existing, attrs))
  }
}

/// Append content attributes.
pub fn context_menu_content_attrs(
  config config: ContextMenuConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ContextMenuConfig(msg) {
  case config {
    ContextMenuConfig(content_attrs: existing, ..) ->
      ContextMenuConfig(..config, content_attrs: list.append(existing, attrs))
  }
}

/// Construct context menu item configuration.
pub fn context_menu_item_config(
  on_click on_click: fn() -> msg,
) -> ContextMenuItemConfig(msg) {
  ContextMenuItemConfig(
    on_click: on_click,
    disabled: False,
    variant: DefaultItem,
    attrs: [],
  )
}

/// Disable a context menu item.
pub fn context_menu_item_disabled(
  config config: ContextMenuItemConfig(msg),
) -> ContextMenuItemConfig(msg) {
  ContextMenuItemConfig(..config, disabled: True)
}

/// Set the variant of a context menu item.
pub fn context_menu_item_variant(
  config config: ContextMenuItemConfig(msg),
  variant variant: ContextMenuItemVariant,
) -> ContextMenuItemConfig(msg) {
  ContextMenuItemConfig(..config, variant: variant)
}

/// Append item attributes.
pub fn context_menu_item_attrs(
  config config: ContextMenuItemConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ContextMenuItemConfig(msg) {
  case config {
    ContextMenuItemConfig(attrs: existing, ..) ->
      ContextMenuItemConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Internal: read the `open` field from a `ContextMenuConfig`.
@internal
pub fn context_menu_config_open(config config: ContextMenuConfig(msg)) -> Bool {
  case config {
    ContextMenuConfig(open:, ..) -> open
  }
}

/// Internal: read the `on_open_change` function from a `ContextMenuConfig`.
@internal
pub fn context_menu_config_on_open_change(
  config config: ContextMenuConfig(msg),
) -> fn(Bool) -> msg {
  case config {
    ContextMenuConfig(on_open_change:, ..) -> on_open_change
  }
}

/// Internal: read the `on_click` function from a `ContextMenuItemConfig`.
@internal
pub fn context_menu_item_config_on_click(
  config config: ContextMenuItemConfig(msg),
) -> fn() -> msg {
  case config {
    ContextMenuItemConfig(on_click:, ..) -> on_click
  }
}

/// Internal: read the `disabled` field from a `ContextMenuItemConfig`.
@internal
pub fn context_menu_item_config_disabled(
  config config: ContextMenuItemConfig(msg),
) -> Bool {
  case config {
    ContextMenuItemConfig(disabled:, ..) -> disabled
  }
}

/// Internal: read the `variant` field from a `ContextMenuItemConfig`.
@internal
pub fn context_menu_item_config_variant(
  config config: ContextMenuItemConfig(msg),
) -> ContextMenuItemVariant {
  case config {
    ContextMenuItemConfig(variant:, ..) -> variant
  }
}

/// Internal: read the extra `attrs` from a `ContextMenuItemConfig`.
@internal
pub fn context_menu_item_config_attrs(
  config config: ContextMenuItemConfig(msg),
) -> List(weft_lustre.Attribute(msg)) {
  case config {
    ContextMenuItemConfig(attrs:, ..) -> attrs
  }
}

fn variant_to_string(variant: ContextMenuItemVariant) -> String {
  case variant {
    DefaultItem -> "default"
    DestructiveItem -> "destructive"
  }
}

/// Render headless context menu.
pub fn context_menu(
  config config: ContextMenuConfig(msg),
  trigger trigger: weft_lustre.Element(msg),
  items items: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  case config {
    ContextMenuConfig(
      open: open,
      on_open_change: on_open_change,
      attrs: attrs,
      trigger_attrs: trigger_attrs,
      content_attrs: content_attrs,
    ) -> {
      let content_el = case open {
        True -> [
          // Transparent scrim to close menu on outside click
          weft_lustre.element_tag(
            tag: "div",
            base_weft_attrs: [weft.el_layout()],
            attrs: [
              weft_lustre.styles([
                weft.position(value: weft.position_fixed()),
                weft.inset(length: weft.px(pixels: 0)),
              ]),
              weft_lustre.html_attribute(event.on_click(on_open_change(False))),
            ],
            children: [],
          ),
          // Menu content
          weft_lustre.column(
            attrs: [
              weft_lustre.html_attribute(attribute.role("menu")),
              weft_lustre.html_attribute(attribute.attribute(
                "data-slot",
                "context-menu-content",
              )),
              ..content_attrs
            ],
            children: items,
          ),
        ]
        False -> []
      }

      weft_lustre.column(
        attrs: [
          weft_lustre.styles([
            weft.display(value: weft.display_inline_flex()),
            weft.align_items(value: weft.align_items_start()),
            weft.position(value: weft.position_relative()),
          ]),
          ..attrs
        ],
        children: list.flatten([
          [
            weft_lustre.element_tag(
              tag: "div",
              base_weft_attrs: [weft.el_layout()],
              attrs: [
                weft_lustre.html_attribute(
                  event.prevent_default(event.on(
                    "contextmenu",
                    decode.success(on_open_change(!open)),
                  )),
                ),
                ..trigger_attrs
              ],
              children: [trigger],
            ),
          ],
          content_el,
        ]),
      )
    }
  }
}

/// Render a headless context menu item.
pub fn context_menu_item(
  config config: ContextMenuItemConfig(msg),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  case config {
    ContextMenuItemConfig(
      on_click: on_click,
      disabled: disabled,
      variant: variant,
      attrs: attrs,
    ) -> {
      let base_attrs = [
        weft_lustre.html_attribute(attribute.role("menuitem")),
        weft_lustre.html_attribute(attribute.attribute("tabindex", "-1")),
        weft_lustre.html_attribute(attribute.attribute(
          "data-variant",
          variant_to_string(variant),
        )),
      ]

      let disabled_attrs = case disabled {
        True -> [
          weft_lustre.html_attribute(attribute.attribute("data-disabled", "")),
          weft_lustre.html_attribute(attribute.attribute(
            "aria-disabled",
            "true",
          )),
        ]
        False -> [
          weft_lustre.html_attribute(event.on_click(on_click())),
        ]
      }

      let all_attrs = list.flatten([base_attrs, disabled_attrs, attrs])

      weft_lustre.row(attrs: all_attrs, children: children)
    }
  }
}

/// Render a context menu separator.
pub fn context_menu_separator() -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.el_layout()],
    attrs: [
      weft_lustre.html_attribute(attribute.role("separator")),
      weft_lustre.html_attribute(attribute.attribute(
        "data-slot",
        "context-menu-separator",
      )),
    ],
    children: [],
  )
}

/// Render a context menu label.
pub fn context_menu_label(
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.el_layout()],
    attrs: [
      weft_lustre.html_attribute(attribute.attribute(
        "data-slot",
        "context-menu-label",
      )),
    ],
    children: children,
  )
}
