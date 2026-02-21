//// Styled, theme-driven alert component for weft_lustre_ui.
////
//// This wrapper maps alert variants to theme token-driven colors and keeps all
//// styling composed from `weft` attributes.

import gleam/list
import lustre/attribute
import weft
import weft_lustre
import weft_lustre_ui/headless/alert as headless_alert
import weft_lustre_ui/theme

type Variant {
  Default
  Destructive
}

/// Styled alert variant token.
pub opaque type AlertVariant {
  AlertVariant(value: Variant)
}

/// Default alert variant.
pub fn alert_default() -> AlertVariant {
  AlertVariant(value: Default)
}

/// Destructive alert variant.
pub fn alert_destructive() -> AlertVariant {
  AlertVariant(value: Destructive)
}

/// Styled alert configuration.
pub opaque type AlertConfig(msg) {
  AlertConfig(variant: AlertVariant, attrs: List(weft_lustre.Attribute(msg)))
}

/// Construct a default alert configuration with the given variant.
pub fn alert_config(variant variant: AlertVariant) -> AlertConfig(msg) {
  AlertConfig(variant: variant, attrs: [])
}

/// Set the alert visual variant.
pub fn alert_variant(
  config config: AlertConfig(msg),
  variant variant: AlertVariant,
) -> AlertConfig(msg) {
  AlertConfig(..config, variant: variant)
}

/// Append additional attributes to the alert container.
pub fn alert_attrs(
  config config: AlertConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> AlertConfig(msg) {
  case config {
    AlertConfig(variant: variant, attrs: existing) ->
      AlertConfig(variant: variant, attrs: list.append(existing, attrs))
  }
}

fn alert_styles(
  theme theme: theme.Theme,
  variant variant: AlertVariant,
) -> List(weft.Attribute) {
  let #(surface_bg, surface_fg) = theme.surface(theme)
  let #(danger_bg, _danger_fg) = theme.danger(theme)
  let border_color = theme.border_color(theme)
  let radius = theme.radius_md(theme)
  let space = theme.space_md(theme)

  let #(border, text_color) = case variant {
    AlertVariant(value: Default) -> #(border_color, surface_fg)
    AlertVariant(value: Destructive) -> #(danger_bg, danger_bg)
  }

  [
    weft.background(color: surface_bg),
    weft.text_color(color: text_color),
    weft.rounded(radius: radius),
    weft.border(
      width: weft.px(pixels: 1),
      style: weft.border_style_solid(),
      color: border,
    ),
    weft.padding_xy(x: space + 4, y: space),
    weft.spacing(pixels: 4),
    weft.font_size(size: weft.rem(rem: 0.875)),
    weft.width(length: weft.fill()),
  ]
}

fn alert_title_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  let #(_surface_bg, surface_fg) = theme.surface(theme)

  [
    weft.text_color(color: surface_fg),
    weft.font_weight(weight: weft.font_weight_value(weight: 500)),
    weft.line_height(height: weft.line_height_multiple(multiplier: 1.4)),
    weft.letter_spacing(length: weft.em(em: -0.01)),
  ]
}

fn alert_description_styles(
  theme theme: theme.Theme,
  variant variant: AlertVariant,
) -> List(weft.Attribute) {
  let muted = theme.muted_text(theme)
  let #(danger_bg, _danger_fg) = theme.danger(theme)

  let color = case variant {
    AlertVariant(value: Default) -> muted
    AlertVariant(value: Destructive) -> danger_bg
  }

  [
    weft.text_color(color: color),
    weft.font_size(size: weft.rem(rem: 0.875)),
    weft.line_height(height: weft.line_height_multiple(multiplier: 1.6)),
  ]
}

/// Render a styled alert container.
pub fn alert(
  theme theme: theme.Theme,
  config config: AlertConfig(msg),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  case config {
    AlertConfig(variant: variant, attrs: attrs) -> {
      let styles = alert_styles(theme: theme, variant: variant)

      let headless_variant = case variant {
        AlertVariant(value: Default) -> headless_alert.alert_default()
        AlertVariant(value: Destructive) -> headless_alert.alert_destructive()
      }

      let headless_config =
        headless_alert.alert_config(variant: headless_variant)
        |> headless_alert.alert_attrs(attrs: [
          weft_lustre.styles(styles),
          ..attrs
        ])

      headless_alert.alert(config: headless_config, children: children)
    }
  }
}

/// Render a styled alert title.
pub fn alert_title(
  theme theme: theme.Theme,
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let styles = alert_title_styles(theme: theme)

  weft_lustre.element_tag(
    tag: "h5",
    base_weft_attrs: [weft.el_layout()],
    attrs: [weft_lustre.styles(styles)],
    children: children,
  )
}

/// Render a styled alert description.
///
/// The variant parameter determines the text color: muted for default,
/// danger color for destructive.
pub fn alert_description(
  theme theme: theme.Theme,
  variant variant: AlertVariant,
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let styles = alert_description_styles(theme: theme, variant: variant)

  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.el_layout()],
    attrs: [
      weft_lustre.styles(styles),
      weft_lustre.html_attribute(attribute.attribute(
        "data-slot",
        "alert-description",
      )),
    ],
    children: children,
  )
}
