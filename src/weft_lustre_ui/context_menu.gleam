//// Styled context menu component for weft_lustre_ui.
////
//// A context menu is triggered by right-click. This module applies
//// theme-driven styling over the headless context menu.

import gleam/list
import lustre/attribute
import lustre/event
import weft
import weft_lustre
import weft_lustre_ui/headless/context_menu as headless_context_menu
import weft_lustre_ui/theme

/// Styled context menu configuration alias.
pub type ContextMenuConfig(msg) =
  headless_context_menu.ContextMenuConfig(msg)

/// Styled context menu item configuration alias.
pub type ContextMenuItemConfig(msg) =
  headless_context_menu.ContextMenuItemConfig(msg)

/// Context menu item variant alias.
pub type ContextMenuItemVariant =
  headless_context_menu.ContextMenuItemVariant

/// Default menu item style.
pub const default_item = headless_context_menu.DefaultItem

/// Destructive / danger menu item style.
pub const destructive_item = headless_context_menu.DestructiveItem

/// Construct context menu configuration.
pub fn context_menu_config(
  open open: Bool,
  on_open_change on_open_change: fn(Bool) -> msg,
) -> ContextMenuConfig(msg) {
  headless_context_menu.context_menu_config(
    open: open,
    on_open_change: on_open_change,
  )
}

