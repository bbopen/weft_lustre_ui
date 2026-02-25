//// Headless direction provider for shadcn compatibility.
////
//// Provides a lightweight wrapper that applies `dir` to a container.

import gleam/list
import lustre/attribute
import weft
import weft_lustre

type Dir {
  Ltr
  Rtl
}

/// Text direction token.
pub opaque type Direction {
  Direction(value: Dir)
}

/// Left-to-right direction.
pub fn direction_ltr() -> Direction {
  Direction(value: Ltr)
}

/// Right-to-left direction.
pub fn direction_rtl() -> Direction {
  Direction(value: Rtl)
}

fn direction_value(direction: Direction) -> String {
  case direction {
    Direction(value: Ltr) -> "ltr"
    Direction(value: Rtl) -> "rtl"
  }
}

/// Direction provider configuration.
pub opaque type DirectionConfig(msg) {
  DirectionConfig(direction: Direction, attrs: List(weft_lustre.Attribute(msg)))
}

/// Construct a direction provider configuration.
pub fn direction_provider_config(
  direction direction: Direction,
) -> DirectionConfig(msg) {
  DirectionConfig(direction: direction, attrs: [])
}

/// Append root attributes.
pub fn direction_provider_attrs(
  config config: DirectionConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> DirectionConfig(msg) {
  case config {
    DirectionConfig(attrs: existing, ..) ->
      DirectionConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Read the configured direction value.
pub fn use_direction(config config: DirectionConfig(msg)) -> Direction {
  case config {
    DirectionConfig(direction:, ..) -> direction
  }
}

/// Render a direction provider wrapper.
pub fn direction_provider(
  config config: DirectionConfig(msg),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  case config {
    DirectionConfig(direction: direction, attrs: attrs) ->
      weft_lustre.element_tag(
        tag: "div",
        base_weft_attrs: [weft.el_layout()],
        attrs: list.append(
          [
            weft_lustre.html_attribute(attribute.attribute(
              "dir",
              direction_value(direction),
            )),
          ],
          attrs,
        ),
        children: children,
      )
  }
}
