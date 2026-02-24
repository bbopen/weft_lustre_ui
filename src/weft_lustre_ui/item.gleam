//// Styled item primitives for shadcn-compatible list item composition.
////
//// Applies theme-driven defaults on top of `headless/item` slot structure.

import gleam/list
import weft
import weft_lustre
import weft_lustre_ui/headless/item as headless_item
import weft_lustre_ui/theme

/// Item surface variant token alias.
pub type ItemVariant =
  headless_item.ItemVariant

/// Item size token alias.
pub type ItemSize =
  headless_item.ItemSize

/// Item media variant token alias.
pub type ItemMediaVariant =
  headless_item.ItemMediaVariant

/// Styled item root configuration alias.
pub type ItemConfig(msg) =
  headless_item.ItemConfig(msg)

/// Styled item media configuration alias.
pub type ItemMediaConfig(msg) =
  headless_item.ItemMediaConfig(msg)

/// Default transparent item variant.
pub fn item_variant_default(theme _theme: theme.Theme) -> ItemVariant {
  headless_item.item_variant_default()
}

/// Outlined item variant.
pub fn item_variant_outline(theme _theme: theme.Theme) -> ItemVariant {
  headless_item.item_variant_outline()
}

/// Muted item variant.
pub fn item_variant_muted(theme _theme: theme.Theme) -> ItemVariant {
  headless_item.item_variant_muted()
}

/// Default item size.
pub fn item_size_default(theme _theme: theme.Theme) -> ItemSize {
  headless_item.item_size_default()
}

/// Small item size.
pub fn item_size_sm(theme _theme: theme.Theme) -> ItemSize {
  headless_item.item_size_sm()
}

/// Default media variant.
pub fn item_media_variant_default(theme _theme: theme.Theme) -> ItemMediaVariant {
  headless_item.item_media_variant_default()
}

/// Icon media variant.
pub fn item_media_variant_icon(theme _theme: theme.Theme) -> ItemMediaVariant {
  headless_item.item_media_variant_icon()
}

/// Image media variant.
pub fn item_media_variant_image(theme _theme: theme.Theme) -> ItemMediaVariant {
  headless_item.item_media_variant_image()
}

/// Construct a default item configuration.
pub fn item_config(theme _theme: theme.Theme) -> ItemConfig(msg) {
  headless_item.item_config()
}

/// Set the item variant.
pub fn item_variant(
  theme _theme: theme.Theme,
  config config: ItemConfig(msg),
  variant variant: ItemVariant,
) -> ItemConfig(msg) {
  headless_item.item_variant(config: config, variant: variant)
}

/// Set the item size.
pub fn item_size(
  theme _theme: theme.Theme,
  config config: ItemConfig(msg),
  size size: ItemSize,
) -> ItemConfig(msg) {
  headless_item.item_size(config: config, size: size)
}