/// Append root attributes.
pub fn context_menu_attrs(
  config config: ContextMenuConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ContextMenuConfig(msg) {
  headless_context_menu.context_menu_attrs(config: config, attrs: attrs)
}

/// Append trigger attributes.
pub fn context_menu_trigger_attrs(
  config config: ContextMenuConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ContextMenuConfig(msg) {
  headless_context_menu.context_menu_trigger_attrs(config: config, attrs: attrs)
}

/// Append content attributes.
pub fn context_menu_content_attrs(
  config config: ContextMenuConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ContextMenuConfig(msg) {
  headless_context_menu.context_menu_content_attrs(config: config, attrs: attrs)
}

/// Construct context menu item configuration.
pub fn context_menu_item_config(
  on_click on_click: fn() -> msg,
) -> ContextMenuItemConfig(msg) {
  headless_context_menu.context_menu_item_config(on_click: on_click)
}

/// Disable a context menu item.
pub fn context_menu_item_disabled(
  config config: ContextMenuItemConfig(msg),
) -> ContextMenuItemConfig(msg) {
  headless_context_menu.context_menu_item_disabled(config: config)
}

/// Set the variant of a context menu item.
pub fn context_menu_item_variant(
  config config: ContextMenuItemConfig(msg),
  variant variant: ContextMenuItemVariant,
) -> ContextMenuItemConfig(msg) {
  headless_context_menu.context_menu_item_variant(
    config: config,
    variant: variant,
  )
}

/// Append item attributes.
pub fn context_menu_item_attrs(
  config config: ContextMenuItemConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ContextMenuItemConfig(msg) {
  headless_context_menu.context_menu_item_attrs(config: config, attrs: attrs)
}

fn bool_to_string(value: Bool) -> String {
  case value {
    True -> "true"
    False -> "false"
  }
}

fn content_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  let #(overlay_bg, overlay_fg) = theme.overlay_surface(theme)

  [
    weft.position(value: weft.position_absolute()),
    weft.top(length: weft.pct(pct: 100.0)),
    weft.left(length: weft.px(pixels: 0)),
    weft.width(length: weft.minimum(
      base: weft.shrink(),
      min: weft.px(pixels: 128),
    )),
    weft.padding(pixels: 4),
    weft.background(color: overlay_bg),
    weft.text_color(color: overlay_fg),
    weft.rounded(radius: theme.radius_md(theme)),
    weft.border(
      width: weft.px(pixels: 1),
      style: weft.border_style_solid(),
      color: theme.border_color(theme),
    ),
    weft.shadows(shadows: [
      weft.shadow(
        x: weft.px(pixels: 0),
        y: weft.px(pixels: 8),
        blur: weft.px(pixels: 24),
        spread: weft.px(pixels: -6),
        color: theme.tooltip_shadow(theme),
      ),
    ]),
    weft.font_family(families: theme.font_families(theme)),
    weft.font_size(size: weft.rem(rem: 0.875)),
  ]
}

fn item_styles(
  theme theme: theme.Theme,
  variant variant: headless_context_menu.ContextMenuItemVariant,
  disabled disabled: Bool,
) -> List(weft.Attribute) {
  let base = [
    weft.padding_xy(x: 8, y: 6),
    weft.rounded(radius: weft.px(pixels: 4)),
    weft.spacing(pixels: 8),
    weft.align_items(value: weft.align_items_center()),
    weft.cursor(cursor: case disabled {
      True -> weft.cursor_not_allowed()
      False -> weft.cursor_pointer()
    }),
  ]

  let variant_styles = case variant {
    headless_context_menu.DestructiveItem -> {
      let #(danger_bg, _) = theme.danger(theme)
      [weft.text_color(color: danger_bg)]
    }
    headless_context_menu.DefaultItem -> []
  }

  let disabled_styles = case disabled {
    True -> [weft.alpha(opacity: theme.disabled_opacity(theme))]
    False -> []
  }

  list.flatten([base, variant_styles, disabled_styles])
}

fn separator_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  [
    weft.height(length: weft.fixed(length: weft.px(pixels: 1))),
    weft.background(color: theme.border_color(theme)),
    weft.margin(pixels: 4),
  ]
}

fn label_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  [
    weft.padding_xy(x: 8, y: 6),
    weft.text_color(color: theme.muted_text(theme)),
    weft.font_size(size: weft.rem(rem: 0.75)),
    weft.font_weight(weight: weft.font_weight_value(weight: 500)),
  ]
}

/// Render a styled context menu.
pub fn context_menu(
  theme theme: theme.Theme,
  config config: ContextMenuConfig(msg),
  trigger trigger: weft_lustre.Element(msg),
  items items: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  headless_context_menu.context_menu(
    config: config
      |> headless_context_menu.context_menu_content_attrs(attrs: [
        weft_lustre.styles(content_styles(theme: theme)),
      ]),
    trigger: trigger,
    items: items,
  )
}

/// Render a styled context menu item.
pub fn context_menu_item(
  theme theme: theme.Theme,
  config config: ContextMenuItemConfig(msg),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let on_click =
    headless_context_menu.context_menu_item_config_on_click(config: config)
  let disabled =
    headless_context_menu.context_menu_item_config_disabled(config: config)
  let variant =
    headless_context_menu.context_menu_item_config_variant(config: config)
  let extra_attrs =
    headless_context_menu.context_menu_item_config_attrs(config: config)

  let variant_string = case variant {
    headless_context_menu.DefaultItem -> "default"
    headless_context_menu.DestructiveItem -> "destructive"
  }

  let base_attrs = [
    weft_lustre.html_attribute(attribute.role("menuitem")),
    weft_lustre.html_attribute(attribute.attribute("tabindex", "-1")),
    weft_lustre.html_attribute(attribute.attribute(
      "data-variant",
      variant_string,
    )),
    weft_lustre.styles(item_styles(
      theme: theme,
      variant: variant,
      disabled: disabled,
    )),
  ]

  let disabled_attrs = case disabled {
    True -> [
      weft_lustre.html_attribute(attribute.attribute("data-disabled", "")),
      weft_lustre.html_attribute(attribute.attribute(
        "aria-disabled",
        bool_to_string(True),
      )),
    ]
    False -> [
      weft_lustre.html_attribute(event.on_click(on_click())),
    ]
  }

  let all_attrs = list.flatten([base_attrs, disabled_attrs, extra_attrs])

  weft_lustre.row(attrs: all_attrs, children: children)
}

/// Render a styled context menu separator.
pub fn context_menu_separator(
  theme theme: theme.Theme,
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.el_layout()],
    attrs: [
      weft_lustre.html_attribute(attribute.role("separator")),
      weft_lustre.html_attribute(attribute.attribute(
        "data-slot",
        "context-menu-separator",
      )),
      weft_lustre.styles(separator_styles(theme: theme)),
    ],
    children: [],
  )
}

/// Render a styled context menu label.
pub fn context_menu_label(
  theme theme: theme.Theme,
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
      weft_lustre.styles(label_styles(theme: theme)),
    ],
    children: children,
  )
}
