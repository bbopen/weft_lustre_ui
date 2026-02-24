//// Headless menubar primitives for shadcn compatibility.
////
//// Uses semantic HTML (`details` + `summary`) to provide a dependency-free
//// menu surface with structural slots similar to shadcn's menubar.

import gleam/dynamic/decode
import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute
import lustre/event
import weft
import weft_lustre

type ItemVariantValue {
  Default
  Destructive
}

/// Menubar item variant token.
pub opaque type MenubarItemVariant {
  MenubarItemVariant(value: ItemVariantValue)
}

/// Default menubar item variant.
pub fn menubar_item_variant_default() -> MenubarItemVariant {
  MenubarItemVariant(value: Default)
}

/// Destructive menubar item variant.
pub fn menubar_item_variant_destructive() -> MenubarItemVariant {
  MenubarItemVariant(value: Destructive)
}

/// Menubar root configuration.
pub opaque type MenubarConfig(msg) {
  MenubarConfig(
    on_move_prev: Option(msg),
    on_move_next: Option(msg),
    on_close_all: Option(msg),
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default menubar configuration.
pub fn menubar_config() -> MenubarConfig(msg) {
  MenubarConfig(
    on_move_prev: None,
    on_move_next: None,
    on_close_all: None,
    attrs: [],
  )
}

/// Append menubar root attributes.
pub fn menubar_attrs(
  config config: MenubarConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> MenubarConfig(msg) {
  case config {
    MenubarConfig(attrs: existing, ..) ->
      MenubarConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Set message dispatched for left-arrow menu traversal.
pub fn menubar_on_move_prev(
  config config: MenubarConfig(msg),
  on_move_prev on_move_prev: msg,
) -> MenubarConfig(msg) {
  MenubarConfig(..config, on_move_prev: Some(on_move_prev))
}

/// Set message dispatched for right-arrow menu traversal.
pub fn menubar_on_move_next(
  config config: MenubarConfig(msg),
  on_move_next on_move_next: msg,
) -> MenubarConfig(msg) {
  MenubarConfig(..config, on_move_next: Some(on_move_next))
}

/// Set message dispatched to close all menus on Escape.
pub fn menubar_on_close_all(
  config config: MenubarConfig(msg),
  on_close_all on_close_all: msg,
) -> MenubarConfig(msg) {
  MenubarConfig(..config, on_close_all: Some(on_close_all))
}

/// Menubar menu wrapper configuration.
pub opaque type MenubarMenuConfig(msg) {
  MenubarMenuConfig(
    id: String,
    open: Bool,
    on_open_change: Option(fn(Bool) -> msg),
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default menubar menu configuration.
pub fn menubar_menu_config(id id: String) -> MenubarMenuConfig(msg) {
  MenubarMenuConfig(id: id, open: False, on_open_change: None, attrs: [])
}

/// Set open state for a menu wrapper.
pub fn menubar_menu_open(
  config config: MenubarMenuConfig(msg),
  open open: Bool,
) -> MenubarMenuConfig(msg) {
  MenubarMenuConfig(..config, open: open)
}

/// Set open-state change handler for a menu wrapper.
pub fn menubar_menu_on_open_change(
  config config: MenubarMenuConfig(msg),
  on_open_change on_open_change: fn(Bool) -> msg,
) -> MenubarMenuConfig(msg) {
  MenubarMenuConfig(..config, on_open_change: Some(on_open_change))
}

/// Append menu wrapper attributes.
pub fn menubar_menu_attrs(
  config config: MenubarMenuConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> MenubarMenuConfig(msg) {
  case config {
    MenubarMenuConfig(attrs: existing, ..) ->
      MenubarMenuConfig(..config, attrs: list.append(existing, attrs))
  }
}

fn first_key_message(
  on_move_prev: Option(msg),
  on_move_next: Option(msg),
  on_close_all: Option(msg),
) -> Option(msg) {
  case on_move_prev {
    Some(msg) -> Some(msg)
    None ->
      case on_move_next {
        Some(msg) -> Some(msg)
        None -> on_close_all
      }
  }
}

fn keydown_attr(
  fallback fallback: msg,
  on_move_prev on_move_prev: Option(msg),
  on_move_next on_move_next: Option(msg),
  on_close_all on_close_all: Option(msg),
) -> weft_lustre.Attribute(msg) {
  weft_lustre.html_attribute(
    event.advanced("keydown", {
      use key <- decode.field("key", decode.string)
      case key {
        "ArrowLeft" ->
          case on_move_prev {
            Some(message) ->
              decode.success(event.handler(
                dispatch: message,
                prevent_default: True,
                stop_propagation: False,
              ))
            None ->
              decode.failure(
                event.handler(
                  dispatch: fallback,
                  prevent_default: False,
                  stop_propagation: False,
                ),
                "arrow-left-unhandled",
              )
          }
        "ArrowRight" ->
          case on_move_next {
            Some(message) ->
              decode.success(event.handler(
                dispatch: message,
                prevent_default: True,
                stop_propagation: False,
              ))
            None ->
              decode.failure(
                event.handler(
                  dispatch: fallback,
                  prevent_default: False,
                  stop_propagation: False,
                ),
                "arrow-right-unhandled",
              )
          }
        "Escape" ->
          case on_close_all {
            Some(message) ->
              decode.success(event.handler(
                dispatch: message,
                prevent_default: True,
                stop_propagation: False,
              ))
            None ->
              decode.failure(
                event.handler(
                  dispatch: fallback,
                  prevent_default: False,
                  stop_propagation: False,
                ),
                "escape-unhandled",
              )
          }
        _ ->
          decode.failure(
            event.handler(
              dispatch: fallback,
              prevent_default: False,
              stop_propagation: False,
            ),
            "non-menubar-key",
          )
      }
    }),
  )
}

/// Menubar item configuration.
pub opaque type MenubarItemConfig(msg) {
  MenubarItemConfig(
    inset: Bool,
    variant: MenubarItemVariant,
    disabled: Bool,
    on_select: Option(msg),
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default menubar item configuration.
pub fn menubar_item_config() -> MenubarItemConfig(msg) {
  MenubarItemConfig(
    inset: False,
    variant: menubar_item_variant_default(),
    disabled: False,
    on_select: None,
    attrs: [],
  )
}

/// Set item as inset.
pub fn menubar_item_inset(
  config config: MenubarItemConfig(msg),
) -> MenubarItemConfig(msg) {
  MenubarItemConfig(..config, inset: True)
}

/// Set item variant.
pub fn menubar_item_variant(
  config config: MenubarItemConfig(msg),
  variant variant: MenubarItemVariant,
) -> MenubarItemConfig(msg) {
  MenubarItemConfig(..config, variant: variant)
}

/// Mark item disabled.
pub fn menubar_item_disabled(
  config config: MenubarItemConfig(msg),
) -> MenubarItemConfig(msg) {
  MenubarItemConfig(..config, disabled: True)
}

/// Set item on-select message.
pub fn menubar_item_on_select(
  config config: MenubarItemConfig(msg),
  on_select on_select: msg,
) -> MenubarItemConfig(msg) {
  MenubarItemConfig(..config, on_select: Some(on_select))
}

/// Append item attributes.
pub fn menubar_item_attrs(
  config config: MenubarItemConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> MenubarItemConfig(msg) {
  case config {
    MenubarItemConfig(attrs: existing, ..) ->
      MenubarItemConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Menubar checkbox item configuration.
pub opaque type MenubarCheckboxItemConfig(msg) {
  MenubarCheckboxItemConfig(
    checked: Bool,
    on_toggle: fn(Bool) -> msg,
    disabled: Bool,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a menubar checkbox item configuration.
pub fn menubar_checkbox_item_config(
  checked checked: Bool,
  on_toggle on_toggle: fn(Bool) -> msg,
) -> MenubarCheckboxItemConfig(msg) {
  MenubarCheckboxItemConfig(
    checked: checked,
    on_toggle: on_toggle,
    disabled: False,
    attrs: [],
  )
}

/// Mark checkbox item disabled.
pub fn menubar_checkbox_item_disabled(
  config config: MenubarCheckboxItemConfig(msg),
) -> MenubarCheckboxItemConfig(msg) {
  MenubarCheckboxItemConfig(..config, disabled: True)
}

/// Append checkbox item attributes.
pub fn menubar_checkbox_item_attrs(
  config config: MenubarCheckboxItemConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> MenubarCheckboxItemConfig(msg) {
  case config {
    MenubarCheckboxItemConfig(attrs: existing, ..) ->
      MenubarCheckboxItemConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Menubar radio item configuration.
pub opaque type MenubarRadioItemConfig(msg) {
  MenubarRadioItemConfig(
    name: String,
    value: String,
    checked: Bool,
    on_select: fn(String) -> msg,
    disabled: Bool,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a menubar radio item configuration.
pub fn menubar_radio_item_config(
  name name: String,
  value value: String,
  checked checked: Bool,
  on_select on_select: fn(String) -> msg,
) -> MenubarRadioItemConfig(msg) {
  MenubarRadioItemConfig(
    name: name,
    value: value,
    checked: checked,
    on_select: on_select,
    disabled: False,
    attrs: [],
  )
}

/// Mark radio item disabled.
pub fn menubar_radio_item_disabled(
  config config: MenubarRadioItemConfig(msg),
) -> MenubarRadioItemConfig(msg) {
  MenubarRadioItemConfig(..config, disabled: True)
}

/// Append radio item attributes.
pub fn menubar_radio_item_attrs(
  config config: MenubarRadioItemConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> MenubarRadioItemConfig(msg) {
  case config {
    MenubarRadioItemConfig(attrs: existing, ..) ->
      MenubarRadioItemConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Internal: read item variant.
@internal
pub fn menubar_item_config_variant(
  config config: MenubarItemConfig(msg),
) -> MenubarItemVariant {
  case config {
    MenubarItemConfig(variant:, ..) -> variant
  }
}

/// Internal: read item inset flag.
@internal
pub fn menubar_item_config_inset(config config: MenubarItemConfig(msg)) -> Bool {
  case config {
    MenubarItemConfig(inset:, ..) -> inset
  }
}

/// Internal: variant is destructive.
@internal
pub fn menubar_item_variant_is_destructive(
  variant variant: MenubarItemVariant,
) -> Bool {
  case variant {
    MenubarItemVariant(value: Destructive) -> True
    MenubarItemVariant(value: Default) -> False
  }
}

/// Render menubar root.
pub fn menubar(
  config config: MenubarConfig(msg),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  case config {
    MenubarConfig(
      on_move_prev: on_move_prev,
      on_move_next: on_move_next,
      on_close_all: on_close_all,
      attrs: attrs,
    ) -> {
      let keyboard_attrs = case
        first_key_message(on_move_prev, on_move_next, on_close_all)
      {
        Some(fallback) -> [
          keydown_attr(
            fallback: fallback,
            on_move_prev: on_move_prev,
            on_move_next: on_move_next,
            on_close_all: on_close_all,
          ),
        ]
        None -> []
      }

      weft_lustre.element_tag(
        tag: "div",
        base_weft_attrs: [weft.row_layout()],
        attrs: list.flatten([
          [
            weft_lustre.html_attribute(attribute.role("menubar")),
            weft_lustre.html_attribute(attribute.attribute(
              "data-slot",
              "menubar",
            )),
          ],
          keyboard_attrs,
          attrs,
        ]),
        children: children,
      )
    }
  }
}

/// Render a menubar menu wrapper.
pub fn menubar_menu(
  config config: MenubarMenuConfig(msg),
  trigger trigger: weft_lustre.Element(msg),
  content content: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  case config {
    MenubarMenuConfig(
      id: id,
      open: open,
      on_open_change: on_open_change,
      attrs: attrs,
    ) -> {
      let summary_attrs = case on_open_change {
        Some(on_open_change) -> [
          weft_lustre.html_attribute(event.on_click(on_open_change(!open))),
        ]
        None -> []
      }

      weft_lustre.element_tag(
        tag: "details",
        base_weft_attrs: [weft.el_layout()],
        attrs: list.flatten([
          [
            weft_lustre.html_attribute(attribute.open(open)),
            weft_lustre.html_attribute(attribute.attribute(
              "data-slot",
              "menubar-menu",
            )),
            weft_lustre.html_attribute(
              attribute.attribute("data-state", case open {
                True -> "open"
                False -> "closed"
              }),
            ),
            weft_lustre.html_attribute(attribute.attribute("data-menu-id", id)),
          ],
          attrs,
        ]),
        children: [
          weft_lustre.element_tag(
            tag: "summary",
            base_weft_attrs: [weft.el_layout()],
            attrs: summary_attrs,
            children: [trigger],
          ),
          content,
        ],
      )
    }
  }
}

/// Render a menubar group.
pub fn menubar_group(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.column_layout()],
    attrs: list.append(
      [
        weft_lustre.html_attribute(attribute.role("group")),
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "menubar-group",
        )),
      ],
      attrs,
    ),
    children: children,
  )
}

/// Render a menubar portal wrapper.
pub fn menubar_portal(
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.in_front(child: weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.el_layout()],
    attrs: [
      weft_lustre.html_attribute(attribute.attribute(
        "data-slot",
        "menubar-portal",
      )),
    ],
    children: children,
  ))
}

/// Render a menubar radio-group wrapper.
pub fn menubar_radio_group(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.column_layout()],
    attrs: list.append(
      [
        weft_lustre.html_attribute(attribute.role("group")),
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "menubar-radio-group",
        )),
      ],
      attrs,
    ),
    children: children,
  )
}

/// Render a menubar trigger.
pub fn menubar_trigger(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  child child: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "span",
    base_weft_attrs: [weft.el_layout()],
    attrs: list.append(
      [
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "menubar-trigger",
        )),
      ],
      attrs,
    ),
    children: [child],
  )
}

/// Render menubar content.
pub fn menubar_content(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.column_layout()],
    attrs: list.append(
      [
        weft_lustre.html_attribute(attribute.role("menu")),
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "menubar-content",
        )),
      ],
      attrs,
    ),
    children: children,
  )
}

/// Render a menubar item.
pub fn menubar_item(
  config config: MenubarItemConfig(msg),
  child child: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  case config {
    MenubarItemConfig(
      inset: inset,
      variant: variant,
      disabled: disabled,
      on_select: on_select,
      attrs: attrs,
    ) -> {
      let click_attrs = case disabled, on_select {
        True, _ -> []
        False, Some(message) -> [
          weft_lustre.html_attribute(event.on_click(message)),
        ]
        False, None -> []
      }

      weft_lustre.element_tag(
        tag: "button",
        base_weft_attrs: [weft.el_layout()],
        attrs: list.flatten([
          [weft_lustre.html_attribute(attribute.type_("button"))],
          [weft_lustre.html_attribute(attribute.role("menuitem"))],
          [
            weft_lustre.html_attribute(attribute.attribute(
              "data-slot",
              "menubar-item",
            )),
          ],
          [
            weft_lustre.html_attribute(
              attribute.attribute("data-variant", case variant {
                MenubarItemVariant(value: Default) -> "default"
                MenubarItemVariant(value: Destructive) -> "destructive"
              }),
            ),
          ],
          case inset {
            True -> [
              weft_lustre.html_attribute(attribute.attribute(
                "data-inset",
                "true",
              )),
            ]
            False -> []
          },
          case disabled {
            True -> [
              weft_lustre.html_attribute(attribute.disabled(True)),
              weft_lustre.html_attribute(attribute.attribute(
                "data-disabled",
                "true",
              )),
            ]
            False -> []
          },
          click_attrs,
          attrs,
        ]),
        children: [child],
      )
    }
  }
}

/// Render a menubar checkbox item.
pub fn menubar_checkbox_item(
  config config: MenubarCheckboxItemConfig(msg),
  child child: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  case config {
    MenubarCheckboxItemConfig(
      checked: checked,
      on_toggle: on_toggle,
      disabled: disabled,
      attrs: attrs,
    ) -> {
      let click_attrs = case disabled {
        True -> []
        False -> [
          weft_lustre.html_attribute(event.on_click(on_toggle(!checked))),
        ]
      }

      weft_lustre.element_tag(
        tag: "button",
        base_weft_attrs: [weft.el_layout()],
        attrs: list.flatten([
          [weft_lustre.html_attribute(attribute.type_("button"))],
          [
            weft_lustre.html_attribute(attribute.attribute(
              "role",
              "menuitemcheckbox",
            )),
          ],
          [
            weft_lustre.html_attribute(
              attribute.attribute("aria-checked", case checked {
                True -> "true"
                False -> "false"
              }),
            ),
          ],
          [
            weft_lustre.html_attribute(attribute.attribute(
              "data-slot",
              "menubar-checkbox-item",
            )),
          ],
          case disabled {
            True -> [weft_lustre.html_attribute(attribute.disabled(True))]
            False -> []
          },
          click_attrs,
          attrs,
        ]),
        children: [child],
      )
    }
  }
}

/// Render a menubar radio item.
pub fn menubar_radio_item(
  config config: MenubarRadioItemConfig(msg),
  child child: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  case config {
    MenubarRadioItemConfig(
      name: name,
      value: value,
      checked: checked,
      on_select: on_select,
      disabled: disabled,
      attrs: attrs,
    ) -> {
      let click_attrs = case disabled {
        True -> []
        False -> [weft_lustre.html_attribute(event.on_click(on_select(value)))]
      }

      weft_lustre.element_tag(
        tag: "button",
        base_weft_attrs: [weft.el_layout()],
        attrs: list.flatten([
          [weft_lustre.html_attribute(attribute.type_("button"))],
          [
            weft_lustre.html_attribute(attribute.attribute(
              "role",
              "menuitemradio",
            )),
          ],
          [weft_lustre.html_attribute(attribute.name(name))],
          [weft_lustre.html_attribute(attribute.value(value))],
          [
            weft_lustre.html_attribute(
              attribute.attribute("aria-checked", case checked {
                True -> "true"
                False -> "false"
              }),
            ),
          ],
          [
            weft_lustre.html_attribute(attribute.attribute(
              "data-slot",
              "menubar-radio-item",
            )),
          ],
          case disabled {
            True -> [weft_lustre.html_attribute(attribute.disabled(True))]
            False -> []
          },
          click_attrs,
          attrs,
        ]),
        children: [child],
      )
    }
  }
}

/// Render a menubar label.
pub fn menubar_label(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  child child: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.el_layout()],
    attrs: list.append(
      [
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "menubar-label",
        )),
      ],
      attrs,
    ),
    children: [child],
  )
}

/// Render a menubar separator.
pub fn menubar_separator(
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.el_layout()],
    attrs: list.append(
      [
        weft_lustre.html_attribute(attribute.role("separator")),
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "menubar-separator",
        )),
      ],
      attrs,
    ),
    children: [],
  )
}

