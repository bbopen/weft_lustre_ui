//// Styled, theme-driven badge component for weft_lustre_ui.
////
//// This wrapper maps badge variants to theme token-driven values and keeps all
//// styling composed from `weft` attributes.

import gleam/list
import gleam/option.{type Option, None, Some}
import weft
import weft_lustre
import weft_lustre_ui/theme

type Variant {
  Default
  Secondary
  Destructive
  Outline
  Ghost
  Link
  Count
}

type Style {
  Style(
    background: weft.Color,
    foreground: weft.Color,
    border: Option(weft.Color),
    hover_decoration: Bool,
    hover_offset: Bool,
  )
}

/// Styled badge variant token.
pub opaque type BadgeVariant {
  BadgeVariant(value: Variant)
}

/// Default badge variant.
pub fn badge_default() -> BadgeVariant {
  BadgeVariant(value: Default)
}

/// Secondary badge variant.
pub fn badge_secondary() -> BadgeVariant {
  BadgeVariant(value: Secondary)
}

/// Destructive badge variant.
pub fn badge_destructive() -> BadgeVariant {
  BadgeVariant(value: Destructive)
}

/// Outline badge variant.
pub fn badge_outline() -> BadgeVariant {
  BadgeVariant(value: Outline)
}

/// Ghost badge variant.
pub fn badge_ghost() -> BadgeVariant {
  BadgeVariant(value: Ghost)
}

/// Link-like badge variant.
pub fn badge_link() -> BadgeVariant {
  BadgeVariant(value: Link)
}

/// Compact numeric count badge variant — minimal pill for short numbers.
pub fn badge_count() -> BadgeVariant {
  BadgeVariant(value: Count)
}

/// Styled badge configuration.
pub opaque type BadgeConfig(msg) {
  BadgeConfig(variant: BadgeVariant, attrs: List(weft_lustre.Attribute(msg)))
}

/// Construct a default badge configuration.
pub fn badge_config() -> BadgeConfig(msg) {
  BadgeConfig(variant: badge_default(), attrs: [])
}

/// Set the badge visual variant.
pub fn badge_variant(
  config config: BadgeConfig(msg),
  variant variant: BadgeVariant,
) -> BadgeConfig(msg) {
  BadgeConfig(..config, variant: variant)
}

/// Append additional attributes to the badge.
pub fn badge_attrs(
  config config: BadgeConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> BadgeConfig(msg) {
  case config {
    BadgeConfig(variant: variant, attrs: existing) ->
      BadgeConfig(variant: variant, attrs: list.append(existing, attrs))
  }
}

fn transparent_color() -> weft.Color {
  weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.0)
}

fn variant_styles(
  theme theme: theme.Theme,
  variant variant: BadgeVariant,
) -> Style {
  let #(primary_bg, primary_fg) = theme.primary(theme)
  let #(danger_bg, danger_fg) = theme.danger(theme)
  let #(surface_bg, surface_fg) = theme.surface(theme)
  let #(muted_bg, muted_fg) = theme.muted(theme)

  case variant {
    BadgeVariant(value: Default) ->
      Style(
        background: primary_bg,
        foreground: primary_fg,
        border: None,
        hover_decoration: False,
        hover_offset: False,
      )

    BadgeVariant(value: Secondary) ->
      Style(
        background: surface_bg,
        foreground: surface_fg,
        border: None,
        hover_decoration: False,
        hover_offset: False,
      )

    BadgeVariant(value: Destructive) ->
      Style(
        background: danger_bg,
        foreground: danger_fg,
        border: None,
        hover_decoration: False,
        hover_offset: False,
      )

    BadgeVariant(value: Outline) ->
      Style(
        background: transparent_color(),
        foreground: surface_fg,
        border: Some(theme.border_color(theme)),
        hover_decoration: False,
        hover_offset: False,
      )

    BadgeVariant(value: Ghost) ->
      Style(
        background: transparent_color(),
        foreground: surface_fg,
        border: None,
        hover_decoration: False,
        hover_offset: False,
      )

    BadgeVariant(value: Link) ->
      Style(
        background: transparent_color(),
        foreground: primary_fg,
        border: None,
        hover_decoration: True,
        hover_offset: False,
      )

    BadgeVariant(value: Count) ->
      Style(
        background: muted_bg,
        foreground: muted_fg,
        border: None,
        hover_decoration: False,
        hover_offset: False,
      )
  }
}

