//// Headless (unstyled) alert component for weft_lustre_ui.
////
//// This module provides an accessible inline alert with `role="alert"` and
//// structural sub-components for title, description, and an optional icon slot.
//// Visual styling is the responsibility of the caller or the styled wrapper.

import gleam/list
import lustre/attribute
import weft
import weft_lustre

type Variant {
  Default
  Destructive
}

/// An alert visual variant.
pub opaque type AlertVariant {
  AlertVariant(value: Variant)
}

/// Default alert variant.
pub fn alert_default() -> AlertVariant {
  AlertVariant(value: Default)
}

/// Destructive alert variant.
pub fn alert_destructive() -> AlertVariant {
  AlertVariant(value: Destructive)
}

/// Headless alert configuration.
pub opaque type AlertConfig(msg) {
  AlertConfig(variant: AlertVariant, attrs: List(weft_lustre.Attribute(msg)))
}

/// Construct a default alert configuration with the given variant.
pub fn alert_config(variant variant: AlertVariant) -> AlertConfig(msg) {
  AlertConfig(variant: variant, attrs: [])
}

/// Set the alert variant.
pub fn alert_variant(
  config config: AlertConfig(msg),
  variant variant: AlertVariant,
) -> AlertConfig(msg) {
  AlertConfig(..config, variant: variant)
}

/// Append additional attributes to the alert container.
pub fn alert_attrs(
  config config: AlertConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> AlertConfig(msg) {
  case config {
    AlertConfig(variant: variant, attrs: existing) ->
      AlertConfig(variant: variant, attrs: list.append(existing, attrs))
  }
}

/// Internal: read the variant from an AlertConfig.
@internal
pub fn alert_config_variant(config config: AlertConfig(msg)) -> AlertVariant {
  case config {
    AlertConfig(variant:, ..) -> variant
  }
}

/// Internal: check if variant is destructive.
@internal
pub fn alert_variant_is_destructive(variant variant: AlertVariant) -> Bool {
  case variant {
    AlertVariant(value: Destructive) -> True
    AlertVariant(value: Default) -> False
  }
}

/// Render a headless alert container with `role="alert"`.
pub fn alert(
  config config: AlertConfig(msg),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  case config {
    AlertConfig(variant: _, attrs: attrs) ->
      weft_lustre.element_tag(
        tag: "div",
        base_weft_attrs: [weft.column_layout()],
        attrs: list.flatten([
          [weft_lustre.html_attribute(attribute.role("alert"))],
          attrs,
        ]),
        children: children,
      )
  }
}

/// Render a headless alert title.
pub fn alert_title(
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "h5",
    base_weft_attrs: [weft.el_layout()],
    attrs: [],
    children: children,
  )
}

/// Render a headless alert description.
pub fn alert_description(
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.el_layout()],
    attrs: [],
    children: children,
  )
}
