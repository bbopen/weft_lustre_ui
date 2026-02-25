//// Styled menubar primitives for shadcn compatibility.
////
//// Applies theme-driven defaults to `headless/menubar` primitives.

import gleam/list
import weft
import weft_lustre
import weft_lustre_ui/headless/menubar as headless_menubar
import weft_lustre_ui/theme

/// Menubar item variant token alias.
pub type MenubarItemVariant =
  headless_menubar.MenubarItemVariant

/// Styled menubar root configuration alias.
pub type MenubarConfig(msg) =
  headless_menubar.MenubarConfig(msg)

/// Styled menubar menu wrapper configuration alias.
pub type MenubarMenuConfig(msg) =
  headless_menubar.MenubarMenuConfig(msg)

/// Styled menubar item configuration alias.
pub type MenubarItemConfig(msg) =
  headless_menubar.MenubarItemConfig(msg)

/// Styled checkbox item configuration alias.
pub type MenubarCheckboxItemConfig(msg) =
  headless_menubar.MenubarCheckboxItemConfig(msg)

/// Styled radio item configuration alias.
pub type MenubarRadioItemConfig(msg) =
  headless_menubar.MenubarRadioItemConfig(msg)

/// Default menubar item variant.
pub fn menubar_item_variant_default(
  theme _theme: theme.Theme,
) -> MenubarItemVariant {
  headless_menubar.menubar_item_variant_default()
}

/// Destructive menubar item variant.
pub fn menubar_item_variant_destructive(
  theme _theme: theme.Theme,
) -> MenubarItemVariant {
  headless_menubar.menubar_item_variant_destructive()
}

/// Construct a default menubar configuration.
pub fn menubar_config(theme _theme: theme.Theme) -> MenubarConfig(msg) {
  headless_menubar.menubar_config()
}

