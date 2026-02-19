//// Styled, theme-driven card component for weft_lustre_ui.
////
//// ShadCN-style card atoms with structural sections and explicit theme-driven
//// styling. The structure remains in `headless/card` while styling is composed here.

import gleam/list
import weft
import weft_lustre
import weft_lustre_ui/headless/card as headless_card
import weft_lustre_ui/theme

fn card_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  let #(bg, fg) = theme.surface(theme)

  [
    weft.display(value: weft.display_block()),
    weft.width(length: weft.fixed(length: weft.pct(pct: 100.0))),
    weft.background(color: bg),
    weft.text_color(color: fg),
    weft.border(
      width: weft.px(pixels: 1),
      style: weft.border_style_solid(),
      color: theme.border_color(theme),
    ),
    weft.rounded(radius: weft.px(pixels: 14)),
    weft.overflow(overflow: weft.overflow_hidden()),
    weft.font_family(families: theme.font_families(theme)),
    weft.shadows(shadows: [
      weft.shadow(
        x: weft.px(pixels: 0),
        y: weft.px(pixels: 1),
        blur: weft.px(pixels: 2),
        spread: weft.px(pixels: 0),
        color: weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.04),
      ),
    ]),
  ]
}

fn card_header_styles() -> List(weft.Attribute) {
  [
    weft.column_layout(),
    weft.spacing(pixels: 6),
  ]
}

fn card_title_styles() -> List(weft.Attribute) {
  [
    weft.font_size(size: weft.rem(rem: 1.5)),
    weft.line_height(height: weft.line_height_multiple(multiplier: 1.15)),
    weft.font_weight(weight: weft.font_weight_value(weight: 650)),
  ]
}

fn card_description_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  [
    weft.font_size(size: weft.rem(rem: 0.875)),
    weft.line_height(height: weft.line_height_multiple(multiplier: 1.4)),
    weft.text_color(color: theme.muted_text(theme)),
  ]
}

fn card_action_styles() -> List(weft.Attribute) {
  [
    weft.display(value: weft.display_flex()),
    weft.justify_content(value: weft.justify_end()),
  ]
}

fn card_header_section_styles() -> List(weft.Attribute) {
  [
    weft.padding(pixels: 20),
  ]
}

fn card_content_section_styles() -> List(weft.Attribute) {
  [
    weft.padding_xy(x: 20, y: 12),
  ]
}

fn card_footer_section_styles() -> List(weft.Attribute) {
  [
    weft.padding_xy(x: 20, y: 16),
  ]
}

/// Render a styled card root container.
pub fn card(
  theme theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let styled_attrs =
    attrs
    |> list.prepend(weft_lustre.styles(card_styles(theme: theme)))

  headless_card.card(attrs: styled_attrs, children: children)
}

/// Render a styled card header section.
pub fn card_header(
  theme _theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let styled_attrs =
    attrs
    |> list.prepend(
      weft_lustre.styles(
        list.flatten([
          card_header_section_styles(),
          card_header_styles(),
        ]),
      ),
    )

  headless_card.card_header(attrs: styled_attrs, children: children)
}

/// Render a styled card title section.
pub fn card_title(
  theme _theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let styled_attrs =
    attrs
    |> list.prepend(weft_lustre.styles(card_title_styles()))

  headless_card.card_title(attrs: styled_attrs, children: children)
}

/// Render a styled card description section.
pub fn card_description(
  theme theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let styled_attrs =
    attrs
    |> list.prepend(weft_lustre.styles(card_description_styles(theme: theme)))

  headless_card.card_description(attrs: styled_attrs, children: children)
}

/// Render a styled card action section.
pub fn card_action(
  theme _theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let styled_attrs =
    attrs
    |> list.prepend(weft_lustre.styles(card_action_styles()))

  headless_card.card_action(attrs: styled_attrs, children: children)
}

/// Render a styled card content section.
pub fn card_content(
  theme _theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let styled_attrs =
    attrs
    |> list.prepend(weft_lustre.styles(card_content_section_styles()))

  headless_card.card_content(attrs: styled_attrs, children: children)
}

/// Render a styled card footer section.
pub fn card_footer(
  theme _theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let styled_attrs =
    attrs
    |> list.prepend(weft_lustre.styles(card_footer_section_styles()))

  headless_card.card_footer(attrs: styled_attrs, children: children)
}
