//// Styled, theme-driven empty state component for weft_lustre_ui.
////
//// Renders a centered container with muted text for displaying empty states
//// with optional icon, title, description, and action slots.

import gleam/list
import gleam/option.{type Option}
import weft
import weft_lustre
import weft_lustre_ui/headless/empty as headless_empty
import weft_lustre_ui/theme

/// Styled empty state configuration alias.
pub type EmptyConfig(msg) =
  headless_empty.EmptyConfig(msg)

/// Construct a default empty state configuration.
pub fn empty_config() -> EmptyConfig(msg) {
  headless_empty.empty_config()
}

/// Set the icon slot for the empty state.
pub fn empty_icon(
  config config: EmptyConfig(msg),
  icon icon: weft_lustre.Element(msg),
) -> EmptyConfig(msg) {
  headless_empty.empty_icon(config: config, icon: icon)
}

/// Set the title slot for the empty state.
pub fn empty_title(
  config config: EmptyConfig(msg),
  title title: weft_lustre.Element(msg),
) -> EmptyConfig(msg) {
  headless_empty.empty_title(config: config, title: title)
}

/// Set the description slot for the empty state.
pub fn empty_description(
  config config: EmptyConfig(msg),
  description description: weft_lustre.Element(msg),
) -> EmptyConfig(msg) {
  headless_empty.empty_description(config: config, description: description)
}

/// Set the action slot for the empty state.
pub fn empty_action(
  config config: EmptyConfig(msg),
  action action: weft_lustre.Element(msg),
) -> EmptyConfig(msg) {
  headless_empty.empty_action(config: config, action: action)
}

/// Append additional attributes to the empty state container.
pub fn empty_attrs(
  config config: EmptyConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> EmptyConfig(msg) {
  headless_empty.empty_attrs(config: config, attrs: attrs)
}

fn container_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  let #(_, surface_fg) = theme.surface(theme)
  let muted = theme.muted_text(theme)
  let radius = theme.radius_md(theme)
  let _: weft.Color = surface_fg
  let _: weft.Color = muted

  [
    weft.column_layout(),
    weft.align_items(value: weft.align_items_center()),
    weft.justify_content(value: weft.justify_center()),
    weft.spacing(pixels: 24),
    weft.padding(pixels: 48),
    weft.rounded(radius: radius),
    weft.text_color(color: muted),
    weft.font_family(families: theme.font_families(theme)),
  ]
}

fn icon_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  let #(muted_bg, _) = theme.muted(theme)

  [
    weft.display(value: weft.display_flex()),
    weft.align_items(value: weft.align_items_center()),
    weft.justify_content(value: weft.justify_center()),
    weft.width(length: weft.fixed(length: weft.px(pixels: 40))),
    weft.height(length: weft.fixed(length: weft.px(pixels: 40))),
    weft.rounded(radius: weft.px(pixels: 8)),
    weft.background(color: muted_bg),
  ]
}

fn title_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  let #(_, surface_fg) = theme.surface(theme)

  [
    weft.font_size(size: weft.rem(rem: 1.125)),
    weft.font_weight(weight: weft.font_weight_value(weight: 500)),
    weft.text_color(color: surface_fg),
  ]
}

fn description_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  let muted = theme.muted_text(theme)

  [
    weft.font_size(size: weft.rem(rem: 0.875)),
    weft.line_height(height: weft.line_height_multiple(multiplier: 1.625)),
    weft.text_color(color: muted),
  ]
}

fn wrap_slot(
  slot: Option(weft_lustre.Element(msg)),
  styles: List(weft.Attribute),
) -> List(weft_lustre.Element(msg)) {
  case slot {
    option.Some(child) -> [
      weft_lustre.element_tag(
        tag: "div",
        base_weft_attrs: [weft.el_layout()],
        attrs: [weft_lustre.styles(styles)],
        children: [child],
      ),
    ]
    option.None -> []
  }
}

fn optional_child(
  slot: Option(weft_lustre.Element(msg)),
) -> List(weft_lustre.Element(msg)) {
  case slot {
    option.Some(child) -> [child]
    option.None -> []
  }
}

/// Render a styled empty state container.
pub fn empty(
  theme theme: theme.Theme,
  config config: EmptyConfig(msg),
) -> weft_lustre.Element(msg) {
  let icon = headless_empty.empty_config_icon(config: config)
  let title = headless_empty.empty_config_title(config: config)
  let description = headless_empty.empty_config_description(config: config)
  let action = headless_empty.empty_config_action(config: config)
  let attrs = headless_empty.empty_config_attrs(config: config)

  let children =
    list.flatten([
      wrap_slot(icon, icon_styles(theme: theme)),
      wrap_slot(title, title_styles(theme: theme)),
      wrap_slot(description, description_styles(theme: theme)),
      optional_child(action),
    ])

  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.el_layout()],
    attrs: list.append(
      [weft_lustre.styles(container_styles(theme: theme))],
      attrs,
    ),
    children: children,
  )
}
