//// Theme tokens and typography adjustment configuration for weft_lustre_ui.
////
//// Themes are consumed by the styled component layer in this package. Headless
//// components do not read theme values.

import gleam/float
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order
import gleam/result
import weft

/// A UI kit theme.
pub opaque type Theme {
  Theme(
    font_families: List(weft.FontFamily),
    primary: #(weft.Color, weft.Color),
    danger: #(weft.Color, weft.Color),
    surface: #(weft.Color, weft.Color),
    input_surface: #(weft.Color, weft.Color),
    overlay_surface: #(weft.Color, weft.Color),
    border_color: weft.Color,
    button_shadow_base: weft.Color,
    button_shadow_hover: weft.Color,
    tooltip_shadow: weft.Color,
    dialog_shadow: weft.Color,
    toast_shadow: weft.Color,
    toast_close_button_background: weft.Color,
    muted_text: weft.Color,
    focus_ring_color: weft.Color,
    scrim: weft.Color,
    radius_md: weft.CssLength,
    space_md: Int,
    disabled_opacity: Float,
    font_adjustment: Option(FontAdjustment),
  )
}

/// Font metrics used to improve baseline alignment and clipping behavior for
/// UI components.
pub opaque type FontAdjustment {
  FontAdjustment(
    line_height: Float,
    capital: Float,
    lowercase: Float,
    baseline: Float,
    descender: Float,
  )
}

fn clamp_non_negative(value: Float) -> Float {
  case float.compare(value, with: value) {
    order.Eq ->
      case value <. 0.0 {
        True -> 0.0
        False -> value
      }
    _ -> 0.0
  }
}

fn clamp_unit(default: Float, value: Float) -> Float {
  case float.compare(value, with: value) {
    order.Eq -> {
      case value <. 0.0 {
        True -> 0.0
        False ->
          case value >. 1.0 {
            True -> 1.0
            False -> value
          }
      }
    }
    _ -> default
  }
}

fn clamp_positive_or(default: Float, value: Float) -> Float {
  case float.compare(value, with: value) {
    order.Eq ->
      case value <=. 0.0 {
        True -> default
        False -> value
      }
    _ -> default
  }
}

fn clamp_non_negative_int(value: Int) -> Int {
  case value < 0 {
    True -> 0
    False -> value
  }
}

/// A default theme suitable for professional applications.
pub fn theme_default() -> Theme {
  Theme(
    font_families: [
      weft.font_system_ui(),
      weft.font_sans_serif(),
      weft.font_emoji(),
    ],
    primary: #(
      weft.rgb(red: 9, green: 9, blue: 11),
      weft.rgb(red: 255, green: 255, blue: 255),
    ),
    danger: #(
      weft.rgb(red: 185, green: 28, blue: 28),
      weft.rgb(red: 255, green: 255, blue: 255),
    ),
    surface: #(
      weft.rgb(red: 255, green: 255, blue: 255),
      weft.rgb(red: 9, green: 9, blue: 11),
    ),
    input_surface: #(
      weft.rgb(red: 255, green: 255, blue: 255),
      weft.rgb(red: 9, green: 9, blue: 11),
    ),
    overlay_surface: #(
      weft.rgb(red: 255, green: 255, blue: 255),
      weft.rgb(red: 9, green: 9, blue: 11),
    ),
    border_color: weft.rgb(red: 228, green: 228, blue: 231),
    button_shadow_base: weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.0),
    button_shadow_hover: weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.0),
    tooltip_shadow: weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.12),
    dialog_shadow: weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.18),
    toast_shadow: weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.16),
    toast_close_button_background: weft.rgba(
      red: 0,
      green: 0,
      blue: 0,
      alpha: 0.0,
    ),
    muted_text: weft.rgba(red: 63, green: 63, blue: 70, alpha: 0.85),
    focus_ring_color: weft.rgb(red: 113, green: 113, blue: 122),
    scrim: weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.5),
    radius_md: weft.px(pixels: 8),
    space_md: 12,
    disabled_opacity: 0.6,
    font_adjustment: None,
  )
}

