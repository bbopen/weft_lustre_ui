//// Styled, theme-driven command palette component for weft_lustre_ui.
////
//// Renders a searchable command list with themed input, groups, and items.
//// Items show accent highlight on hover, muted text for groups and empty state.

import gleam/list
import gleam/option
import lustre/attribute
import lustre/event
import weft
import weft_lustre
import weft_lustre_ui/headless/command as headless_command
import weft_lustre_ui/theme

/// Styled command item alias.
pub type CommandItem(msg) =
  headless_command.CommandItem(msg)

/// Styled command configuration alias.
pub type CommandConfig(msg) =
  headless_command.CommandConfig(msg)

/// Create a command item with sensible defaults.
///
/// Keywords default to empty, group to `None`, and disabled to `False`.
pub fn command_item(
  value value: String,
  label label: String,
  on_select on_select: msg,
) -> CommandItem(msg) {
  headless_command.command_item(
    value: value,
    label: label,
    on_select: on_select,
  )
}

/// Add keywords to a command item for search matching.
pub fn command_item_keywords(
  item item: CommandItem(msg),
  keywords keywords: List(String),
) -> CommandItem(msg) {
  headless_command.command_item_keywords(item: item, keywords: keywords)
}

/// Assign a command item to a named group.
pub fn command_item_group(
  item item: CommandItem(msg),
  group group: String,
) -> CommandItem(msg) {
  headless_command.command_item_group(item: item, group: group)
}

/// Mark a command item as disabled.
pub fn command_item_disabled(item item: CommandItem(msg)) -> CommandItem(msg) {
  headless_command.command_item_disabled(item: item)
}

/// Construct command palette configuration.
pub fn command_config(
  query query: String,
  on_query_change on_query_change: fn(String) -> msg,
  items items: List(CommandItem(msg)),
) -> CommandConfig(msg) {
  headless_command.command_config(
    query: query,
    on_query_change: on_query_change,
    items: items,
  )
}

/// Set the message displayed when no items match the search query.
pub fn command_empty_message(
  config config: CommandConfig(msg),
  message message: String,
) -> CommandConfig(msg) {
  headless_command.command_empty_message(config: config, message: message)
}

