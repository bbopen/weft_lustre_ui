//// Headless (unstyled) badge component for weft_lustre_ui.
////
//// This module provides only semantic badge structure and configuration. Styling is
//// intentionally absent so callers can layer either headless styles manually or
//// use the themed wrapper in `weft_lustre_ui/badge`.

import gleam/list
import weft
import weft_lustre

type Variant {
  Default
  Secondary
  Destructive
  Outline
  Ghost
  Link
}

/// A badge visual variant for headless construction.
pub opaque type BadgeVariant {
  BadgeVariant(value: Variant)
}

/// Default badge variant.
pub fn badge_default() -> BadgeVariant {
  BadgeVariant(value: Default)
}

/// Secondary badge variant.
pub fn badge_secondary() -> BadgeVariant {
  BadgeVariant(value: Secondary)
}

/// Destructive badge variant.
pub fn badge_destructive() -> BadgeVariant {
  BadgeVariant(value: Destructive)
}

/// Outline badge variant.
pub fn badge_outline() -> BadgeVariant {
  BadgeVariant(value: Outline)
}

/// Ghost badge variant.
pub fn badge_ghost() -> BadgeVariant {
  BadgeVariant(value: Ghost)
}

/// Link-like badge variant.
pub fn badge_link() -> BadgeVariant {
  BadgeVariant(value: Link)
}

/// Headless badge configuration.
pub opaque type BadgeConfig(msg) {
  BadgeConfig(variant: BadgeVariant, attrs: List(weft_lustre.Attribute(msg)))
}

/// Construct a default badge configuration.
pub fn badge_config() -> BadgeConfig(msg) {
  BadgeConfig(variant: badge_default(), attrs: [])
}

/// Set the badge variant.
pub fn badge_variant(
  config config: BadgeConfig(msg),
  variant variant: BadgeVariant,
) -> BadgeConfig(msg) {
  BadgeConfig(..config, variant: variant)
}

/// Append additional attributes to the badge wrapper.
pub fn badge_attrs(
  config config: BadgeConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> BadgeConfig(msg) {
  case config {
    BadgeConfig(variant: variant, attrs: existing) ->
      BadgeConfig(variant: variant, attrs: list.append(existing, attrs))
  }
}

/// Render a badge node.
pub fn badge(
  config config: BadgeConfig(msg),
  child child: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  case config {
    BadgeConfig(variant: _, attrs: attrs) ->
      weft_lustre.element_tag(
        tag: "span",
        base_weft_attrs: [weft.el_layout()],
        attrs: attrs,
        children: [child],
      )
  }
}