/// Set the default font family list for components.
pub fn theme_font_family(
  theme theme: Theme,
  families families: List(weft.FontFamily),
) -> Theme {
  Theme(..theme, font_families: families)
}

/// Set the primary brand color and its contrasting foreground color.
pub fn theme_primary(
  theme theme: Theme,
  color color: weft.Color,
  on_color on_color: weft.Color,
) -> Theme {
  Theme(..theme, primary: #(color, on_color))
}

/// Set the danger color and its contrasting foreground color.
pub fn theme_danger(
  theme theme: Theme,
  color color: weft.Color,
  on_color on_color: weft.Color,
) -> Theme {
  Theme(..theme, danger: #(color, on_color))
}

/// Set the surface background color and its contrasting foreground color.
pub fn theme_surface(
  theme theme: Theme,
  color color: weft.Color,
  on_color on_color: weft.Color,
) -> Theme {
  Theme(..theme, surface: #(color, on_color))
}

/// Set the input surface background color and its contrasting foreground color.
pub fn theme_input_surface(
  theme theme: Theme,
  color color: weft.Color,
  on_color on_color: weft.Color,
) -> Theme {
  Theme(..theme, input_surface: #(color, on_color))
}

/// Set the overlay surface background color and its contrasting foreground
/// color.
pub fn theme_overlay_surface(
  theme theme: Theme,
  color color: weft.Color,
  on_color on_color: weft.Color,
) -> Theme {
  Theme(..theme, overlay_surface: #(color, on_color))
}

/// Set the default border color used by components.
pub fn theme_border(theme theme: Theme, color color: weft.Color) -> Theme {
  Theme(..theme, border_color: color)
}

/// Set the default muted text color used by components.
pub fn theme_muted_text(theme theme: Theme, color color: weft.Color) -> Theme {
  Theme(..theme, muted_text: color)
}

/// Set the focus ring color used by components.
pub fn theme_focus_ring(theme theme: Theme, color color: weft.Color) -> Theme {
  Theme(..theme, focus_ring_color: color)
}

/// Set the scrim color used by modal-like components.
pub fn theme_scrim(theme theme: Theme, color color: weft.Color) -> Theme {
  Theme(..theme, scrim: color)
}

/// Set the default medium radius used by components.
pub fn theme_radius_md(
  theme theme: Theme,
  radius radius: weft.CssLength,
) -> Theme {
  Theme(..theme, radius_md: radius)
}

/// Set the default medium spacing token used by components.
pub fn theme_space_md(theme theme: Theme, pixels pixels: Int) -> Theme {
  Theme(..theme, space_md: clamp_non_negative_int(pixels))
}

/// Set the button shadow colors (`base` for normal state, `hover` for hover state).
pub fn theme_button_shadows(
  theme theme: Theme,
  base base: weft.Color,
  hover hover: weft.Color,
) -> Theme {
  Theme(..theme, button_shadow_base: base, button_shadow_hover: hover)
}

/// Set the tooltip shadow color.
pub fn theme_tooltip_shadow(
  theme theme: Theme,
  color color: weft.Color,
) -> Theme {
  Theme(..theme, tooltip_shadow: color)
}

/// Set the dialog shadow color.
pub fn theme_dialog_shadow(theme theme: Theme, color color: weft.Color) -> Theme {
  Theme(..theme, dialog_shadow: color)
}

/// Set the toast shadow color.
pub fn theme_toast_shadow(theme theme: Theme, color color: weft.Color) -> Theme {
  Theme(..theme, toast_shadow: color)
}

/// Set the default close-button background color for toast actions.
pub fn theme_toast_close_button_background(
  theme theme: Theme,
  color color: weft.Color,
) -> Theme {
  Theme(..theme, toast_close_button_background: color)
}

/// Set the default disabled opacity used by components.
///
/// The value is clamped to `[0, 1]` and defaults to `0.6` if invalid.
pub fn theme_disabled_opacity(
  theme theme: Theme,
  opacity opacity: Float,
) -> Theme {
  Theme(..theme, disabled_opacity: clamp_unit(0.6, opacity))
}

/// Set the font adjustment used by components.
pub fn theme_font_adjustment(
  theme theme: Theme,
  adjustment adjustment: FontAdjustment,
) -> Theme {
  Theme(..theme, font_adjustment: Some(adjustment))
}

/// Construct a `FontAdjustment`.
///
/// `line_height` is clamped to be positive and defaults to `1.5` if invalid.
pub fn font_adjustment(
  line_height line_height: Float,
  capital capital: Float,
  lowercase lowercase: Float,
  baseline baseline: Float,
  descender descender: Float,
) -> FontAdjustment {
  FontAdjustment(
    line_height: clamp_positive_or(1.5, line_height),
    capital: clamp_non_negative(capital),
    lowercase: clamp_non_negative(lowercase),
    baseline: clamp_non_negative(baseline),
    descender: descender,
  )
}

/// Internal: get the theme font family list.
@internal
pub fn font_families(theme: Theme) -> List(weft.FontFamily) {
  case theme {
    Theme(font_families:, ..) -> font_families
  }
}

/// Internal: get the primary background/foreground color pair.
@internal
pub fn primary(theme: Theme) -> #(weft.Color, weft.Color) {
  case theme {
    Theme(primary:, ..) -> primary
  }
}

/// Internal: get the danger background/foreground color pair.
@internal
pub fn danger(theme: Theme) -> #(weft.Color, weft.Color) {
  case theme {
    Theme(danger:, ..) -> danger
  }
}

/// Internal: get the surface background/foreground color pair.
@internal
pub fn surface(theme: Theme) -> #(weft.Color, weft.Color) {
  case theme {
    Theme(surface:, ..) -> surface
  }
}

/// Internal: get the input surface background/foreground color pair.
@internal
pub fn input_surface(theme: Theme) -> #(weft.Color, weft.Color) {
  case theme {
    Theme(input_surface:, ..) -> input_surface
  }
}

/// Internal: get the overlay surface background/foreground color pair.
@internal
pub fn overlay_surface(theme: Theme) -> #(weft.Color, weft.Color) {
  case theme {
    Theme(overlay_surface:, ..) -> overlay_surface
  }
}