/// Append additional attributes to the command palette root element.
pub fn command_attrs(
  config config: CommandConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> CommandConfig(msg) {
  headless_command.command_attrs(config: config, attrs: attrs)
}

/// Filter command items by a search query.
///
/// If the query is empty, returns all non-disabled items. Otherwise performs
/// a case-insensitive substring match against each item's label, value, and
/// keywords.
pub fn command_filter(
  items items: List(CommandItem(msg)),
  query query: String,
) -> List(CommandItem(msg)) {
  headless_command.command_filter(items: items, query: query)
}

fn root_styles(t: theme.Theme) -> List(weft.Attribute) {
  let #(overlay_bg, overlay_fg) = theme.overlay_surface(t)

  [
    weft.display(value: weft.display_flex()),
    weft.overflow(overflow: weft.overflow_hidden()),
    weft.rounded(radius: theme.radius_md(t)),
    weft.width(length: weft.fill()),
    weft.background(color: overlay_bg),
    weft.text_color(color: overlay_fg),
    weft.font_family(families: theme.font_families(t)),
  ]
}

fn input_wrapper_styles(_t: theme.Theme) -> List(weft.Attribute) {
  [
    weft.display(value: weft.display_flex()),
    weft.align_items(value: weft.align_items_center()),
    weft.spacing(pixels: 8),
    weft.padding_xy(x: 12, y: 0),
    weft.height(length: weft.fixed(length: weft.px(pixels: 36))),
    weft.border(
      width: weft.px(pixels: 0),
      style: weft.border_style_none(),
      color: weft.transparent(),
    ),
  ]
}

fn input_styles(t: theme.Theme) -> List(weft.Attribute) {
  [
    weft.width(length: weft.fill()),
    weft.background(color: weft.transparent()),
    weft.border(
      width: weft.px(pixels: 0),
      style: weft.border_style_none(),
      color: weft.transparent(),
    ),
    weft.outline_none(),
    weft.appearance(value: weft.appearance_none()),
    weft.font_size(size: weft.rem(rem: 0.875)),
    weft.font_family(families: theme.font_families(t)),
  ]
}

fn separator_styles(t: theme.Theme) -> List(weft.Attribute) {
  [
    weft.height(length: weft.fixed(length: weft.px(pixels: 1))),
    weft.width(length: weft.fill()),
    weft.background(color: theme.border_color(t)),
  ]
}

fn list_styles(_t: theme.Theme) -> List(weft.Attribute) {
  [
    weft.overflow_y(overflow: weft.overflow_auto()),
    weft.height(length: weft.maximum(
      base: weft.shrink(),
      max: weft.px(pixels: 300),
    )),
    weft.padding(pixels: 4),
  ]
}

fn empty_styles(t: theme.Theme) -> List(weft.Attribute) {
  [
    weft.padding_xy(x: 0, y: 24),
    weft.text_align(align: weft.text_align_center()),
    weft.font_size(size: weft.rem(rem: 0.875)),
    weft.text_color(color: theme.muted_text(t)),
  ]
}

fn group_heading_styles(t: theme.Theme) -> List(weft.Attribute) {
  [
    weft.padding_xy(x: 8, y: 6),
    weft.font_size(size: weft.rem(rem: 0.75)),
    weft.font_weight(weight: weft.font_weight_value(weight: 500)),
    weft.text_color(color: theme.muted_text(t)),
  ]
}

fn item_styles(t: theme.Theme, disabled: Bool) -> List(weft.Attribute) {
  let #(accent_bg, accent_fg) = theme.accent(theme: t)

  list.flatten([
    [
      weft.display(value: weft.display_flex()),
      weft.align_items(value: weft.align_items_center()),
      weft.spacing(pixels: 8),
      weft.padding_xy(x: 8, y: 6),
      weft.rounded(radius: weft.px(pixels: 4)),
      weft.font_size(size: weft.rem(rem: 0.875)),
      weft.cursor(cursor: weft.cursor_default()),
    ],
    case disabled {
      True -> [
        weft.alpha(opacity: theme.disabled_opacity(t)),
        weft.cursor(cursor: weft.cursor_not_allowed()),
      ]
      False -> [
        weft.mouse_over(attrs: [
          weft.background(color: accent_bg),
          weft.text_color(color: accent_fg),
        ]),
      ]
    },
  ])
}

fn render_styled_item(
  t: theme.Theme,
  item: headless_command.CommandItem(msg),
) -> weft_lustre.Element(msg) {
  let disabled_attrs = case item.disabled {
    True -> [
      weft_lustre.html_attribute(attribute.attribute("data-disabled", "true")),
      weft_lustre.html_attribute(attribute.aria_disabled(True)),
    ]
    False -> [
      weft_lustre.html_attribute(event.on_click(item.on_select)),
    ]
  }

  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.el_layout()],
    attrs: list.flatten([
      [
        weft_lustre.styles(item_styles(t, item.disabled)),
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "command-item",
        )),
        weft_lustre.html_attribute(attribute.role("option")),
        weft_lustre.html_attribute(attribute.attribute("data-value", item.value)),
        weft_lustre.html_attribute(attribute.tabindex(-1)),
      ],
      disabled_attrs,
    ]),
    children: [weft_lustre.text(content: item.label)],
  )
}

fn render_styled_group(
  t: theme.Theme,
  name: String,
  items: List(headless_command.CommandItem(msg)),
) -> weft_lustre.Element(msg) {
  let heading =
    weft_lustre.element_tag(
      tag: "div",
      base_weft_attrs: [weft.el_layout()],
      attrs: [
        weft_lustre.styles(group_heading_styles(t)),
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "command-group-heading",
        )),
      ],
      children: [weft_lustre.text(content: name)],
    )

  let item_elements = list.map(items, fn(item) { render_styled_item(t, item) })

  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.column_layout()],
    attrs: [
      weft_lustre.html_attribute(attribute.attribute(
        "data-slot",
        "command-group",
      )),
      weft_lustre.html_attribute(attribute.role("group")),
      weft_lustre.html_attribute(attribute.aria_label(name)),
    ],
    children: [heading, ..item_elements],
  )
}

