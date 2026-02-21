//// Headless (unstyled) empty state component for weft_lustre_ui.
////
//// Provides a container for empty state messages with slots for icon, title,
//// description, and action content. Visual appearance is not applied here.

import gleam/list
import gleam/option.{type Option, None}
import weft
import weft_lustre

/// Headless empty state configuration.
pub opaque type EmptyConfig(msg) {
  EmptyConfig(
    icon: Option(weft_lustre.Element(msg)),
    title: Option(weft_lustre.Element(msg)),
    description: Option(weft_lustre.Element(msg)),
    action: Option(weft_lustre.Element(msg)),
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default empty state configuration.
pub fn empty_config() -> EmptyConfig(msg) {
  EmptyConfig(
    icon: None,
    title: None,
    description: None,
    action: None,
    attrs: [],
  )
}

/// Set the icon slot for the empty state.
pub fn empty_icon(
  config config: EmptyConfig(msg),
  icon icon: weft_lustre.Element(msg),
) -> EmptyConfig(msg) {
  EmptyConfig(..config, icon: option.Some(icon))
}

/// Set the title slot for the empty state.
pub fn empty_title(
  config config: EmptyConfig(msg),
  title title: weft_lustre.Element(msg),
) -> EmptyConfig(msg) {
  EmptyConfig(..config, title: option.Some(title))
}

/// Set the description slot for the empty state.
pub fn empty_description(
  config config: EmptyConfig(msg),
  description description: weft_lustre.Element(msg),
) -> EmptyConfig(msg) {
  EmptyConfig(..config, description: option.Some(description))
}

/// Set the action slot for the empty state.
pub fn empty_action(
  config config: EmptyConfig(msg),
  action action: weft_lustre.Element(msg),
) -> EmptyConfig(msg) {
  EmptyConfig(..config, action: option.Some(action))
}

/// Append additional attributes to the empty state container.
pub fn empty_attrs(
  config config: EmptyConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> EmptyConfig(msg) {
  case config {
    EmptyConfig(attrs: existing, ..) ->
      EmptyConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Internal: read the icon from an empty config.
@internal
pub fn empty_config_icon(
  config config: EmptyConfig(msg),
) -> Option(weft_lustre.Element(msg)) {
  case config {
    EmptyConfig(icon:, ..) -> icon
  }
}

/// Internal: read the title from an empty config.
@internal
pub fn empty_config_title(
  config config: EmptyConfig(msg),
) -> Option(weft_lustre.Element(msg)) {
  case config {
    EmptyConfig(title:, ..) -> title
  }
}

/// Internal: read the description from an empty config.
@internal
pub fn empty_config_description(
  config config: EmptyConfig(msg),
) -> Option(weft_lustre.Element(msg)) {
  case config {
    EmptyConfig(description:, ..) -> description
  }
}

/// Internal: read the action from an empty config.
@internal
pub fn empty_config_action(
  config config: EmptyConfig(msg),
) -> Option(weft_lustre.Element(msg)) {
  case config {
    EmptyConfig(action:, ..) -> action
  }
}

/// Internal: read the attrs from an empty config.
@internal
pub fn empty_config_attrs(
  config config: EmptyConfig(msg),
) -> List(weft_lustre.Attribute(msg)) {
  case config {
    EmptyConfig(attrs:, ..) -> attrs
  }
}

fn optional_child(
  slot: Option(weft_lustre.Element(msg)),
) -> List(weft_lustre.Element(msg)) {
  case slot {
    option.Some(child) -> [child]
    None -> []
  }
}

/// Render an unstyled empty state container.
pub fn empty(config config: EmptyConfig(msg)) -> weft_lustre.Element(msg) {
  case config {
    EmptyConfig(icon:, title:, description:, action:, attrs:) -> {
      let children =
        list.flatten([
          optional_child(icon),
          optional_child(title),
          optional_child(description),
          optional_child(action),
        ])

      weft_lustre.element_tag(
        tag: "div",
        base_weft_attrs: [weft.el_layout()],
        attrs: attrs,
        children: children,
      )
    }
  }
}
