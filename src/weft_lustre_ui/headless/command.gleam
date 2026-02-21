//// Headless command palette component for weft_lustre_ui.
////
//// Provides a searchable command list with groups, items, and a
//// pure filter function. The headless layer handles structure,
//// ARIA attributes, and event wiring.

import gleam/dict
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import lustre/attribute
import lustre/event
import weft
import weft_lustre

/// A command item with metadata for filtering and display.
pub type CommandItem(msg) {
  /// A selectable item with a value, label, keywords, optional group,
  /// disabled flag, and a message to dispatch on selection.
  CommandItem(
    value: String,
    label: String,
    keywords: List(String),
    group: Option(String),
    disabled: Bool,
    on_select: msg,
  )
}

/// Configuration for the command palette component.
pub opaque type CommandConfig(msg) {
  CommandConfig(
    query: String,
    on_query_change: fn(String) -> msg,
    items: List(CommandItem(msg)),
    empty_message: String,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Create a command item with sensible defaults.
///
/// Keywords default to empty, group to `None`, and disabled to `False`.
pub fn command_item(
  value value: String,
  label label: String,
  on_select on_select: msg,
) -> CommandItem(msg) {
  CommandItem(
    value: value,
    label: label,
    keywords: [],
    group: None,
    disabled: False,
    on_select: on_select,
  )
}

/// Add keywords to a command item for search matching.
pub fn command_item_keywords(
  item item: CommandItem(msg),
  keywords keywords: List(String),
) -> CommandItem(msg) {
  CommandItem(..item, keywords: keywords)
}

/// Assign a command item to a named group.
pub fn command_item_group(
  item item: CommandItem(msg),
  group group: String,
) -> CommandItem(msg) {
  CommandItem(..item, group: Some(group))
}

/// Mark a command item as disabled.
pub fn command_item_disabled(item item: CommandItem(msg)) -> CommandItem(msg) {
  CommandItem(..item, disabled: True)
}

/// Construct command palette configuration.
pub fn command_config(
  query query: String,
  on_query_change on_query_change: fn(String) -> msg,
  items items: List(CommandItem(msg)),
) -> CommandConfig(msg) {
  CommandConfig(
    query: query,
    on_query_change: on_query_change,
    items: items,
    empty_message: "No results found.",
    attrs: [],
  )
}

/// Set the message displayed when no items match the search query.
pub fn command_empty_message(
  config config: CommandConfig(msg),
  message message: String,
) -> CommandConfig(msg) {
  CommandConfig(..config, empty_message: message)
}

/// Append additional attributes to the command palette root element.
pub fn command_attrs(
  config config: CommandConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> CommandConfig(msg) {
  case config {
    CommandConfig(attrs: existing, ..) ->
      CommandConfig(..config, attrs: list.append(existing, attrs))
  }
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
  let trimmed = string.trim(query)
  case string.is_empty(trimmed) {
    True -> list.filter(items, fn(item) { !item.disabled })
    False -> {
      let needle = string.lowercase(trimmed)
      list.filter(items, fn(item) {
        case item.disabled {
          True -> False
          False -> item_matches(item, needle)
        }
      })
    }
  }
}

fn item_matches(item: CommandItem(msg), needle: String) -> Bool {
  let label_match =
    string.contains(does: string.lowercase(item.label), contain: needle)
  let value_match =
    string.contains(does: string.lowercase(item.value), contain: needle)
  case label_match {
    True -> True
    False ->
      case value_match {
        True -> True
        False -> keywords_match(item.keywords, needle)
      }
  }
}

fn keywords_match(keywords: List(String), needle: String) -> Bool {
  case keywords {
    [] -> False
    [keyword, ..rest] ->
      case string.contains(does: string.lowercase(keyword), contain: needle) {
        True -> True
        False -> keywords_match(rest, needle)
      }
  }
}

/// Internal: read the query from a command config.
@internal
pub fn command_config_query(config config: CommandConfig(msg)) -> String {
  case config {
    CommandConfig(query:, ..) -> query
  }
}

/// Internal: read the on_query_change callback from a command config.
@internal
pub fn command_config_on_query_change(
  config config: CommandConfig(msg),
) -> fn(String) -> msg {
  case config {
    CommandConfig(on_query_change:, ..) -> on_query_change
  }
}

/// Internal: read the items from a command config.
@internal
pub fn command_config_items(
  config config: CommandConfig(msg),
) -> List(CommandItem(msg)) {
  case config {
    CommandConfig(items:, ..) -> items
  }
}

/// Internal: read the empty message from a command config.
@internal
pub fn command_config_empty_message(config config: CommandConfig(msg)) -> String {
  case config {
    CommandConfig(empty_message:, ..) -> empty_message
  }
}

/// Collect unique group names from a list of items, preserving first-seen order.
fn collect_group_names(items: List(CommandItem(msg))) -> List(String) {
  collect_group_names_loop(items, [], dict.new())
}

fn collect_group_names_loop(
  items: List(CommandItem(msg)),
  acc: List(String),
  seen: dict.Dict(String, Nil),
) -> List(String) {
  case items {
    [] -> list.reverse(acc)
    [item, ..rest] ->
      case item.group {
        None -> collect_group_names_loop(rest, acc, seen)
        Some(name) ->
          case dict.get(seen, name) {
            Ok(Nil) -> collect_group_names_loop(rest, acc, seen)
            Error(Nil) ->
              collect_group_names_loop(
                rest,
                [name, ..acc],
                dict.insert(seen, name, Nil),
              )
          }
      }
  }
}

fn render_item(item: CommandItem(msg)) -> weft_lustre.Element(msg) {
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

fn render_group(
  name: String,
  items: List(CommandItem(msg)),
) -> weft_lustre.Element(msg) {
  let heading =
    weft_lustre.element_tag(
      tag: "div",
      base_weft_attrs: [weft.el_layout()],
      attrs: [
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "command-group-heading",
        )),
      ],
      children: [weft_lustre.text(content: name)],
    )

  let item_elements = list.map(items, render_item)

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

/// Render the headless command palette.
///
/// Renders a root container with a search input and a filtered, grouped
/// list of command items. Items with no group render first, then grouped
/// items appear in first-seen order.
pub fn command(config config: CommandConfig(msg)) -> weft_lustre.Element(msg) {
  case config {
    CommandConfig(
      query: query,
      on_query_change: on_query_change,
      items: items,
      empty_message: empty_message,
      attrs: attrs,
    ) -> {
      let filtered = command_filter(items: items, query: query)

      let input_el =
        weft_lustre.element_tag(
          tag: "input",
          base_weft_attrs: [weft.el_layout()],
          attrs: [
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
            weft_lustre.html_attribute(attribute.attribute(
              "data-slot",
              "command-input-wrapper",
            )),
          ],
          children: [input_el],
        )

      let list_children = case filtered {
        [] -> [
          weft_lustre.element_tag(
            tag: "div",
            base_weft_attrs: [weft.el_layout()],
            attrs: [
              weft_lustre.html_attribute(attribute.attribute(
                "data-slot",
                "command-empty",
              )),
            ],
            children: [weft_lustre.text(content: empty_message)],
          ),
        ]
        _ -> build_grouped_children(filtered)
      }

      let list_el =
        weft_lustre.element_tag(
          tag: "div",
          base_weft_attrs: [weft.column_layout()],
          attrs: [
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
        attrs: list.flatten([
          [
            weft_lustre.html_attribute(attribute.attribute(
              "data-slot",
              "command",
            )),
          ],
          attrs,
        ]),
        children: [input_wrapper, list_el],
      )
    }
  }
}

fn build_grouped_children(
  filtered: List(CommandItem(msg)),
) -> List(weft_lustre.Element(msg)) {
  // Ungrouped items first
  let ungrouped =
    list.filter(filtered, fn(item) {
      case item.group {
        None -> True
        Some(_) -> False
      }
    })

  let ungrouped_elements = list.map(ungrouped, render_item)

  // Then grouped items in first-seen order
  let group_names = collect_group_names(filtered)
  let grouped_elements =
    list.map(group_names, fn(name) {
      let group_items =
        list.filter(filtered, fn(item) { item.group == Some(name) })
      render_group(name, group_items)
    })

  list.append(ungrouped_elements, grouped_elements)
}
