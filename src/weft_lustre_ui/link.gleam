//// Themed link component for weft_lustre_ui.
////
//// Links are rendered as native `<a>` tags and styled using weft primitives.

import gleam/list
import lustre/attribute
import weft
import weft_lustre
import weft_lustre_ui/theme

type Target {
  SameTab
  NewTab
}

/// Link configuration.
pub opaque type LinkConfig(msg) {
  LinkConfig(
    href: String,
    target: Target,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default `LinkConfig`.
pub fn link_config(href href: String) -> LinkConfig(msg) {
  LinkConfig(href: href, target: SameTab, attrs: [])
}

/// Open the link in a new tab/window.
pub fn link_new_tab(config config: LinkConfig(msg)) -> LinkConfig(msg) {
  LinkConfig(..config, target: NewTab)
}

/// Open the link in the same tab/window (default).
pub fn link_same_tab(config config: LinkConfig(msg)) -> LinkConfig(msg) {
  LinkConfig(..config, target: SameTab)
}

/// Append additional weft_lustre attributes to the link.
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

fn base_styles(t: theme.Theme) -> List(weft.Attribute) {
  let #(primary_color, _) = theme.primary(t)

  [
    weft.display(value: weft.display_inline_block()),
    weft.font_family(families: theme.font_families(t)),
    weft.text_color(color: primary_color),
    weft.text_decoration(value: weft.text_decoration_none()),
    weft.cursor(cursor: weft.cursor_pointer()),
    weft.outline_none(),
    weft.alpha(opacity: 1.0),
    weft.transitions(transitions: [
      weft.transition_item(
        property: weft.transition_property_color(),
        duration: weft.ms(milliseconds: 120),
        easing: weft.ease_out(),
      ),
      weft.transition_item(
        property: weft.transition_property_opacity(),
        duration: weft.ms(milliseconds: 120),
        easing: weft.ease_out(),
      ),
    ]),
    weft.when(query: weft.prefers_reduced_motion(), attrs: [
      weft.transitions(transitions: []),
    ]),
    weft.mouse_over(attrs: [
      weft.text_decoration(value: weft.text_decoration_underline()),
      weft.alpha(opacity: 0.88),
    ]),
    weft.focus_visible(attrs: [
      weft.outline(width: weft.px(pixels: 2), color: theme.focus_ring_color(t)),
      weft.outline_offset(length: weft.px(pixels: 2)),
    ]),
  ]
}

/// Render a themed link.
pub fn link(
  theme theme: theme.Theme,
  config config: LinkConfig(msg),
  label label: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  case config {
    LinkConfig(href:, target:, attrs:) -> {
      let required_html_attrs =
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

      let all_attrs =
        [weft_lustre.styles(base_styles(theme)), ..attrs]
        |> list.append(required_html_attrs)

      weft_lustre.element_tag(
        tag: "a",
        base_weft_attrs: [weft.el_layout()],
        attrs: all_attrs,
        children: [label],
      )
    }
  }
}
