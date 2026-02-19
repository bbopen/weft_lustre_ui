//// Styled breadcrumb component for weft_lustre_ui.

import weft
import weft_lustre
import weft_lustre_ui/headless/breadcrumb as headless_breadcrumb
import weft_lustre_ui/theme

/// Styled breadcrumb item alias.
pub type BreadcrumbItem =
  headless_breadcrumb.BreadcrumbItem

/// Construct a breadcrumb item.
pub fn breadcrumb_item(label label: String) -> BreadcrumbItem {
  headless_breadcrumb.breadcrumb_item(label: label)
}

/// Set item href.
pub fn breadcrumb_item_href(
  item item: BreadcrumbItem,
  href href: String,
) -> BreadcrumbItem {
  headless_breadcrumb.breadcrumb_item_href(item: item, href: href)
}

/// Mark item as current.
pub fn breadcrumb_item_current(item item: BreadcrumbItem) -> BreadcrumbItem {
  headless_breadcrumb.breadcrumb_item_current(item: item)
}

/// Styled breadcrumb configuration.
pub opaque type BreadcrumbConfig(msg) {
  BreadcrumbConfig(value: headless_breadcrumb.BreadcrumbConfig(msg))
}

/// Construct breadcrumb configuration.
pub fn breadcrumb_config(
  items items: List(BreadcrumbItem),
) -> BreadcrumbConfig(msg) {
  BreadcrumbConfig(value: headless_breadcrumb.breadcrumb_config(items: items))
}

/// Set separator text.
pub fn breadcrumb_separator(
  config config: BreadcrumbConfig(msg),
  separator separator: String,
) -> BreadcrumbConfig(msg) {
  case config {
    BreadcrumbConfig(value:) ->
      BreadcrumbConfig(value: headless_breadcrumb.breadcrumb_separator(
        config: value,
        separator: separator,
      ))
  }
}

/// Append root attributes.
pub fn breadcrumb_attrs(
  config config: BreadcrumbConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> BreadcrumbConfig(msg) {
  case config {
    BreadcrumbConfig(value:) ->
      BreadcrumbConfig(value: headless_breadcrumb.breadcrumb_attrs(
        config: value,
        attrs: attrs,
      ))
  }
}

fn styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  [
    weft.font_family(families: theme.font_families(theme)),
    weft.font_size(size: weft.rem(rem: 0.875)),
    weft.text_color(color: theme.muted_text(theme)),
    weft.spacing(pixels: 8),
    weft.align_items(value: weft.align_items_center()),
  ]
}

/// Render a styled breadcrumb.
pub fn breadcrumb(
  theme theme: theme.Theme,
  config config: BreadcrumbConfig(msg),
) -> weft_lustre.Element(msg) {
  case config {
    BreadcrumbConfig(value:) ->
      headless_breadcrumb.breadcrumb(
        config: headless_breadcrumb.breadcrumb_attrs(config: value, attrs: [
          weft_lustre.styles(styles(theme: theme)),
        ]),
      )
  }
}
