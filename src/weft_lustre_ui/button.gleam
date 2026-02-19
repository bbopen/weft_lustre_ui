//// Accessible, themed button component for weft_lustre_ui.
////
//// Buttons compose weft primitives internally (pseudo-states, transitions,
//// typography) while keeping the app-facing API small and typed.

import gleam/list
import gleam/option.{None, Some}
import lustre/attribute
import lustre/event
import weft
import weft_lustre
import weft_lustre_ui/theme

type Variant {
  Primary
  Secondary
  Danger
}

/// A button visual variant.
pub opaque type ButtonVariant {
  ButtonVariant(value: Variant)
}

/// Primary button variant.
pub fn primary() -> ButtonVariant {
  ButtonVariant(value: Primary)
}

/// Secondary button variant.
pub fn secondary() -> ButtonVariant {
  ButtonVariant(value: Secondary)
}

/// Danger button variant.
pub fn danger() -> ButtonVariant {
  ButtonVariant(value: Danger)
}

fn variant_value(variant: ButtonVariant) -> Variant {
  case variant {
    ButtonVariant(value:) -> value
  }
}

type Size {
  Sm
  Md
  Lg
}

/// A button size.
pub opaque type ButtonSize {
  ButtonSize(value: Size)
}

/// Small button size.
pub fn sm() -> ButtonSize {
  ButtonSize(value: Sm)
}

/// Medium button size.
pub fn md() -> ButtonSize {
  ButtonSize(value: Md)
}

/// Large button size.
pub fn lg() -> ButtonSize {
  ButtonSize(value: Lg)
}

fn size_value(size: ButtonSize) -> Size {
  case size {
    ButtonSize(value:) -> value
  }
}

/// Button configuration.
pub opaque type ButtonConfig(msg) {
  ButtonConfig(
    on_press: msg,
    disabled: Bool,
    variant: ButtonVariant,
    size: ButtonSize,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default `ButtonConfig`.
pub fn button_config(on_press on_press: msg) -> ButtonConfig(msg) {
  ButtonConfig(
    on_press: on_press,
    disabled: False,
    variant: primary(),
    size: md(),
    attrs: [],
  )
}

/// Disable a button.
pub fn button_disabled(config config: ButtonConfig(msg)) -> ButtonConfig(msg) {
  ButtonConfig(..config, disabled: True)
}

/// Set a button variant.
pub fn button_variant(
  config config: ButtonConfig(msg),
  variant variant: ButtonVariant,
) -> ButtonConfig(msg) {
  ButtonConfig(..config, variant: variant)
}

/// Set a button size.
pub fn button_size(
  config config: ButtonConfig(msg),
  size size: ButtonSize,
) -> ButtonConfig(msg) {
  ButtonConfig(..config, size: size)
}

/// Append additional weft_lustre attributes to the button.
///
/// Attributes are appended, so later attributes can override earlier ones.
pub fn button_attrs(
  config config: ButtonConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ButtonConfig(msg) {
  case config {
    ButtonConfig(attrs: existing, ..) ->
      ButtonConfig(..config, attrs: list.append(existing, attrs))
  }
}

fn max_int(a: Int, b: Int) -> Int {
  case a >= b {
    True -> a
    False -> b
  }
}

fn padding_for(size: Size, space_md: Int) -> #(Int, Int) {
  let base_x = max_int(8, space_md)
  let base_y = max_int(4, space_md - 6)

  case size {
    Sm -> #(max_int(6, base_x - 2), max_int(4, base_y - 2))
    Md -> #(base_x, base_y)
    Lg -> #(base_x + 4, base_y + 2)
  }
}

fn font_size_for(size: Size) -> weft.CssLength {
  case size {
    Sm -> weft.rem(rem: 0.875)
    Md -> weft.rem(rem: 0.875)
    Lg -> weft.rem(rem: 1.0)
  }
}

fn default_colors(
  variant: Variant,
  t: theme.Theme,
) -> #(weft.Color, weft.Color, weft.Color) {
  let transparent = weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.0)
  let #(primary_bg, primary_fg) = theme.primary(t)
  let #(danger_bg, danger_fg) = theme.danger(t)
  let #(surface_bg, surface_fg) = theme.surface(t)

  case variant {
    Primary -> #(primary_bg, primary_fg, transparent)
    Secondary -> #(surface_bg, surface_fg, theme.border_color(t))
    Danger -> #(danger_bg, danger_fg, transparent)
  }
}