/// Render a menubar shortcut slot.
pub fn menubar_shortcut(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  child child: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "span",
    base_weft_attrs: [weft.el_layout()],
    attrs: list.append(
      [
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "menubar-shortcut",
        )),
      ],
      attrs,
    ),
    children: [child],
  )
}

/// Render a menubar sub-menu wrapper.
pub fn menubar_sub(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  trigger trigger: weft_lustre.Element(msg),
  content content: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "details",
    base_weft_attrs: [weft.el_layout()],
    attrs: list.append(
      [
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "menubar-sub",
        )),
      ],
      attrs,
    ),
    children: [
      weft_lustre.element_tag(
        tag: "summary",
        base_weft_attrs: [weft.el_layout()],
        attrs: [],
        children: [trigger],
      ),
      content,
    ],
  )
}

/// Render a menubar sub-trigger.
pub fn menubar_sub_trigger(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  child child: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "span",
    base_weft_attrs: [weft.el_layout()],
    attrs: list.append(
      [
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "menubar-sub-trigger",
        )),
      ],
      attrs,
    ),
    children: [child],
  )
}

/// Render menubar sub-content.
pub fn menubar_sub_content(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.column_layout()],
    attrs: list.append(
      [
        weft_lustre.html_attribute(attribute.role("menu")),
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "menubar-sub-content",
        )),
      ],
      attrs,
    ),
    children: children,
  )
}
