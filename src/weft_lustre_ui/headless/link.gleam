//// Headless (unstyled) link component for weft_lustre_ui.
////
//// This module renders a native `<a>` element and wires up:
//// - `href`
//// - optional new-tab behavior (`target="_blank"` + `rel="noopener noreferrer"`)
//// - user-provided attributes and children
////
//// Visual styling is the responsibility of the caller (or the styled wrapper
//// in `weft_lustre_ui/link`).

import gleam/list
import lustre/attribute
import weft
import weft_lustre

type Target {
  SameTab
  NewTab
}

/// Headless link configuration.
pub opaque type LinkConfig(msg) {
  LinkConfig(
    href: String,
    target: Target,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default headless link config.
pub fn link_config(href href: String) -> LinkConfig(msg) {
  LinkConfig(href: href, target: SameTab, attrs: [])
}

/// Open the link in a new tab.
pub fn link_new_tab(config config: LinkConfig(msg)) -> LinkConfig(msg) {
  LinkConfig(..config, target: NewTab)
}

/// Open the link in the same tab (default).
pub fn link_same_tab(config config: LinkConfig(msg)) -> LinkConfig(msg) {
  LinkConfig(..config, target: SameTab)
}

/// Append additional attributes to the link.
///
/// Attributes are appended, so later attributes can override earlier ones.
pub fn link_attrs(
  config config: LinkConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> LinkConfig(msg) {
  case config {
    LinkConfig(attrs: existing, ..) ->
      LinkConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Render a headless link.
pub fn link(
  config config: LinkConfig(msg),
  child child: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  case config {
    LinkConfig(href: href, target: target, attrs: attrs) -> {
      let required =
        list.flatten([
          [weft_lustre.html_attribute(attribute.href(href))],
          case target {
            SameTab -> []
            NewTab -> [
              weft_lustre.html_attribute(attribute.target("_blank")),
              weft_lustre.html_attribute(attribute.rel("noopener noreferrer")),
            ]
          },
        ])

      weft_lustre.element_tag(
        tag: "a",
        base_weft_attrs: [weft.el_layout()],
        attrs: list.append(attrs, required),
        children: [child],
      )
    }
  }
}