fn base_styles(
  variant: Variant,
  size: Size,
  disabled: Bool,
  t: theme.Theme,
) -> List(weft.Attribute) {
  let #(bg, fg, border) = default_colors(variant, t)
  let radius = theme.radius_md(t)
  let space_md = theme.space_md(t)
  let #(pad_x, pad_y) = padding_for(size, space_md)

  let cursor = case disabled {
    True -> weft.cursor_not_allowed()
    False -> weft.cursor_pointer()
  }

  let interaction_styles = case disabled {
    True -> []
    False -> [
      weft.mouse_over(attrs: [
        case variant {
          Primary -> weft.alpha(opacity: 0.92)
          Secondary ->
            weft.background(color: weft.rgb(red: 244, green: 244, blue: 245))
          Danger -> weft.alpha(opacity: 0.9)
        },
        weft.shadows(shadows: [
          weft.shadow(
            x: weft.px(pixels: 0),
            y: weft.px(pixels: 4),
            blur: weft.px(pixels: 12),
            spread: weft.px(pixels: -2),
            color: theme.button_shadow_hover(t),
          ),
        ]),
      ]),
      weft.active(attrs: [
        weft.alpha(opacity: 1.0),
        weft.shadows(shadows: [
          weft.shadow(
            x: weft.px(pixels: 0),
            y: weft.px(pixels: 1),
            blur: weft.px(pixels: 2),
            spread: weft.px(pixels: 0),
            color: theme.button_shadow_base(t),
          ),
        ]),
      ]),
    ]
  }

  list.flatten([
    [
      weft.display(value: weft.display_inline_flex()),
      weft.align_items(value: weft.align_items_center()),
      weft.justify_content(value: weft.justify_center()),
      weft.padding_xy(x: pad_x, y: pad_y),
      weft.rounded(radius: radius),
      weft.background(color: bg),
      weft.text_color(color: fg),
      weft.border(
        width: weft.px(pixels: 1),
        style: weft.border_style_solid(),
        color: border,
      ),
      weft.font_family(families: theme.font_families(t)),
      weft.font_weight(weight: weft.font_weight_value(weight: 600)),
      weft.font_size(size: font_size_for(size)),
      weft.line_height(height: weft.line_height_multiple(multiplier: 1.4)),
      weft.text_decoration(value: weft.text_decoration_none()),
      weft.user_select(value: weft.user_select_none()),
      weft.appearance(value: weft.appearance_none()),
      weft.cursor(cursor: cursor),
      weft.outline_none(),
      weft.shadows(shadows: [
        weft.shadow(
          x: weft.px(pixels: 0),
          y: weft.px(pixels: 1),
          blur: weft.px(pixels: 2),
          spread: weft.px(pixels: 0),
          color: theme.button_shadow_base(t),
        ),
      ]),
      weft.transitions(transitions: [
        weft.transition_item(
          property: weft.transition_property_all(),
          duration: weft.ms(milliseconds: 120),
          easing: weft.ease_out(),
        ),
      ]),
      weft.when(query: weft.prefers_reduced_motion(), attrs: [
        weft.transitions(transitions: []),
      ]),
      weft.focus_visible(attrs: [
        weft.outline(
          width: weft.px(pixels: 2),
          color: theme.focus_ring_color(t),
        ),
        weft.outline_offset(length: weft.px(pixels: 2)),
      ]),
      weft.disabled(attrs: [
        weft.alpha(opacity: theme.disabled_opacity(t)),
        weft.cursor(cursor: weft.cursor_not_allowed()),
        weft.shadows(shadows: []),
      ]),
    ],
    interaction_styles,
  ])
}

fn apply_font_adjustment(
  t: theme.Theme,
  label: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  case theme.get_font_adjustment(t) {
    None -> label
    Some(adjustment) -> {
      let #(outer, inner) = theme.font_adjustment_capital_rules(adjustment)

      let inner_span =
        weft_lustre.element_tag(
          tag: "span",
          base_weft_attrs: [weft.el_layout()],
          attrs: [weft_lustre.styles(inner)],
          children: [label],
        )

      weft_lustre.element_tag(
        tag: "span",
        base_weft_attrs: [weft.el_layout()],
        attrs: [weft_lustre.styles(outer)],
        children: [inner_span],
      )
    }
  }
}

/// Render a themed, accessible button.
pub fn button(
  theme theme: theme.Theme,
  config config: ButtonConfig(msg),
  label label: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  case config {
    ButtonConfig(on_press:, disabled:, variant:, size:, attrs:) -> {
      let required_html_attrs =
        list.flatten([
          [weft_lustre.html_attribute(attribute.type_("button"))],
          case disabled {
            True -> [weft_lustre.html_attribute(attribute.disabled(True))]
            False -> []
          },
          case disabled {
            True -> []
            False -> [weft_lustre.html_attribute(event.on_click(on_press))]
          },
        ])

      let styles =
        base_styles(variant_value(variant), size_value(size), disabled, theme)

      let adjusted_label = apply_font_adjustment(theme, label)

      let all_attrs =
        [weft_lustre.styles(styles), ..attrs]
        |> list.append(required_html_attrs)

      weft_lustre.element_tag(
        tag: "button",
        base_weft_attrs: [weft.row_layout()],
        attrs: all_attrs,
        children: [adjusted_label],
      )
    }
  }
}