/// Internal: get the default border color.
@internal
pub fn border_color(theme: Theme) -> weft.Color {
  case theme {
    Theme(border_color:, ..) -> border_color
  }
}

/// Internal: get the normal button shadow color.
@internal
pub fn button_shadow_base(theme: Theme) -> weft.Color {
  case theme {
    Theme(button_shadow_base:, ..) -> button_shadow_base
  }
}

/// Internal: get the hover button shadow color.
@internal
pub fn button_shadow_hover(theme: Theme) -> weft.Color {
  case theme {
    Theme(button_shadow_hover:, ..) -> button_shadow_hover
  }
}

/// Internal: get the tooltip shadow color.
@internal
pub fn tooltip_shadow(theme: Theme) -> weft.Color {
  case theme {
    Theme(tooltip_shadow:, ..) -> tooltip_shadow
  }
}

/// Internal: get the dialog shadow color.
@internal
pub fn dialog_shadow(theme: Theme) -> weft.Color {
  case theme {
    Theme(dialog_shadow:, ..) -> dialog_shadow
  }
}

/// Internal: get the toast shadow color.
@internal
pub fn toast_shadow(theme: Theme) -> weft.Color {
  case theme {
    Theme(toast_shadow:, ..) -> toast_shadow
  }
}

/// Internal: get toast close-button background color.
@internal
pub fn toast_close_button_background(theme: Theme) -> weft.Color {
  case theme {
    Theme(toast_close_button_background:, ..) -> toast_close_button_background
  }
}

/// Internal: get the muted text color.
@internal
pub fn muted_text(theme: Theme) -> weft.Color {
  case theme {
    Theme(muted_text:, ..) -> muted_text
  }
}

/// Internal: get the focus ring color.
@internal
pub fn focus_ring_color(theme: Theme) -> weft.Color {
  case theme {
    Theme(focus_ring_color:, ..) -> focus_ring_color
  }
}

