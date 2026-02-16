//// Headless (unstyled) card primitives for weft_lustre_ui.
////
//// These functions provide the semantic card layout surface used by the styled
//// wrappers in `weft_lustre_ui/card`.

import weft
import weft_lustre

/// Render a card root container.
pub fn card(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.el_layout()],
    attrs: attrs,
    children: children,
  )
}

/// Render a card header section.
pub fn card_header(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.el_layout()],
    attrs: attrs,
    children: children,
  )
}

/// Render a card title section.
pub fn card_title(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "h3",
    base_weft_attrs: [weft.el_layout()],
    attrs: attrs,
    children: children,
  )
}

/// Render a card description section.
pub fn card_description(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "p",
    base_weft_attrs: [weft.el_layout()],
    attrs: attrs,
    children: children,
  )
}

/// Render a card action section.
pub fn card_action(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.el_layout()],
    attrs: attrs,
    children: children,
  )
}

/// Render a card content section.
pub fn card_content(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.el_layout()],
    attrs: attrs,
    children: children,
  )
}

/// Render a card footer section.
pub fn card_footer(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.el_layout()],
    attrs: attrs,
    children: children,
  )
}
