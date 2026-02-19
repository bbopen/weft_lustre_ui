//// Headless table wrappers for weft_lustre_ui.

import weft
import weft_lustre

/// Render table root.
pub fn table(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "table",
    base_weft_attrs: [weft.el_layout()],
    attrs: attrs,
    children: children,
  )
}

/// Render table header section.
pub fn table_header(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "thead",
    base_weft_attrs: [weft.el_layout()],
    attrs: attrs,
    children: children,
  )
}

/// Render table body section.
pub fn table_body(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "tbody",
    base_weft_attrs: [weft.el_layout()],
    attrs: attrs,
    children: children,
  )
}

/// Render table row.
pub fn table_row(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "tr",
    base_weft_attrs: [weft.el_layout()],
    attrs: attrs,
    children: children,
  )
}

/// Render table head cell.
pub fn table_head(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  child child: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "th",
    base_weft_attrs: [weft.el_layout()],
    attrs: attrs,
    children: [child],
  )
}

/// Render table data cell.
pub fn table_cell(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  child child: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "td",
    base_weft_attrs: [weft.el_layout()],
    attrs: attrs,
    children: [child],
  )
}
