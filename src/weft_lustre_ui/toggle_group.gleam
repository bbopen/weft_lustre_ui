//// Styled toggle-group component for weft_lustre_ui.

import gleam/list
import weft
import weft_lustre
import weft_lustre_ui/headless/toggle_group as headless_toggle_group
import weft_lustre_ui/theme

/// Styled toggle item alias.
pub type ToggleItem =
  headless_toggle_group.ToggleItem

/// Styled toggle-group configuration alias.
pub type ToggleGroupConfig(msg) =
  headless_toggle_group.ToggleGroupConfig(msg)

/// Construct toggle item.
pub fn toggle_item(value value: String, label label: String) -> ToggleItem {
  headless_toggle_group.toggle_item(value: value, label: label)
}

/// Construct toggle-group configuration.
pub fn toggle_group_config(
  value value: String,
  on_change on_change: fn(String) -> msg,
) -> ToggleGroupConfig(msg) {
  headless_toggle_group.toggle_group_config(value: value, on_change: on_change)
}

/// Append root attributes.
pub fn toggle_group_attrs(
  config config: ToggleGroupConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ToggleGroupConfig(msg) {
  headless_toggle_group.toggle_group_attrs(config: config, attrs: attrs)
}

/// Append active item attributes.
pub fn toggle_group_active_item_attrs(
  config config: ToggleGroupConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ToggleGroupConfig(msg) {
  headless_toggle_group.toggle_group_active_item_attrs(
    config: config,
    attrs: attrs,
  )
}

/// Append inactive item attributes.
pub fn toggle_group_inactive_item_attrs(
  config config: ToggleGroupConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ToggleGroupConfig(msg) {
  headless_toggle_group.toggle_group_inactive_item_attrs(
    config: config,
    attrs: attrs,
  )
}

fn styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  [
    weft.display(value: weft.display_inline_flex()),
    weft.align_items(value: weft.align_items_center()),
    weft.spacing(pixels: 4),
    weft.padding(pixels: 3),
    weft.rounded(radius: theme.radius_md(theme)),
    weft.background(color: weft.rgb(red: 244, green: 244, blue: 245)),
    weft.font_family(families: theme.font_families(theme)),
  ]
}

fn item_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  [
    weft.display(value: weft.display_inline_flex()),
    weft.align_items(value: weft.align_items_center()),
    weft.justify_content(value: weft.justify_center()),
    weft.padding_xy(x: 8, y: 4),
    weft.rounded(radius: theme.radius_md(theme)),
    weft.font_family(families: theme.font_families(theme)),
    weft.font_size(size: weft.rem(rem: 0.875)),
    weft.font_weight(weight: weft.font_weight_value(weight: 500)),
    weft.line_height(height: weft.line_height_multiple(multiplier: 1.4)),
    weft.text_color(color: theme.muted_text(theme)),
    weft.outline_none(),
  ]
}

fn active_item_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  [
    weft.background(color: weft.rgb(red: 255, green: 255, blue: 255)),
    weft.border(
      width: weft.px(pixels: 1),
      style: weft.border_style_solid(),
      color: theme.border_color(theme),
    ),
    weft.text_color(color: weft.rgb(red: 17, green: 24, blue: 39)),
    weft.shadows(shadows: [
      weft.shadow(
        x: weft.px(pixels: 0),
        y: weft.px(pixels: 1),
        blur: weft.px(pixels: 2),
        spread: weft.px(pixels: 0),
        color: weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.05),
      ),
    ]),
  ]
}

fn inactive_item_styles() -> List(weft.Attribute) {
  [
    weft.background(color: weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.0)),
    weft.border(
      width: weft.px(pixels: 1),
      style: weft.border_style_solid(),
      color: weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.0),
    ),
    weft.shadows(shadows: []),
  ]
}

/// Render styled toggle-group.
pub fn toggle_group(
  theme theme: theme.Theme,
  config config: ToggleGroupConfig(msg),
  items items: List(ToggleItem),
) -> weft_lustre.Element(msg) {
  headless_toggle_group.toggle_group(
    config: config
      |> headless_toggle_group.toggle_group_attrs(attrs: [
        weft_lustre.styles(styles(theme: theme)),
      ])
      |> headless_toggle_group.toggle_group_active_item_attrs(attrs: [
        weft_lustre.styles(
          list.flatten([
            item_styles(theme: theme),
            active_item_styles(theme: theme),
          ]),
        ),
      ])
      |> headless_toggle_group.toggle_group_inactive_item_attrs(attrs: [
        weft_lustre.styles(
          list.flatten([item_styles(theme: theme), inactive_item_styles()]),
        ),
      ]),
    items: items,
  )
}