/// Append menubar root attributes.
pub fn menubar_attrs(
  theme _theme: theme.Theme,
  config config: MenubarConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> MenubarConfig(msg) {
  headless_menubar.menubar_attrs(config: config, attrs: attrs)
}

/// Set message dispatched for left-arrow menu traversal.
pub fn menubar_on_move_prev(
  theme _theme: theme.Theme,
  config config: MenubarConfig(msg),
  on_move_prev on_move_prev: msg,
) -> MenubarConfig(msg) {
  headless_menubar.menubar_on_move_prev(
    config: config,
    on_move_prev: on_move_prev,
  )
}

/// Set message dispatched for right-arrow menu traversal.
pub fn menubar_on_move_next(
  theme _theme: theme.Theme,
  config config: MenubarConfig(msg),
  on_move_next on_move_next: msg,
) -> MenubarConfig(msg) {
  headless_menubar.menubar_on_move_next(
    config: config,
    on_move_next: on_move_next,
  )
}

/// Set message dispatched to close all menus on Escape.
pub fn menubar_on_close_all(
  theme _theme: theme.Theme,
  config config: MenubarConfig(msg),
  on_close_all on_close_all: msg,
) -> MenubarConfig(msg) {
  headless_menubar.menubar_on_close_all(
    config: config,
    on_close_all: on_close_all,
  )
}

/// Construct a default menubar menu wrapper configuration.
pub fn menubar_menu_config(
  theme _theme: theme.Theme,
  id id: String,
) -> MenubarMenuConfig(msg) {
  headless_menubar.menubar_menu_config(id: id)
}

/// Set open state for a menu wrapper.
pub fn menubar_menu_open(
  theme _theme: theme.Theme,
  config config: MenubarMenuConfig(msg),
  open open: Bool,
) -> MenubarMenuConfig(msg) {
  headless_menubar.menubar_menu_open(config: config, open: open)
}

/// Set open-state change handler for a menu wrapper.
pub fn menubar_menu_on_open_change(
  theme _theme: theme.Theme,
  config config: MenubarMenuConfig(msg),
  on_open_change on_open_change: fn(Bool) -> msg,
) -> MenubarMenuConfig(msg) {
  headless_menubar.menubar_menu_on_open_change(
    config: config,
    on_open_change: on_open_change,
  )
}

/// Append menu wrapper attributes.
pub fn menubar_menu_attrs(
  theme _theme: theme.Theme,
  config config: MenubarMenuConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> MenubarMenuConfig(msg) {
  headless_menubar.menubar_menu_attrs(config: config, attrs: attrs)
}

/// Construct a default menubar item configuration.
pub fn menubar_item_config(theme _theme: theme.Theme) -> MenubarItemConfig(msg) {
  headless_menubar.menubar_item_config()
}

/// Set item as inset.
pub fn menubar_item_inset(
  theme _theme: theme.Theme,
  config config: MenubarItemConfig(msg),
) -> MenubarItemConfig(msg) {
  headless_menubar.menubar_item_inset(config: config)
}

/// Set item variant.
pub fn menubar_item_variant(
  theme _theme: theme.Theme,
  config config: MenubarItemConfig(msg),
  variant variant: MenubarItemVariant,
) -> MenubarItemConfig(msg) {
  headless_menubar.menubar_item_variant(config: config, variant: variant)
}

/// Mark item disabled.
pub fn menubar_item_disabled(
  theme _theme: theme.Theme,
  config config: MenubarItemConfig(msg),
) -> MenubarItemConfig(msg) {
  headless_menubar.menubar_item_disabled(config: config)
}

/// Set item on-select message.
pub fn menubar_item_on_select(
  theme _theme: theme.Theme,
  config config: MenubarItemConfig(msg),
  on_select on_select: msg,
) -> MenubarItemConfig(msg) {
  headless_menubar.menubar_item_on_select(config: config, on_select: on_select)
}

/// Append item attributes.
pub fn menubar_item_attrs(
  theme _theme: theme.Theme,
  config config: MenubarItemConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> MenubarItemConfig(msg) {
  headless_menubar.menubar_item_attrs(config: config, attrs: attrs)
}

/// Construct a menubar checkbox item configuration.
pub fn menubar_checkbox_item_config(
  theme _theme: theme.Theme,
  checked checked: Bool,
  on_toggle on_toggle: fn(Bool) -> msg,
) -> MenubarCheckboxItemConfig(msg) {
  headless_menubar.menubar_checkbox_item_config(
    checked: checked,
    on_toggle: on_toggle,
  )
}

/// Mark checkbox item disabled.
pub fn menubar_checkbox_item_disabled(
  theme _theme: theme.Theme,
  config config: MenubarCheckboxItemConfig(msg),
) -> MenubarCheckboxItemConfig(msg) {
  headless_menubar.menubar_checkbox_item_disabled(config: config)
}

/// Append checkbox item attributes.
pub fn menubar_checkbox_item_attrs(
  theme _theme: theme.Theme,
  config config: MenubarCheckboxItemConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> MenubarCheckboxItemConfig(msg) {
  headless_menubar.menubar_checkbox_item_attrs(config: config, attrs: attrs)
}

/// Construct a menubar radio item configuration.
pub fn menubar_radio_item_config(
  theme _theme: theme.Theme,
  name name: String,
  value value: String,
  checked checked: Bool,
  on_select on_select: fn(String) -> msg,
) -> MenubarRadioItemConfig(msg) {
  headless_menubar.menubar_radio_item_config(
    name: name,
    value: value,
    checked: checked,
    on_select: on_select,
  )
}

/// Mark radio item disabled.
pub fn menubar_radio_item_disabled(
  theme _theme: theme.Theme,
  config config: MenubarRadioItemConfig(msg),
) -> MenubarRadioItemConfig(msg) {
  headless_menubar.menubar_radio_item_disabled(config: config)
}

/// Append radio item attributes.
pub fn menubar_radio_item_attrs(
  theme _theme: theme.Theme,
  config config: MenubarRadioItemConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> MenubarRadioItemConfig(msg) {
  headless_menubar.menubar_radio_item_attrs(config: config, attrs: attrs)
}

/// Read the item variant from a menubar item config.
pub fn menubar_item_config_variant(
  theme _theme: theme.Theme,
  config config: MenubarItemConfig(msg),
) -> MenubarItemVariant {
  headless_menubar.menubar_item_config_variant(config: config)
}

/// Read whether a menubar item config is inset.
pub fn menubar_item_config_inset(
  theme _theme: theme.Theme,
  config config: MenubarItemConfig(msg),
) -> Bool {
  headless_menubar.menubar_item_config_inset(config: config)
}

/// Check whether a menubar item variant is destructive.
pub fn menubar_item_variant_is_destructive(
  theme _theme: theme.Theme,
  variant variant: MenubarItemVariant,
) -> Bool {
  headless_menubar.menubar_item_variant_is_destructive(variant: variant)
}

fn menubar_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  let #(surface_bg, surface_fg) = theme.surface(theme)

  [
    weft.row_layout(),
    weft.align_items(value: weft.align_items_center()),
    weft.spacing(pixels: 4),
    weft.padding(pixels: 4),
    weft.rounded(radius: theme.radius_md(theme)),
    weft.border(
      width: weft.px(pixels: 1),
      style: weft.border_style_solid(),
      color: theme.border_color(theme),
    ),
    weft.background(color: surface_bg),
    weft.text_color(color: surface_fg),
    weft.font_family(families: theme.font_families(theme)),
  ]
}

/// Render styled menubar root.
pub fn menubar(
  theme theme: theme.Theme,
  config config: MenubarConfig(msg),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  headless_menubar.menubar(
    config: config
      |> headless_menubar.menubar_attrs(attrs: [
        weft_lustre.styles(menubar_styles(theme: theme)),
      ]),
    children: children,
  )
}

/// Render a styled menubar menu wrapper.
pub fn menubar_menu(
  theme _theme: theme.Theme,
  config config: MenubarMenuConfig(msg),
  trigger trigger: weft_lustre.Element(msg),
  content content: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  headless_menubar.menubar_menu(
    config: config,
    trigger: trigger,
    content: content,
  )
}

/// Render a styled menubar group.
pub fn menubar_group(
  theme _theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  headless_menubar.menubar_group(
    attrs: list.append(
      [weft_lustre.styles([weft.column_layout(), weft.spacing(pixels: 2)])],
      attrs,
    ),
    children: children,
  )
}

/// Render a styled menubar portal wrapper.
pub fn menubar_portal(
  theme _theme: theme.Theme,
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  headless_menubar.menubar_portal(children: children)
}

/// Render a styled menubar radio-group wrapper.
pub fn menubar_radio_group(
  theme _theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  headless_menubar.menubar_radio_group(attrs: attrs, children: children)
}

/// Render a styled menubar trigger.
pub fn menubar_trigger(
  theme theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  child child: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  let #(_, surface_fg) = theme.surface(theme)

  headless_menubar.menubar_trigger(
    attrs: list.append(
      [
        weft_lustre.styles([
          weft.display(value: weft.display_inline_flex()),
          weft.align_items(value: weft.align_items_center()),
          weft.padding_xy(x: 8, y: 6),
          weft.rounded(radius: weft.px(pixels: 6)),
          weft.text_color(color: surface_fg),
        ]),
      ],
      attrs,
    ),
    child: child,
  )
}

/// Render styled menubar content.
pub fn menubar_content(
  theme theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let #(overlay_bg, overlay_fg) = theme.overlay_surface(theme)

  menubar_portal(theme: theme, children: [
    headless_menubar.menubar_content(
      attrs: list.append(
        [
          weft_lustre.styles([
            weft.column_layout(),
            weft.spacing(pixels: 4),
            weft.padding(pixels: 6),
            weft.rounded(radius: theme.radius_md(theme)),
            weft.border(
              width: weft.px(pixels: 1),
              style: weft.border_style_solid(),
              color: theme.border_color(theme),
            ),
            weft.background(color: overlay_bg),
            weft.text_color(color: overlay_fg),
          ]),
        ],
        attrs,
      ),
      children: children,
    ),
  ])
}

fn item_styles(
  theme theme: theme.Theme,
  config config: MenubarItemConfig(msg),
) -> List(weft.Attribute) {
  let #(surface_bg, surface_fg) = theme.surface(theme)
  let #(danger_bg, danger_fg) = theme.danger(theme)

  let variant = headless_menubar.menubar_item_config_variant(config: config)
  let inset = headless_menubar.menubar_item_config_inset(config: config)

  list.flatten([
    [
      weft.display(value: weft.display_flex()),
      weft.align_items(value: weft.align_items_center()),
      weft.justify_content(value: weft.justify_start()),
      weft.padding_xy(x: 8, y: 6),
      weft.rounded(radius: weft.px(pixels: 6)),
      weft.outline_none(),
      weft.border(
        width: weft.px(pixels: 1),
        style: weft.border_style_solid(),
        color: weft.transparent(),
      ),
      weft.font_size(size: weft.rem(rem: 0.875)),
      weft.font_family(families: theme.font_families(theme)),
    ],
    case inset {
      True -> [weft.padding_left(pixels: 24)]
      False -> []
    },
    case
      headless_menubar.menubar_item_variant_is_destructive(variant: variant)
    {
      True -> [
        weft.background(color: danger_bg),
        weft.text_color(color: danger_fg),
      ]
      False -> [
        weft.background(color: surface_bg),
        weft.text_color(color: surface_fg),
      ]
    },
  ])
}

/// Render a styled menubar item.
pub fn menubar_item(
  theme theme: theme.Theme,
  config config: MenubarItemConfig(msg),
  child child: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  headless_menubar.menubar_item(
    config: config
      |> headless_menubar.menubar_item_attrs(attrs: [
        weft_lustre.styles(item_styles(theme: theme, config: config)),
      ]),
    child: child,
  )
}

/// Render a styled menubar checkbox item.
pub fn menubar_checkbox_item(
  theme theme: theme.Theme,
  config config: MenubarCheckboxItemConfig(msg),
  child child: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  headless_menubar.menubar_checkbox_item(
    config: config
      |> headless_menubar.menubar_checkbox_item_attrs(attrs: [
        weft_lustre.styles([
          weft.display(value: weft.display_flex()),
          weft.align_items(value: weft.align_items_center()),
          weft.padding_xy(x: 8, y: 6),
          weft.rounded(radius: weft.px(pixels: 6)),
          weft.font_family(families: theme.font_families(theme)),
        ]),
      ]),
    child: child,
  )
}

/// Render a styled menubar radio item.
pub fn menubar_radio_item(
  theme theme: theme.Theme,
  config config: MenubarRadioItemConfig(msg),
  child child: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  headless_menubar.menubar_radio_item(
    config: config
      |> headless_menubar.menubar_radio_item_attrs(attrs: [
        weft_lustre.styles([
          weft.display(value: weft.display_flex()),
          weft.align_items(value: weft.align_items_center()),
          weft.padding_xy(x: 8, y: 6),
          weft.rounded(radius: weft.px(pixels: 6)),
          weft.font_family(families: theme.font_families(theme)),
        ]),
      ]),
    child: child,
  )
}

/// Render a styled menubar label.
pub fn menubar_label(
  theme theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  child child: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  headless_menubar.menubar_label(
    attrs: list.append(
      [
        weft_lustre.styles([
          weft.padding_xy(x: 8, y: 6),
          weft.font_family(families: theme.font_families(theme)),
          weft.font_weight(weight: weft.font_weight_value(weight: 600)),
        ]),
      ],
      attrs,
    ),
    child: child,
  )
}

/// Render a styled menubar separator.
pub fn menubar_separator(
  theme theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> weft_lustre.Element(msg) {
  headless_menubar.menubar_separator(attrs: list.append(
    [
      weft_lustre.styles([
        weft.height(length: weft.fixed(length: weft.px(pixels: 1))),
        weft.width(length: weft.fixed(length: weft.pct(pct: 100.0))),
        weft.background(color: theme.border_color(theme)),
      ]),
    ],
    attrs,
  ))
}

/// Render a styled menubar shortcut slot.
pub fn menubar_shortcut(
  theme theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  child child: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  headless_menubar.menubar_shortcut(
    attrs: list.append(
      [
        weft_lustre.styles([
          weft.margin_left(pixels: 0),
          weft.font_size(size: weft.rem(rem: 0.75)),
          weft.text_color(color: theme.muted_text(theme)),
        ]),
      ],
      attrs,
    ),
    child: child,
  )
}

/// Render a styled menubar sub-menu wrapper.
pub fn menubar_sub(
  theme _theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  trigger trigger: weft_lustre.Element(msg),
  content content: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  headless_menubar.menubar_sub(attrs: attrs, trigger: trigger, content: content)
}

/// Render a styled menubar sub-trigger.
pub fn menubar_sub_trigger(
  theme theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  child child: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  headless_menubar.menubar_sub_trigger(
    attrs: list.append(
      [
        weft_lustre.styles([
          weft.display(value: weft.display_flex()),
          weft.align_items(value: weft.align_items_center()),
          weft.justify_content(value: weft.justify_space_between()),
          weft.padding_xy(x: 8, y: 6),
          weft.rounded(radius: weft.px(pixels: 6)),
          weft.font_family(families: theme.font_families(theme)),
        ]),
      ],
      attrs,
    ),
    child: child,
  )
}

/// Render styled menubar sub-content.
pub fn menubar_sub_content(
  theme theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let #(overlay_bg, overlay_fg) = theme.overlay_surface(theme)

  headless_menubar.menubar_sub_content(
    attrs: list.append(
      [
        weft_lustre.styles([
          weft.column_layout(),
          weft.spacing(pixels: 4),
          weft.padding(pixels: 6),
          weft.rounded(radius: theme.radius_md(theme)),
          weft.border(
            width: weft.px(pixels: 1),
            style: weft.border_style_solid(),
            color: theme.border_color(theme),
          ),
          weft.background(color: overlay_bg),
          weft.text_color(color: overlay_fg),
        ]),
      ],
      attrs,
    ),
    children: children,
  )
}
