//// Styled table component wrappers for weft_lustre_ui.

import weft
import weft_lustre
import weft_lustre_ui/headless/table as headless_table
import weft_lustre_ui/theme

fn root_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  let #(surface_bg, surface_fg) = theme.surface(theme)

  [
    weft.width(length: weft.fixed(length: weft.pct(pct: 100.0))),
    weft.background(color: surface_bg),
    weft.text_color(color: surface_fg),
    weft.font_family(families: theme.font_families(theme)),
    weft.border(
      width: weft.px(pixels: 1),
      style: weft.border_style_solid(),
      color: theme.border_color(theme),
    ),
    weft.rounded(radius: theme.radius_md(theme)),
    weft.overflow(overflow: weft.overflow_hidden()),
  ]
}

fn row_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  [
    weft.border(
      width: weft.px(pixels: 1),
      style: weft.border_style_solid(),
      color: theme.border_color(theme),
    ),
  ]
}

fn cell_styles() -> List(weft.Attribute) {
  [
    weft.padding_xy(x: 10, y: 8),
    weft.font_size(size: weft.rem(rem: 0.875)),
    weft.text_align(align: weft.text_align_left()),
  ]
}

/// Render styled table root.
pub fn table(
  theme theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  headless_table.table(
    attrs: [weft_lustre.styles(root_styles(theme: theme)), ..attrs],
    children: children,
  )
}

/// Render styled table header section.
pub fn table_header(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  headless_table.table_header(attrs: attrs, children: children)
}

/// Render styled table body section.
pub fn table_body(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  headless_table.table_body(attrs: attrs, children: children)
}

/// Render styled table row.
pub fn table_row(
  theme theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  headless_table.table_row(
    attrs: [weft_lustre.styles(row_styles(theme: theme)), ..attrs],
    children: children,
  )
}

/// Render styled table head cell.
pub fn table_head(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  child child: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  headless_table.table_head(
    attrs: [weft_lustre.styles(cell_styles()), ..attrs],
    child: child,
  )
}

/// Render styled table data cell.
pub fn table_cell(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  child child: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  headless_table.table_cell(
    attrs: [weft_lustre.styles(cell_styles()), ..attrs],
    child: child,
  )
}
