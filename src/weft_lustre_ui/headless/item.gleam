//// Headless item primitives for shadcn-compatible list item composition.
////
//// Provides structural slots for rich list rows (`item`, `item_media`,
//// `item_content`, `item_actions`, etc.) without visual styling.

import gleam/list
import lustre/attribute
import weft
import weft_lustre

type ItemVariantValue {
  Default
  Outline
  Muted
}

/// Item surface variant token.
pub opaque type ItemVariant {
  ItemVariant(value: ItemVariantValue)
}

/// Default transparent item variant.
pub fn item_variant_default() -> ItemVariant {
  ItemVariant(value: Default)
}

/// Outlined item variant.
pub fn item_variant_outline() -> ItemVariant {
  ItemVariant(value: Outline)
}

/// Muted item variant.
pub fn item_variant_muted() -> ItemVariant {
  ItemVariant(value: Muted)
}

type ItemSizeValue {
  SizeDefault
  SizeSm
}

/// Item size token.
pub opaque type ItemSize {
  ItemSize(value: ItemSizeValue)
}

/// Default item size.
pub fn item_size_default() -> ItemSize {
  ItemSize(value: SizeDefault)
}

/// Small item size.
pub fn item_size_sm() -> ItemSize {
  ItemSize(value: SizeSm)
}

type ItemMediaVariantValue {
  MediaDefault
  MediaIcon
  MediaImage
}

/// Item media variant token.
pub opaque type ItemMediaVariant {
  ItemMediaVariant(value: ItemMediaVariantValue)
}

/// Default media variant.
pub fn item_media_variant_default() -> ItemMediaVariant {
  ItemMediaVariant(value: MediaDefault)
}

/// Icon media variant.
pub fn item_media_variant_icon() -> ItemMediaVariant {
  ItemMediaVariant(value: MediaIcon)
}

/// Image media variant.
pub fn item_media_variant_image() -> ItemMediaVariant {
  ItemMediaVariant(value: MediaImage)
}

