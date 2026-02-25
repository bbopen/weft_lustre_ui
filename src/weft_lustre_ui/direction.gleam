//// Styled direction provider for shadcn compatibility.
////
//// This component intentionally mirrors the headless API because direction
//// handling is semantic, not visual.

import weft_lustre
import weft_lustre_ui/headless/direction as headless_direction
import weft_lustre_ui/theme

/// Direction token alias.
pub type Direction =
  headless_direction.Direction

/// Direction configuration alias.
pub type DirectionConfig(msg) =
  headless_direction.DirectionConfig(msg)

/// Left-to-right direction.
pub fn direction_ltr(theme _theme: theme.Theme) -> Direction {
  headless_direction.direction_ltr()
}

/// Right-to-left direction.
pub fn direction_rtl(theme _theme: theme.Theme) -> Direction {
  headless_direction.direction_rtl()
}

/// Construct a direction provider configuration.
pub fn direction_provider_config(
  theme _theme: theme.Theme,
  direction direction: Direction,
) -> DirectionConfig(msg) {
  headless_direction.direction_provider_config(direction: direction)
}

/// Append root attributes.
pub fn direction_provider_attrs(
  theme _theme: theme.Theme,
  config config: DirectionConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> DirectionConfig(msg) {
  headless_direction.direction_provider_attrs(config: config, attrs: attrs)
}

/// Read the configured direction value.
pub fn use_direction(
  theme _theme: theme.Theme,
  config config: DirectionConfig(msg),
) -> Direction {
  headless_direction.use_direction(config: config)
}

/// Render a direction provider wrapper.
pub fn direction_provider(
  theme _theme: theme.Theme,
  config config: DirectionConfig(msg),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  headless_direction.direction_provider(config: config, children: children)
}