fn max_int(a: Int, b: Int) -> Int {
  case a >= b {
    True -> a
    False -> b
  }
}

fn badge_styles(
  theme theme: theme.Theme,
  variant variant: BadgeVariant,
) -> List(weft.Attribute) {
  let style = variant_styles(theme: theme, variant: variant)
  let #(surface_bg, _surface_fg) = theme.surface(theme)
  let muted = theme.muted_text(theme)
  let radius = theme.radius_md(theme)
  let base_space = theme.space_md(theme)

  let pad_x = max_int(8, base_space - 4)
  let pad_y = max_int(2, base_space / 4)

  list.flatten([
    [
      weft.display(value: weft.display_inline_flex()),
      weft.align_items(value: weft.align_items_center()),
      weft.justify_content(value: weft.justify_center()),
      weft.padding_xy(x: pad_x, y: pad_y),
      weft.spacing(pixels: 4),
      weft.rounded(radius: radius),
      weft.font_size(size: weft.rem(rem: 0.75)),
      weft.line_height(height: weft.line_height_multiple(multiplier: 1.0)),
      weft.font_weight(weight: weft.font_weight_value(weight: 500)),
      weft.text_color(color: style.foreground),
      weft.text_decoration(value: weft.text_decoration_none()),
      weft.user_select(value: weft.user_select_none()),
      weft.background(color: style.background),
    ],
    case style.border {
      None -> []
      Some(value) -> [
        weft.border(
          width: weft.px(pixels: 1),
          style: weft.border_style_solid(),
          color: value,
        ),
      ]
    },
    case style.hover_decoration {
      True -> [
        weft.mouse_over(attrs: [
          weft.text_decoration(value: weft.text_decoration_underline()),
        ]),
      ]
      False -> []
    },
    case style.hover_offset {
      True -> [
        weft.mouse_over(attrs: [
          weft.background(color: surface_bg),
          weft.text_color(color: muted),
        ]),
      ]

      False -> []
    },
  ])
}

fn badge_count_styles(
  theme theme: theme.Theme,
  variant variant: BadgeVariant,
) -> List(weft.Attribute) {
  let style = variant_styles(theme: theme, variant: variant)

  [
    weft.display(value: weft.display_inline_flex()),
    weft.align_items(value: weft.align_items_center()),
    weft.justify_content(value: weft.justify_center()),
    weft.width(length: weft.minimum(
      base: weft.shrink(),
      min: weft.px(pixels: 20),
    )),
    weft.height(length: weft.fixed(length: weft.px(pixels: 20))),
    weft.padding_xy(x: 4, y: 0),
    weft.rounded(radius: weft.px(pixels: 9999)),
    weft.font_size(size: weft.rem(rem: 0.75)),
    weft.line_height(height: weft.line_height_multiple(multiplier: 1.0)),
    weft.font_weight(weight: weft.font_weight_value(weight: 600)),
    weft.text_color(color: style.foreground),
    weft.background(color: style.background),
    weft.user_select(value: weft.user_select_none()),
  ]
}

fn is_count_variant(variant: BadgeVariant) -> Bool {
  case variant {
    BadgeVariant(value: Count) -> True
    _ -> False
  }
}

/// Render a styled badge.
pub fn badge(
  theme theme: theme.Theme,
  config config: BadgeConfig(msg),
  child child: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  case config {
    BadgeConfig(variant: variant, attrs: attrs) -> {
      let styles = case is_count_variant(variant) {
        True -> badge_count_styles(theme: theme, variant: variant)
        False -> badge_styles(theme: theme, variant: variant)
      }

      weft_lustre.element_tag(
        tag: "span",
        base_weft_attrs: [weft.el_layout()],
        attrs: [weft_lustre.styles(styles), ..attrs],
        children: [child],
      )
    }
  }
}