/// Item root configuration.
pub opaque type ItemConfig(msg) {
  ItemConfig(
    variant: ItemVariant,
    size: ItemSize,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default item configuration.
pub fn item_config() -> ItemConfig(msg) {
  ItemConfig(
    variant: item_variant_default(),
    size: item_size_default(),
    attrs: [],
  )
}

/// Set the item variant.
pub fn item_variant(
  config config: ItemConfig(msg),
  variant variant: ItemVariant,
) -> ItemConfig(msg) {
  ItemConfig(..config, variant: variant)
}

/// Set the item size.
pub fn item_size(
  config config: ItemConfig(msg),
  size size: ItemSize,
) -> ItemConfig(msg) {
  ItemConfig(..config, size: size)
}

/// Append item root attributes.
pub fn item_attrs(
  config config: ItemConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ItemConfig(msg) {
  case config {
    ItemConfig(attrs: existing, ..) ->
      ItemConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Item media configuration.
pub opaque type ItemMediaConfig(msg) {
  ItemMediaConfig(
    variant: ItemMediaVariant,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default item media configuration.
pub fn item_media_config() -> ItemMediaConfig(msg) {
  ItemMediaConfig(variant: item_media_variant_default(), attrs: [])
}

/// Set the item media variant.
pub fn item_media_variant(
  config config: ItemMediaConfig(msg),
  variant variant: ItemMediaVariant,
) -> ItemMediaConfig(msg) {
  ItemMediaConfig(..config, variant: variant)
}

/// Append item media attributes.
pub fn item_media_attrs(
  config config: ItemMediaConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ItemMediaConfig(msg) {
  case config {
    ItemMediaConfig(attrs: existing, ..) ->
      ItemMediaConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Internal: read the item variant.
@internal
pub fn item_config_variant(config config: ItemConfig(msg)) -> ItemVariant {
  case config {
    ItemConfig(variant:, ..) -> variant
  }
}

/// Internal: read the item size.
@internal
pub fn item_config_size(config config: ItemConfig(msg)) -> ItemSize {
  case config {
    ItemConfig(size:, ..) -> size
  }
}

/// Internal: check whether variant is default.
@internal
pub fn item_variant_is_default(variant variant: ItemVariant) -> Bool {
  case variant {
    ItemVariant(value: Default) -> True
    _ -> False
  }
}

/// Internal: check whether variant is outline.
@internal
pub fn item_variant_is_outline(variant variant: ItemVariant) -> Bool {
  case variant {
    ItemVariant(value: Outline) -> True
    _ -> False
  }
}

/// Internal: check whether variant is muted.
@internal
pub fn item_variant_is_muted(variant variant: ItemVariant) -> Bool {
  case variant {
    ItemVariant(value: Muted) -> True
    _ -> False
  }
}

/// Internal: check whether size is default.
@internal
pub fn item_size_is_default(size size: ItemSize) -> Bool {
  case size {
    ItemSize(value: SizeDefault) -> True
    _ -> False
  }
}

/// Internal: check whether size is small.
@internal
pub fn item_size_is_sm(size size: ItemSize) -> Bool {
  case size {
    ItemSize(value: SizeSm) -> True
    _ -> False
  }
}

/// Internal: read the media variant.
@internal
pub fn item_media_config_variant(
  config config: ItemMediaConfig(msg),
) -> ItemMediaVariant {
  case config {
    ItemMediaConfig(variant:, ..) -> variant
  }
}

/// Internal: check whether media variant is default.
@internal
pub fn item_media_variant_is_default(variant variant: ItemMediaVariant) -> Bool {
  case variant {
    ItemMediaVariant(value: MediaDefault) -> True
    _ -> False
  }
}

/// Internal: check whether media variant is icon.
@internal
pub fn item_media_variant_is_icon(variant variant: ItemMediaVariant) -> Bool {
  case variant {
    ItemMediaVariant(value: MediaIcon) -> True
    _ -> False
  }
}

/// Internal: check whether media variant is image.
@internal
pub fn item_media_variant_is_image(variant variant: ItemMediaVariant) -> Bool {
  case variant {
    ItemMediaVariant(value: MediaImage) -> True
    _ -> False
  }
}

/// Render an item root.
pub fn item(
  config config: ItemConfig(msg),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  case config {
    ItemConfig(variant: variant, size: size, attrs: attrs) ->
      weft_lustre.element_tag(
        tag: "div",
        base_weft_attrs: [weft.row_layout()],
        attrs: list.flatten([
          [weft_lustre.html_attribute(attribute.attribute("data-slot", "item"))],
          [
            weft_lustre.html_attribute(
              attribute.attribute("data-variant", case variant {
                ItemVariant(value: Default) -> "default"
                ItemVariant(value: Outline) -> "outline"
                ItemVariant(value: Muted) -> "muted"
              }),
            ),
          ],
          [
            weft_lustre.html_attribute(
              attribute.attribute("data-size", case size {
                ItemSize(value: SizeDefault) -> "default"
                ItemSize(value: SizeSm) -> "sm"
              }),
            ),
          ],
          attrs,
        ]),
        children: children,
      )
  }
}

/// Render an item group.
pub fn item_group(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.column_layout()],
    attrs: list.append(
      [
        weft_lustre.html_attribute(attribute.role("list")),
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "item-group",
        )),
      ],
      attrs,
    ),
    children: children,
  )
}

/// Render an item separator.
pub fn item_separator(
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.el_layout()],
    attrs: list.append(
      [
        weft_lustre.html_attribute(attribute.role("separator")),
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "item-separator",
        )),
      ],
      attrs,
    ),
    children: [],
  )
}

/// Render an item media container.
pub fn item_media(
  config config: ItemMediaConfig(msg),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  case config {
    ItemMediaConfig(variant: variant, attrs: attrs) ->
      weft_lustre.element_tag(
        tag: "div",
        base_weft_attrs: [weft.el_layout()],
        attrs: list.append(
          [
            weft_lustre.html_attribute(attribute.attribute(
              "data-slot",
              "item-media",
            )),
            weft_lustre.html_attribute(
              attribute.attribute("data-variant", case variant {
                ItemMediaVariant(value: MediaDefault) -> "default"
                ItemMediaVariant(value: MediaIcon) -> "icon"
                ItemMediaVariant(value: MediaImage) -> "image"
              }),
            ),
          ],
          attrs,
        ),
        children: children,
      )
  }
}

/// Render an item content container.
pub fn item_content(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.column_layout()],
    attrs: list.append(
      [
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "item-content",
        )),
      ],
      attrs,
    ),
    children: children,
  )
}

/// Render an item title slot.
pub fn item_title(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.row_layout()],
    attrs: list.append(
      [
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "item-title",
        )),
      ],
      attrs,
    ),
    children: children,
  )
}

/// Render an item description slot.
pub fn item_description(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "p",
    base_weft_attrs: [weft.el_layout()],
    attrs: list.append(
      [
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "item-description",
        )),
      ],
      attrs,
    ),
    children: children,
  )
}

/// Render an item actions slot.
pub fn item_actions(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.row_layout()],
    attrs: list.append(
      [
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "item-actions",
        )),
      ],
      attrs,
    ),
    children: children,
  )
}

/// Render an item header slot.
pub fn item_header(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.row_layout()],
    attrs: list.append(
      [
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "item-header",
        )),
      ],
      attrs,
    ),
    children: children,
  )
}

/// Render an item footer slot.
pub fn item_footer(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.row_layout()],
    attrs: list.append(
      [
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "item-footer",
        )),
      ],
      attrs,
    ),
    children: children,
  )
}