/// Internal: get the scrim color.
@internal
pub fn scrim_color(theme: Theme) -> weft.Color {
  case theme {
    Theme(scrim:, ..) -> scrim
  }
}

/// Internal: get the medium radius token.
@internal
pub fn radius_md(theme: Theme) -> weft.CssLength {
  case theme {
    Theme(radius_md:, ..) -> radius_md
  }
}

/// Internal: get the medium spacing token (pixels).
@internal
pub fn space_md(theme: Theme) -> Int {
  case theme {
    Theme(space_md:, ..) -> space_md
  }
}

/// Internal: get the disabled opacity token.
@internal
pub fn disabled_opacity(theme: Theme) -> Float {
  case theme {
    Theme(disabled_opacity:, ..) -> disabled_opacity
  }
}

/// Internal: get the optional font adjustment.
@internal
pub fn get_font_adjustment(theme: Theme) -> Option(FontAdjustment) {
  case theme {
    Theme(font_adjustment:, ..) -> font_adjustment
  }
}

type Converted {
  Converted(size: Float, vertical: Float, line_height: Float)
}

fn reverse_order(ord: order.Order) -> order.Order {
  case ord {
    order.Gt -> order.Lt
    order.Lt -> order.Gt
    order.Eq -> order.Eq
  }
}

fn max_float(values: List(Float), default: Float) -> Float {
  list.max(over: values, with: float.compare)
  |> result.unwrap(or: default)
}

fn min_float(values: List(Float), default: Float) -> Float {
  list.max(over: values, with: fn(a, b) { float.compare(a, b) |> reverse_order })
  |> result.unwrap(or: default)
}

fn convert_font_adjustment(
  adjustment: FontAdjustment,
) -> #(Converted, Converted) {
  case adjustment {
    FontAdjustment(line_height:, capital:, lowercase:, baseline:, descender:) -> {
      let lines = [capital, baseline, descender, lowercase]

      let ascender = max_float(lines, capital)
      let lowest = min_float(lines, descender)

      let new_baseline =
        lines
        |> list.filter(fn(x) { x != lowest })
        |> min_float(baseline)

      let full_height = ascender -. lowest
      let capital_height = ascender -. new_baseline

      let safe_full_height = case full_height <=. 0.0 {
        True -> 1.0
        False -> full_height
      }

      let safe_capital_height = case capital_height <=. 0.0 {
        True -> 1.0
        False -> capital_height
      }

      let full_size = 1.0 /. safe_full_height
      let capital_size = 1.0 /. safe_capital_height

      let vertical = 1.0 -. ascender

      #(
        Converted(
          size: full_size,
          vertical: vertical,
          line_height: line_height /. full_size,
        ),
        Converted(
          size: capital_size,
          vertical: vertical,
          line_height: line_height /. capital_size,
        ),
      )
    }
  }
}

/// Internal: wrapper/span weft rules for "full" font adjustment sizing.
@internal
pub fn font_adjustment_full_rules(
  adjustment: FontAdjustment,
) -> #(List(weft.Attribute), List(weft.Attribute)) {
  let #(full, _) = convert_font_adjustment(adjustment)
  converted_rules(full)
}

/// Internal: wrapper/span weft rules for "capital" font adjustment sizing.
@internal
pub fn font_adjustment_capital_rules(
  adjustment: FontAdjustment,
) -> #(List(weft.Attribute), List(weft.Attribute)) {
  let #(_, capital) = convert_font_adjustment(adjustment)
  converted_rules(capital)
}

fn converted_rules(
  converted: Converted,
) -> #(List(weft.Attribute), List(weft.Attribute)) {
  case converted {
    Converted(size:, vertical:, line_height:) -> #(
      [weft.display(value: weft.display_block())],
      [
        weft.display(value: weft.display_inline_block()),
        weft.line_height(height: weft.line_height_multiple(
          multiplier: line_height,
        )),
        weft.vertical_align(
          value: weft.vertical_align_length(length: weft.em(em: vertical)),
        ),
        weft.font_size(size: weft.em(em: size)),
      ],
    )
  }
}
