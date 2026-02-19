//// Headless dropdown-menu component for weft_lustre_ui.
////
//// Uses semantic `<details>/<summary>` markup to provide an accessible
//// dependency-free dropdown interaction surface.

import gleam/list
import weft
import weft_lustre

/// Dropdown-menu configuration.
pub opaque type DropdownMenuConfig(msg) {
  DropdownMenuConfig(
    attrs: List(weft_lustre.Attribute(msg)),
    trigger_attrs: List(weft_lustre.Attribute(msg)),
    content_attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct dropdown-menu configuration.
pub fn dropdown_menu_config() -> DropdownMenuConfig(msg) {
  DropdownMenuConfig(attrs: [], trigger_attrs: [], content_attrs: [])
}

/// Append root attributes.
pub fn dropdown_menu_attrs(
  config config: DropdownMenuConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> DropdownMenuConfig(msg) {
  case config {
    DropdownMenuConfig(attrs: existing, ..) ->
      DropdownMenuConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Append trigger attributes.
pub fn dropdown_menu_trigger_attrs(
  config config: DropdownMenuConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> DropdownMenuConfig(msg) {
  case config {
    DropdownMenuConfig(trigger_attrs: existing, ..) ->
      DropdownMenuConfig(..config, trigger_attrs: list.append(existing, attrs))
  }
}

/// Append content attributes.
pub fn dropdown_menu_content_attrs(
  config config: DropdownMenuConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> DropdownMenuConfig(msg) {
  case config {
    DropdownMenuConfig(content_attrs: existing, ..) ->
      DropdownMenuConfig(..config, content_attrs: list.append(existing, attrs))
  }
}

/// Render headless dropdown menu.
pub fn dropdown_menu(
  config config: DropdownMenuConfig(msg),
  trigger trigger: weft_lustre.Element(msg),
  items items: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  case config {
    DropdownMenuConfig(
      attrs: attrs,
      trigger_attrs: trigger_attrs,
      content_attrs: content_attrs,
    ) ->
      weft_lustre.element_tag(
        tag: "details",
        base_weft_attrs: [weft.el_layout()],
        attrs: attrs,
        children: [
          weft_lustre.element_tag(
            tag: "summary",
            base_weft_attrs: [weft.el_layout()],
            attrs: trigger_attrs,
            children: [trigger],
          ),
          weft_lustre.column(attrs: content_attrs, children: items),
        ],
      )
  }
}