/// Collect unique group names from a list of items, preserving first-seen order.
fn collect_group_names(
  items: List(headless_command.CommandItem(msg)),
) -> List(String) {
  collect_group_names_loop(items, [], [])
}

fn collect_group_names_loop(
  items: List(headless_command.CommandItem(msg)),
  acc: List(String),
  seen: List(String),
) -> List(String) {
  case items {
    [] -> list.reverse(acc)
    [item, ..rest] ->
      case item.group {
        option.None -> collect_group_names_loop(rest, acc, seen)
        option.Some(name) ->
          case list.contains(seen, name) {
            True -> collect_group_names_loop(rest, acc, seen)
            False ->
              collect_group_names_loop(rest, [name, ..acc], [name, ..seen])
          }
      }
  }
}

fn build_styled_grouped_children(
  t: theme.Theme,
  filtered: List(headless_command.CommandItem(msg)),
) -> List(weft_lustre.Element(msg)) {
  let ungrouped =
    list.filter(filtered, fn(item) {
      case item.group {
        option.None -> True
        option.Some(_) -> False
      }
    })

  let ungrouped_elements =
    list.map(ungrouped, fn(item) { render_styled_item(t, item) })

  let group_names = collect_group_names(filtered)
  let grouped_elements =
    list.map(group_names, fn(name) {
      let group_items =
        list.filter(filtered, fn(item) { item.group == option.Some(name) })
      render_styled_group(t, name, group_items)
    })

  list.append(ungrouped_elements, grouped_elements)
}

/// Render the styled command palette.
///
/// Applies theme tokens to the root, input, list, empty state, group headings,
/// and item rows. Items receive accent-colored hover highlighting and disabled
/// items are dimmed with reduced opacity.
pub fn command(
  theme theme: theme.Theme,
  config config: CommandConfig(msg),
) -> weft_lustre.Element(msg) {
  let t = theme
  let query = headless_command.command_config_query(config: config)
  let on_query_change =
    headless_command.command_config_on_query_change(config: config)
  let items = headless_command.command_config_items(config: config)
  let empty_message =
    headless_command.command_config_empty_message(config: config)

  let filtered = headless_command.command_filter(items: items, query: query)

  let input_el =
    weft_lustre.element_tag(
      tag: "input",
      base_weft_attrs: [weft.el_layout()],
      attrs: [
        weft_lustre.styles(input_styles(t)),
        weft_lustre.html_attribute(attribute.type_("text")),
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "command-input",
        )),
        weft_lustre.html_attribute(attribute.placeholder("Search\u{2026}")),
        weft_lustre.html_attribute(attribute.value(query)),
        weft_lustre.html_attribute(event.on_input(on_query_change)),
      ],
      children: [],
    )

  let input_wrapper =
    weft_lustre.element_tag(
      tag: "div",
      base_weft_attrs: [weft.row_layout()],
      attrs: [
        weft_lustre.styles(input_wrapper_styles(t)),
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "command-input-wrapper",
        )),
      ],
      children: [input_el],
    )

  let separator =
    weft_lustre.element_tag(
      tag: "div",
      base_weft_attrs: [weft.el_layout()],
      attrs: [weft_lustre.styles(separator_styles(t))],
      children: [],
    )

  let list_children = case filtered {
    [] -> [
      weft_lustre.element_tag(
        tag: "div",
        base_weft_attrs: [weft.el_layout()],
        attrs: [
          weft_lustre.styles(empty_styles(t)),
          weft_lustre.html_attribute(attribute.attribute(
            "data-slot",
            "command-empty",
          )),
        ],
        children: [weft_lustre.text(content: empty_message)],
      ),
    ]
    _ -> build_styled_grouped_children(t, filtered)
  }

  let list_el =
    weft_lustre.element_tag(
      tag: "div",
      base_weft_attrs: [weft.column_layout()],
      attrs: [
        weft_lustre.styles(list_styles(t)),
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "command-list",
        )),
        weft_lustre.html_attribute(attribute.role("listbox")),
      ],
      children: list_children,
    )

  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.column_layout()],
    attrs: [
      weft_lustre.styles(root_styles(t)),
      weft_lustre.html_attribute(attribute.attribute("data-slot", "command")),
    ],
    children: [input_wrapper, separator, list_el],
  )
}