/// Append item root attributes.
pub fn item_attrs(
  theme _theme: theme.Theme,
  config config: ItemConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ItemConfig(msg) {
  headless_item.item_attrs(config: config, attrs: attrs)
}

/// Construct a default item media configuration.
pub fn item_media_config(theme _theme: theme.Theme) -> ItemMediaConfig(msg) {
  headless_item.item_media_config()
}

/// Set the item media variant.
pub fn item_media_variant(
  theme _theme: theme.Theme,
  config config: ItemMediaConfig(msg),
  variant variant: ItemMediaVariant,
) -> ItemMediaConfig(msg) {
  headless_item.item_media_variant(config: config, variant: variant)
}

/// Append item media attributes.
pub fn item_media_attrs(
  theme _theme: theme.Theme,
  config config: ItemMediaConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ItemMediaConfig(msg) {
  headless_item.item_media_attrs(config: config, attrs: attrs)
}

/// Read the configured item variant.
pub fn item_config_variant(
  theme _theme: theme.Theme,
  config config: ItemConfig(msg),
) -> ItemVariant {
  headless_item.item_config_variant(config: config)
}

/// Read the configured item size.
pub fn item_config_size(
  theme _theme: theme.Theme,
  config config: ItemConfig(msg),
) -> ItemSize {
  headless_item.item_config_size(config: config)
}

/// Check whether the variant is default.
pub fn item_variant_is_default(
  theme _theme: theme.Theme,
  variant variant: ItemVariant,
) -> Bool {
  headless_item.item_variant_is_default(variant: variant)
}

/// Check whether the variant is outline.
pub fn item_variant_is_outline(
  theme _theme: theme.Theme,
  variant variant: ItemVariant,
) -> Bool {
  headless_item.item_variant_is_outline(variant: variant)
}

/// Check whether the variant is muted.
pub fn item_variant_is_muted(
  theme _theme: theme.Theme,
  variant variant: ItemVariant,
) -> Bool {
  headless_item.item_variant_is_muted(variant: variant)
}

/// Check whether the size is default.
pub fn item_size_is_default(
  theme _theme: theme.Theme,
  size size: ItemSize,
) -> Bool {
  headless_item.item_size_is_default(size: size)
}

/// Check whether the size is small.
pub fn item_size_is_sm(theme _theme: theme.Theme, size size: ItemSize) -> Bool {
  headless_item.item_size_is_sm(size: size)
}

/// Read the configured media variant.
pub fn item_media_config_variant(
  theme _theme: theme.Theme,
  config config: ItemMediaConfig(msg),
) -> ItemMediaVariant {
  headless_item.item_media_config_variant(config: config)
}

/// Check whether media variant is default.
pub fn item_media_variant_is_default(
  theme _theme: theme.Theme,
  variant variant: ItemMediaVariant,
) -> Bool {
  headless_item.item_media_variant_is_default(variant: variant)
}

/// Check whether media variant is icon.
pub fn item_media_variant_is_icon(
  theme _theme: theme.Theme,
  variant variant: ItemMediaVariant,
) -> Bool {
  headless_item.item_media_variant_is_icon(variant: variant)
}

/// Check whether media variant is image.
pub fn item_media_variant_is_image(
  theme _theme: theme.Theme,
  variant variant: ItemMediaVariant,
) -> Bool {
  headless_item.item_media_variant_is_image(variant: variant)
}

fn item_base_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  [
    weft.row_layout(),
    weft.align_items(value: weft.align_items_center()),
    weft.spacing(pixels: 12),
    weft.rounded(radius: theme.radius_md(theme)),
    weft.font_family(families: theme.font_families(theme)),
    weft.transitions(transitions: [
      weft.transition_item(
        property: weft.transition_property_all(),
        duration: weft.ms(milliseconds: 120),
        easing: weft.ease_out(),
      ),
    ]),
  ]
}

fn item_variant_styles(
  theme theme: theme.Theme,
  variant variant: ItemVariant,
) -> List(weft.Attribute) {
  let #(surface_bg, surface_fg) = theme.surface(theme)
  let border = theme.border_color(theme)
  let #(muted_bg, muted_fg) = theme.muted(theme)

  case headless_item.item_variant_is_outline(variant: variant) {
    True -> [
      weft.background(color: surface_bg),
      weft.text_color(color: surface_fg),
      weft.border(
        width: weft.px(pixels: 1),
        style: weft.border_style_solid(),
        color: border,
      ),
    ]
    False ->
      case headless_item.item_variant_is_muted(variant: variant) {
        True -> [
          weft.background(color: muted_bg),
          weft.text_color(color: muted_fg),
          weft.border(
            width: weft.px(pixels: 1),
            style: weft.border_style_solid(),
            color: weft.transparent(),
          ),
        ]
        False -> [
          weft.background(color: weft.transparent()),
          weft.text_color(color: surface_fg),
          weft.border(
            width: weft.px(pixels: 1),
            style: weft.border_style_solid(),
            color: weft.transparent(),
          ),
        ]
      }
  }
}

fn item_size_styles(size size: ItemSize) -> List(weft.Attribute) {
  case headless_item.item_size_is_sm(size: size) {
    True -> [weft.padding_xy(x: 12, y: 8), weft.spacing(pixels: 10)]
    False -> [weft.padding_xy(x: 16, y: 12), weft.spacing(pixels: 16)]
  }
}

/// Render a styled item root.
pub fn item(
  theme theme: theme.Theme,
  config config: ItemConfig(msg),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let variant = headless_item.item_config_variant(config: config)
  let size = headless_item.item_config_size(config: config)

  headless_item.item(
    config: config
      |> headless_item.item_attrs(attrs: [
        weft_lustre.styles(
          list.flatten([
            item_base_styles(theme: theme),
            item_variant_styles(theme: theme, variant: variant),
            item_size_styles(size: size),
          ]),
        ),
      ]),
    children: children,
  )
}

fn media_styles(
  theme theme: theme.Theme,
  variant variant: ItemMediaVariant,
) -> List(weft.Attribute) {
  let border = theme.border_color(theme)
  let #(muted_bg, _) = theme.muted(theme)

  list.flatten([
    [
      weft.display(value: weft.display_inline_flex()),
      weft.align_items(value: weft.align_items_center()),
      weft.justify_content(value: weft.justify_center()),
      weft.spacing(pixels: 8),
    ],
    case headless_item.item_media_variant_is_icon(variant: variant) {
      True -> [
        weft.width(length: weft.fixed(length: weft.px(pixels: 32))),
        weft.height(length: weft.fixed(length: weft.px(pixels: 32))),
        weft.background(color: muted_bg),
        weft.border(
          width: weft.px(pixels: 1),
          style: weft.border_style_solid(),
          color: border,
        ),
        weft.rounded(radius: theme.radius_md(theme)),
      ]
      False ->
        case headless_item.item_media_variant_is_image(variant: variant) {
          True -> [
            weft.width(length: weft.fixed(length: weft.px(pixels: 40))),
            weft.height(length: weft.fixed(length: weft.px(pixels: 40))),
            weft.rounded(radius: theme.radius_md(theme)),
            weft.overflow(overflow: weft.overflow_hidden()),
          ]
          False -> []
        }
    },
  ])
}

/// Render a styled item media container.
pub fn item_media(
  theme theme: theme.Theme,
  config config: ItemMediaConfig(msg),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let variant = headless_item.item_media_config_variant(config: config)

  headless_item.item_media(
    config: config
      |> headless_item.item_media_attrs(attrs: [
        weft_lustre.styles(media_styles(theme: theme, variant: variant)),
      ]),
    children: children,
  )
}

/// Render a styled item group.
pub fn item_group(
  theme theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  headless_item.item_group(
    attrs: list.append(
      [
        weft_lustre.styles([
          weft.column_layout(),
          weft.spacing(pixels: 8),
          weft.font_family(families: theme.font_families(theme)),
        ]),
      ],
      attrs,
    ),
    children: children,
  )
}

/// Render a styled item separator.
pub fn item_separator(
  theme theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> weft_lustre.Element(msg) {
  headless_item.item_separator(attrs: list.append(
    [
      weft_lustre.styles([
        weft.height(length: weft.fixed(length: weft.px(pixels: 1))),
        weft.width(length: weft.fixed(length: weft.pct(pct: 100.0))),
        weft.background(color: theme.border_color(theme)),
      ]),
    ],
    attrs,
  ))
}

/// Render a styled item content container.
pub fn item_content(
  theme theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  headless_item.item_content(
    attrs: list.append(
      [
        weft_lustre.styles([
          weft.column_layout(),
          weft.spacing(pixels: 4),
          weft.width(length: weft.fill()),
          weft.text_color(color: theme.muted_text(theme)),
        ]),
      ],
      attrs,
    ),
    children: children,
  )
}

/// Render a styled item title slot.
pub fn item_title(
  theme theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let #(_, surface_fg) = theme.surface(theme)

  headless_item.item_title(
    attrs: list.append(
      [
        weft_lustre.styles([
          weft.row_layout(),
          weft.align_items(value: weft.align_items_center()),
          weft.spacing(pixels: 8),
          weft.text_color(color: surface_fg),
          weft.font_weight(weight: weft.font_weight_value(weight: 600)),
        ]),
      ],
      attrs,
    ),
    children: children,
  )
}

/// Render a styled item description slot.
pub fn item_description(
  theme theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  headless_item.item_description(
    attrs: list.append(
      [
        weft_lustre.styles([
          weft.text_color(color: theme.muted_text(theme)),
          weft.font_size(size: weft.rem(rem: 0.875)),
          weft.line_height(height: weft.line_height_multiple(multiplier: 1.4)),
        ]),
      ],
      attrs,
    ),
    children: children,
  )
}

/// Render a styled item actions slot.
pub fn item_actions(
  theme _theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  headless_item.item_actions(
    attrs: list.append(
      [
        weft_lustre.styles([
          weft.row_layout(),
          weft.align_items(value: weft.align_items_center()),
          weft.justify_content(value: weft.justify_end()),
          weft.spacing(pixels: 8),
        ]),
      ],
      attrs,
    ),
    children: children,
  )
}

/// Render a styled item header slot.
pub fn item_header(
  theme theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let #(_, surface_fg) = theme.surface(theme)

  headless_item.item_header(
    attrs: list.append(
      [
        weft_lustre.styles([
          weft.row_layout(),
          weft.align_items(value: weft.align_items_center()),
          weft.justify_content(value: weft.justify_space_between()),
          weft.spacing(pixels: 8),
          weft.text_color(color: surface_fg),
        ]),
      ],
      attrs,
    ),
    children: children,
  )
}

/// Render a styled item footer slot.
pub fn item_footer(
  theme _theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  headless_item.item_footer(
    attrs: list.append(
      [
        weft_lustre.styles([
          weft.row_layout(),
          weft.align_items(value: weft.align_items_center()),
          weft.justify_content(value: weft.justify_space_between()),
          weft.spacing(pixels: 8),
        ]),
      ],
      attrs,
    ),
    children: children,
  )
}
