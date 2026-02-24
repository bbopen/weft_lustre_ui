//// Headless navigation-menu primitives for shadcn compatibility.
////
//// Provides structural slots (`navigation_menu`, `list`, `item`, `trigger`,
//// `content`, `link`, `indicator`, `viewport`) without visual styling.

import gleam/list
import lustre/attribute
import weft
import weft_lustre

/// Headless navigation-menu configuration.
pub opaque type NavigationMenuConfig(msg) {
  NavigationMenuConfig(
    viewport_enabled: Bool,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default navigation-menu configuration.
pub fn navigation_menu_config() -> NavigationMenuConfig(msg) {
  NavigationMenuConfig(viewport_enabled: True, attrs: [])
}

/// Enable or disable viewport semantics on the root.
pub fn navigation_menu_viewport_enabled(
  config config: NavigationMenuConfig(msg),
  enabled enabled: Bool,
) -> NavigationMenuConfig(msg) {
  NavigationMenuConfig(..config, viewport_enabled: enabled)
}

/// Append root attributes.
pub fn navigation_menu_attrs(
  config config: NavigationMenuConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> NavigationMenuConfig(msg) {
  case config {
    NavigationMenuConfig(attrs: existing, ..) ->
      NavigationMenuConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Internal: read viewport enabled state.
@internal
pub fn navigation_menu_config_viewport_enabled(
  config config: NavigationMenuConfig(msg),
) -> Bool {
  case config {
    NavigationMenuConfig(viewport_enabled:, ..) -> viewport_enabled
  }
}

/// Trigger baseline style attributes for navigation-menu triggers.
pub fn navigation_menu_trigger_style() -> List(weft.Attribute) {
  [
    weft.display(value: weft.display_inline_flex()),
    weft.align_items(value: weft.align_items_center()),
    weft.justify_content(value: weft.justify_center()),
    weft.height(length: weft.fixed(length: weft.px(pixels: 36))),
    weft.padding_xy(x: 16, y: 8),
    weft.rounded(radius: weft.px(pixels: 8)),
  ]
}

/// Render the root navigation-menu container.
pub fn navigation_menu(
  config config: NavigationMenuConfig(msg),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  case config {
    NavigationMenuConfig(viewport_enabled: viewport_enabled, attrs: attrs) -> {
      let children = case viewport_enabled {
        True ->
          list.append(children, [
            navigation_menu_viewport(attrs: [], children: []),
          ])
        False -> children
      }

      weft_lustre.element_tag(
        tag: "nav",
        base_weft_attrs: [weft.row_layout()],
        attrs: list.append(
          [
            weft_lustre.html_attribute(attribute.attribute(
              "data-slot",
              "navigation-menu",
            )),
            weft_lustre.html_attribute(
              attribute.attribute("data-viewport", case viewport_enabled {
                True -> "true"
                False -> "false"
              }),
            ),
          ],
          attrs,
        ),
        children: children,
      )
    }
  }
}

/// Render a navigation-menu list container.
pub fn navigation_menu_list(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "ul",
    base_weft_attrs: [weft.row_layout()],
    attrs: list.append(
      [
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "navigation-menu-list",
        )),
      ],
      attrs,
    ),
    children: children,
  )
}

/// Render a navigation-menu item container.
pub fn navigation_menu_item(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "li",
    base_weft_attrs: [weft.el_layout()],
    attrs: list.append(
      [
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "navigation-menu-item",
        )),
      ],
      attrs,
    ),
    children: children,
  )
}

/// Render a navigation-menu trigger.
pub fn navigation_menu_trigger(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  child child: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "button",
    base_weft_attrs: [weft.el_layout()],
    attrs: list.flatten([
      [weft_lustre.html_attribute(attribute.type_("button"))],
      [
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "navigation-menu-trigger",
        )),
      ],
      attrs,
    ]),
    children: [child],
  )
}

/// Render navigation-menu content.
pub fn navigation_menu_content(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.el_layout()],
    attrs: list.append(
      [
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "navigation-menu-content",
        )),
      ],
      attrs,
    ),
    children: children,
  )
}

/// Render navigation-menu viewport.
pub fn navigation_menu_viewport(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.el_layout()],
    attrs: list.append(
      [
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "navigation-menu-viewport",
        )),
      ],
      attrs,
    ),
    children: children,
  )
}

/// Render a navigation-menu link.
pub fn navigation_menu_link(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  child child: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "a",
    base_weft_attrs: [weft.el_layout()],
    attrs: list.append(
      [
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "navigation-menu-link",
        )),
      ],
      attrs,
    ),
    children: [child],
  )
}

/// Render a navigation-menu indicator.
pub fn navigation_menu_indicator(
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
          "navigation-menu-indicator",
        )),
      ],
      attrs,
    ),
    children: [child],
  )
}
