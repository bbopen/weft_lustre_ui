//// Headless sidebar shell primitives for weft_lustre_ui.

import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute
import lustre/event
import weft
import weft_lustre

/// Sidebar configuration.
pub opaque type SidebarConfig(msg) {
  SidebarConfig(
    collapsed: Bool,
    attrs: List(weft_lustre.Attribute(msg)),
    aside_attrs: List(weft_lustre.Attribute(msg)),
    inset_attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct sidebar configuration.
pub fn sidebar_config() -> SidebarConfig(msg) {
  SidebarConfig(collapsed: False, attrs: [], aside_attrs: [], inset_attrs: [])
}

/// Collapse the sidebar.
pub fn sidebar_collapsed(
  config config: SidebarConfig(msg),
) -> SidebarConfig(msg) {
  SidebarConfig(..config, collapsed: True)
}

/// Expand the sidebar.
pub fn sidebar_expanded(config config: SidebarConfig(msg)) -> SidebarConfig(msg) {
  SidebarConfig(..config, collapsed: False)
}

/// Read whether the sidebar is collapsed.
pub fn sidebar_is_collapsed(config config: SidebarConfig(msg)) -> Bool {
  case config {
    SidebarConfig(collapsed:, ..) -> collapsed
  }
}

/// Append attributes on the root shell.
pub fn sidebar_attrs(
  config config: SidebarConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> SidebarConfig(msg) {
  case config {
    SidebarConfig(attrs: existing, ..) ->
      SidebarConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Append attributes on the `<aside>` shell.
pub fn sidebar_aside_attrs(
  config config: SidebarConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> SidebarConfig(msg) {
  case config {
    SidebarConfig(aside_attrs: existing, ..) ->
      SidebarConfig(..config, aside_attrs: list.append(existing, attrs))
  }
}

/// Append attributes on the `<main>` inset shell.
pub fn sidebar_inset_attrs(
  config config: SidebarConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> SidebarConfig(msg) {
  case config {
    SidebarConfig(inset_attrs: existing, ..) ->
      SidebarConfig(..config, inset_attrs: list.append(existing, attrs))
  }
}

/// Render headless sidebar shell.
pub fn sidebar(
  config config: SidebarConfig(msg),
  header header: weft_lustre.Element(msg),
  body body: List(weft_lustre.Element(msg)),
  footer footer: weft_lustre.Element(msg),
  inset inset: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  case config {
    SidebarConfig(
      attrs: attrs,
      aside_attrs: aside_attrs,
      inset_attrs: inset_attrs,
      ..,
    ) ->
      weft_lustre.row(attrs: attrs, children: [
        weft_lustre.element_tag(
          tag: "aside",
          base_weft_attrs: [weft.column_layout()],
          attrs: aside_attrs,
          children: [
            header,
            weft_lustre.column(
              attrs: [weft_lustre.styles([weft.height(length: weft.fill())])],
              children: body,
            ),
            footer,
          ],
        ),
        weft_lustre.element_tag(
          tag: "main",
          base_weft_attrs: [
            weft.el_layout(),
            weft.width(length: weft.fill()),
          ],
          attrs: inset_attrs,
          children: [inset],
        ),
      ])
  }
}

/// A nav group container — optional label + list of menu items.
pub fn sidebar_group(
  label label: Option(String),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let label_el = case label {
    None -> weft_lustre.none()
    Some(text) -> weft_lustre.text(content: text)
  }
  weft_lustre.column(attrs: [], children: [label_el, ..children])
}

/// An ordered list (`<ul>`) wrapper for nav items.
pub fn sidebar_menu(
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "ul",
    base_weft_attrs: [weft.el_layout()],
    attrs: [],
    children: children,
  )
}

/// A single nav item container (`<li>`).
///
/// Marks the element with `weft.group("sidebar-item")` for hover-reveal support.
pub fn sidebar_menu_item(
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "li",
    base_weft_attrs: [weft.el_layout(), weft.group(name: "sidebar-item")],
    attrs: [],
    children: children,
  )
}

/// Configuration for a sidebar menu button (nav link/action).
pub opaque type SidebarMenuButtonConfig(msg) {
  SidebarMenuButtonConfig(
    label: weft_lustre.Element(msg),
    active: Bool,
    on_click: Option(fn() -> msg),
    href: Option(String),
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a sidebar menu button config.
pub fn sidebar_menu_button_config(
  label label: weft_lustre.Element(msg),
) -> SidebarMenuButtonConfig(msg) {
  SidebarMenuButtonConfig(
    label: label,
    active: False,
    on_click: None,
    href: None,
    attrs: [],
  )
}

/// Mark the button as the currently active nav item.
pub fn sidebar_menu_button_active(
  config config: SidebarMenuButtonConfig(msg),
) -> SidebarMenuButtonConfig(msg) {
  SidebarMenuButtonConfig(..config, active: True)
}

/// Set the click handler.
pub fn sidebar_menu_button_on_click(
  config config: SidebarMenuButtonConfig(msg),
  on_click on_click: fn() -> msg,
) -> SidebarMenuButtonConfig(msg) {
  SidebarMenuButtonConfig(..config, on_click: Some(on_click))
}

/// Set the href (renders as `<a>` instead of `<button>`).
pub fn sidebar_menu_button_href(
  config config: SidebarMenuButtonConfig(msg),
  href href: String,
) -> SidebarMenuButtonConfig(msg) {
  SidebarMenuButtonConfig(..config, href: Some(href))
}

/// Append extra attributes to the button.
pub fn sidebar_menu_button_attrs(
  config config: SidebarMenuButtonConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> SidebarMenuButtonConfig(msg) {
  case config {
    SidebarMenuButtonConfig(attrs: existing, ..) ->
      SidebarMenuButtonConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Internal: read whether the button is marked as active.
@internal
pub fn sidebar_menu_button_is_active(
  config config: SidebarMenuButtonConfig(msg),
) -> Bool {
  case config {
    SidebarMenuButtonConfig(active:, ..) -> active
  }
}

/// A nav action/link button.
pub fn sidebar_menu_button(
  config config: SidebarMenuButtonConfig(msg),
) -> weft_lustre.Element(msg) {
  case config {
    SidebarMenuButtonConfig(
      label: label,
      on_click: on_click,
      href: href,
      attrs: attrs,
      ..,
    ) -> {
      case href {
        Some(h) -> {
          let html_attrs = [weft_lustre.html_attribute(attribute.href(h))]
          weft_lustre.element_tag(
            tag: "a",
            base_weft_attrs: [weft.el_layout()],
            attrs: list.append(attrs, html_attrs),
            children: [label],
          )
        }
        None -> {
          let click_attrs = case on_click {
            None -> []
            Some(handler) -> [
              weft_lustre.html_attribute(event.on_click(handler())),
            ]
          }
          let html_attrs = [
            weft_lustre.html_attribute(attribute.type_("button")),
            ..click_attrs
          ]
          weft_lustre.element_tag(
            tag: "button",
            base_weft_attrs: [weft.el_layout()],
            attrs: list.append(attrs, html_attrs),
            children: [label],
          )
        }
      }
    }
  }
}

/// Configuration for a sidebar menu action button.
pub opaque type SidebarMenuActionConfig(msg) {
  SidebarMenuActionConfig(
    show_on_hover: Bool,
    on_click: fn() -> msg,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a sidebar menu action config.
pub fn sidebar_menu_action_config(
  on_click on_click: fn() -> msg,
) -> SidebarMenuActionConfig(msg) {
  SidebarMenuActionConfig(show_on_hover: False, on_click: on_click, attrs: [])
}

/// Make this action button visible only when the parent menu item is hovered.
pub fn sidebar_menu_action_show_on_hover(
  config config: SidebarMenuActionConfig(msg),
) -> SidebarMenuActionConfig(msg) {
  SidebarMenuActionConfig(..config, show_on_hover: True)
}

/// Append extra attributes to the action button.
pub fn sidebar_menu_action_attrs(
  config config: SidebarMenuActionConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> SidebarMenuActionConfig(msg) {
  case config {
    SidebarMenuActionConfig(attrs: existing, ..) ->
      SidebarMenuActionConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// An action button that can optionally reveal only on hover.
pub fn sidebar_menu_action(
  config config: SidebarMenuActionConfig(msg),
  content content: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  case config {
    SidebarMenuActionConfig(
      show_on_hover: show_on_hover,
      on_click: on_click,
      attrs: attrs,
    ) -> {
      let hover_attrs = case show_on_hover {
        False -> []
        True -> [
          weft_lustre.styles([
            weft.alpha(opacity: 0.0),
            weft.group_hover(group: "sidebar-item", attrs: [
              weft.alpha(opacity: 1.0),
            ]),
            weft.transition(
              property: weft.transition_property_opacity(),
              duration: weft.ms(milliseconds: 150),
              easing: weft.ease(),
            ),
          ]),
        ]
      }
      let html_attrs = [
        weft_lustre.html_attribute(attribute.type_("button")),
        weft_lustre.html_attribute(event.on_click(on_click())),
      ]
      weft_lustre.element_tag(
        tag: "button",
        base_weft_attrs: [weft.el_layout()],
        attrs: list.flatten([attrs, hover_attrs, html_attrs]),
        children: [content],
      )
    }
  }
}

/// An inline count badge for nav items (e.g., unread count).
pub fn sidebar_menu_badge(text text: String) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "span",
    base_weft_attrs: [weft.el_layout()],
    attrs: [],
    children: [weft_lustre.text(content: text)],
  )
}
