//// Headless (unstyled) keyboard shortcut component for weft_lustre_ui.
////
//// Renders a semantic `<kbd>` element for displaying keyboard shortcuts.
//// Visual appearance is not applied here; the styled wrapper handles
//// typography, background, and border.

import gleam/list
import weft
import weft_lustre

/// Headless kbd configuration.
pub opaque type KbdConfig(msg) {
  KbdConfig(attrs: List(weft_lustre.Attribute(msg)))
}

/// Construct a default kbd configuration.
pub fn kbd_config() -> KbdConfig(msg) {
  KbdConfig(attrs: [])
}

/// Append additional attributes to the kbd element.
pub fn kbd_attrs(
  config config: KbdConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> KbdConfig(msg) {
  case config {
    KbdConfig(attrs: existing) -> KbdConfig(attrs: list.append(existing, attrs))
  }
}

/// Internal: read the attrs from a kbd config.
@internal
pub fn kbd_config_attrs(
  config config: KbdConfig(msg),
) -> List(weft_lustre.Attribute(msg)) {
  case config {
    KbdConfig(attrs:) -> attrs
  }
}

/// Render an unstyled `<kbd>` element.
pub fn kbd(
  config config: KbdConfig(msg),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  case config {
    KbdConfig(attrs: attrs) ->
      weft_lustre.element_tag(
        tag: "kbd",
        base_weft_attrs: [weft.el_layout()],
        attrs: attrs,
        children: children,
      )
  }
}
