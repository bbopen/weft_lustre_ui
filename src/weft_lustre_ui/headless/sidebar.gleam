//// Headless sidebar shell primitives for weft_lustre_ui.

import gleam/list
import weft
import weft_lustre

/// Sidebar configuration.
pub opaque type SidebarConfig(msg) {
  SidebarConfig(
    collapsed: Bool,
    attrs: List(weft_lustre.Attribute(msg)),
    aside_attrs: List(weft_lustre.Attribute(msg)),
    inset_attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct sidebar configuration.
pub fn sidebar_config() -> SidebarConfig(msg) {
  SidebarConfig(collapsed: False, attrs: [], aside_attrs: [], inset_attrs: [])
}

/// Collapse the sidebar.
pub fn sidebar_collapsed(
  config config: SidebarConfig(msg),
) -> SidebarConfig(msg) {
  SidebarConfig(..config, collapsed: True)
}

/// Expand the sidebar.
pub fn sidebar_expanded(config config: SidebarConfig(msg)) -> SidebarConfig(msg) {
  SidebarConfig(..config, collapsed: False)
}

/// Read whether the sidebar is collapsed.
pub fn sidebar_is_collapsed(config config: SidebarConfig(msg)) -> Bool {
  case config {
    SidebarConfig(collapsed:, ..) -> collapsed
  }
}

/// Append attributes on the root shell.
pub fn sidebar_attrs(
  config config: SidebarConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> SidebarConfig(msg) {
  case config {
    SidebarConfig(attrs: existing, ..) ->
      SidebarConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Append attributes on the `<aside>` shell.
pub fn sidebar_aside_attrs(
  config config: SidebarConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> SidebarConfig(msg) {
  case config {
    SidebarConfig(aside_attrs: existing, ..) ->
      SidebarConfig(..config, aside_attrs: list.append(existing, attrs))
  }
}

/// Append attributes on the `<main>` inset shell.
pub fn sidebar_inset_attrs(
  config config: SidebarConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> SidebarConfig(msg) {
  case config {
    SidebarConfig(inset_attrs: existing, ..) ->
      SidebarConfig(..config, inset_attrs: list.append(existing, attrs))
  }
}

/// Render headless sidebar shell.
pub fn sidebar(
  config config: SidebarConfig(msg),
  header header: weft_lustre.Element(msg),
  body body: List(weft_lustre.Element(msg)),
  footer footer: weft_lustre.Element(msg),
  inset inset: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  case config {
    SidebarConfig(
      attrs: attrs,
      aside_attrs: aside_attrs,
      inset_attrs: inset_attrs,
      ..,
    ) ->
      weft_lustre.row(attrs: attrs, children: [
        weft_lustre.element_tag(
          tag: "aside",
          base_weft_attrs: [weft.column_layout()],
          attrs: aside_attrs,
          children: [
            header,
            weft_lustre.column(attrs: [], children: body),
            footer,
          ],
        ),
        weft_lustre.element_tag(
          tag: "main",
          base_weft_attrs: [
            weft.column_layout(),
            weft.width(length: weft.fill()),
          ],
          attrs: inset_attrs,
          children: [inset],
        ),
      ])
  }
}
