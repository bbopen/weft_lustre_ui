//// Headless breadcrumb primitives for weft_lustre_ui.

import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute
import weft
import weft_lustre

/// A breadcrumb item.
pub opaque type BreadcrumbItem {
  BreadcrumbItem(label: String, href: Option(String), current: Bool)
}

/// Construct a breadcrumb item.
pub fn breadcrumb_item(label label: String) -> BreadcrumbItem {
  BreadcrumbItem(label: label, href: None, current: False)
}

/// Set item href.
pub fn breadcrumb_item_href(
  item item: BreadcrumbItem,
  href href: String,
) -> BreadcrumbItem {
  BreadcrumbItem(..item, href: Some(href))
}

/// Mark an item as current page.
pub fn breadcrumb_item_current(item item: BreadcrumbItem) -> BreadcrumbItem {
  BreadcrumbItem(..item, current: True)
}

/// Headless breadcrumb configuration.
pub opaque type BreadcrumbConfig(msg) {
  BreadcrumbConfig(
    items: List(BreadcrumbItem),
    separator: String,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct default breadcrumb configuration.
pub fn breadcrumb_config(
  items items: List(BreadcrumbItem),
) -> BreadcrumbConfig(msg) {
  BreadcrumbConfig(items: items, separator: "/", attrs: [])
}

/// Set separator text.
pub fn breadcrumb_separator(
  config config: BreadcrumbConfig(msg),
  separator separator: String,
) -> BreadcrumbConfig(msg) {
  BreadcrumbConfig(..config, separator: separator)
}

/// Append root attributes.
pub fn breadcrumb_attrs(
  config config: BreadcrumbConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> BreadcrumbConfig(msg) {
  case config {
    BreadcrumbConfig(attrs: existing, ..) ->
      BreadcrumbConfig(..config, attrs: list.append(existing, attrs))
  }
}

fn render_item(item: BreadcrumbItem) -> weft_lustre.Element(msg) {
  case item {
    BreadcrumbItem(label:, href:, current:) -> {
      let child = case href {
        Some(path) ->
          weft_lustre.element_tag(
            tag: "a",
            base_weft_attrs: [weft.el_layout()],
            attrs: [
              weft_lustre.styles([
                weft.text_color(color: weft.rgba(
                  red: 63,
                  green: 63,
                  blue: 70,
                  alpha: 0.9,
                )),
                weft.text_decoration(value: weft.text_decoration_none()),
                weft.font_weight(weight: weft.font_weight_value(weight: 520)),
              ]),
              weft_lustre.html_attribute(attribute.href(path)),
            ],
            children: [weft_lustre.text(content: label)],
          )

        None -> weft_lustre.text(content: label)
      }

      let attrs = case current {
        True -> [
          weft_lustre.styles([
            weft.text_color(color: weft.rgb(red: 39, green: 39, blue: 42)),
            weft.font_weight(weight: weft.font_weight_value(weight: 500)),
          ]),
          weft_lustre.html_attribute(attribute.aria_current("page")),
        ]
        False -> []
      }

      weft_lustre.element_tag(
        tag: "span",
        base_weft_attrs: [weft.el_layout()],
        attrs: attrs,
        children: [child],
      )
    }
  }
}

fn intersperse_separator(
  items: List(weft_lustre.Element(msg)),
  separator: String,
) -> List(weft_lustre.Element(msg)) {
  case items {
    [] -> []
    [first, ..rest] ->
      list.fold(rest, [first], fn(acc, next) {
        list.append(acc, [
          weft_lustre.element_tag(
            tag: "span",
            base_weft_attrs: [weft.el_layout()],
            attrs: [weft_lustre.html_attribute(attribute.aria_hidden(True))],
            children: [weft_lustre.text(content: separator)],
          ),
          next,
        ])
      })
  }
}

/// Render headless breadcrumb navigation.
pub fn breadcrumb(
  config config: BreadcrumbConfig(msg),
) -> weft_lustre.Element(msg) {
  case config {
    BreadcrumbConfig(items: items, separator: separator, attrs: attrs) -> {
      let rendered =
        items |> list.map(render_item) |> intersperse_separator(separator)

      weft_lustre.element_tag(
        tag: "nav",
        base_weft_attrs: [weft.el_layout()],
        attrs: [
          weft_lustre.html_attribute(attribute.aria_label("Breadcrumb")),
          ..attrs
        ],
        children: [
          weft_lustre.element_tag(
            tag: "div",
            base_weft_attrs: [
              weft.row_layout(),
              weft.spacing(pixels: 8),
              weft.align_items(value: weft.align_items_center()),
            ],
            attrs: [],
            children: rendered,
          ),
        ],
      )
    }
  }
}
