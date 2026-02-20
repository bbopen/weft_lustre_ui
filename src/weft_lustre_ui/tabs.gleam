//// Styled tabs component for weft_lustre_ui.

import weft
import weft_lustre
import weft_lustre_ui/headless/tabs as headless_tabs
import weft_lustre_ui/theme

/// Styled tab item alias.
pub type TabItem(msg) =
  headless_tabs.TabItem(msg)

/// Styled tabs configuration alias.
pub type TabsConfig(msg) =
  headless_tabs.TabsConfig(msg)

/// Construct tab item with a text label.
pub fn tab_item(value value: String, label label: String) -> TabItem(msg) {
  headless_tabs.tab_item(value: value, label: label)
}

/// Construct tab item with an element label (e.g., text + badge).
pub fn tab_item_el(
  value value: String,
  label label: weft_lustre.Element(msg),
) -> TabItem(msg) {
  headless_tabs.tab_item_el(value: value, label: label)
}

/// Construct tabs configuration.
pub fn tabs_config(
  value value: String,
  on_change on_change: fn(String) -> msg,
) -> TabsConfig(msg) {
  headless_tabs.tabs_config(value: value, on_change: on_change)
}

/// Append root attributes.
pub fn tabs_attrs(
  config config: TabsConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> TabsConfig(msg) {
  headless_tabs.tabs_attrs(config: config, attrs: attrs)
}

/// Append tablist attributes.
pub fn tabs_list_attrs(
  config config: TabsConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> TabsConfig(msg) {
  headless_tabs.tabs_list_attrs(config: config, attrs: attrs)
}

/// Append tab trigger attributes.
pub fn tabs_trigger_attrs(
  config config: TabsConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> TabsConfig(msg) {
  headless_tabs.tabs_trigger_attrs(config: config, attrs: attrs)
}

/// Append active trigger attributes.
pub fn tabs_active_trigger_attrs(
  config config: TabsConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> TabsConfig(msg) {
  headless_tabs.tabs_active_trigger_attrs(config: config, attrs: attrs)
}

/// Append inactive trigger attributes.
pub fn tabs_inactive_trigger_attrs(
  config config: TabsConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> TabsConfig(msg) {
  headless_tabs.tabs_inactive_trigger_attrs(config: config, attrs: attrs)
}

fn root_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  [
    weft.spacing(pixels: 12),
    weft.font_family(families: theme.font_families(theme)),
  ]
}

fn list_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  [
    weft.display(value: weft.display_inline_flex()),
    weft.align_items(value: weft.align_items_center()),
    weft.spacing(pixels: 4),
    weft.padding(pixels: 3),
    weft.rounded(radius: theme.radius_md(theme)),
    weft.background(color: weft.rgb(red: 244, green: 244, blue: 245)),
  ]
}

fn trigger_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
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
    weft.background(color: weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.0)),
  ]
}

fn trigger_active_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
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

fn trigger_inactive_styles() -> List(weft.Attribute) {
  [
    weft.border(
      width: weft.px(pixels: 1),
      style: weft.border_style_solid(),
      color: weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.0),
    ),
    weft.shadows(shadows: []),
  ]
}

/// Render styled tabs.
pub fn tabs(
  theme theme: theme.Theme,
  config config: TabsConfig(msg),
  items items: List(TabItem(msg)),
  content content: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  let wrapped_content =
    weft_lustre.el(
      attrs: [
        weft_lustre.styles([
          weft.padding(pixels: 14),
          weft.border(
            width: weft.px(pixels: 1),
            style: weft.border_style_solid(),
            color: theme.border_color(theme),
          ),
          weft.rounded(radius: theme.radius_md(theme)),
          weft.background(color: weft.rgb(red: 255, green: 255, blue: 255)),
        ]),
      ],
      child: content,
    )

  headless_tabs.tabs(
    config: config
      |> headless_tabs.tabs_attrs(attrs: [
        weft_lustre.styles(root_styles(theme: theme)),
      ])
      |> headless_tabs.tabs_list_attrs(attrs: [
        weft_lustre.styles(list_styles(theme: theme)),
      ])
      |> headless_tabs.tabs_trigger_attrs(attrs: [
        weft_lustre.styles(trigger_styles(theme: theme)),
      ])
      |> headless_tabs.tabs_active_trigger_attrs(attrs: [
        weft_lustre.styles(trigger_active_styles(theme: theme)),
      ])
      |> headless_tabs.tabs_inactive_trigger_attrs(attrs: [
        weft_lustre.styles(trigger_inactive_styles()),
      ]),
    items: items,
    content: wrapped_content,
  )
}
