//// Styled, theme-driven native select component for weft_lustre_ui.
////
//// Renders a native `<select>` element with input-like borders, padding,
//// and theme-driven styling. Delegates to the headless native select for
//// structure and semantics.

import gleam/list
import gleam/option.{type Option}
import weft
import weft_lustre
import weft_lustre_ui/headless/native_select as headless_native_select
import weft_lustre_ui/theme

/// Styled native select option alias.
pub type NativeSelectOption =
  headless_native_select.NativeSelectOption

/// Styled native select configuration alias.
pub type NativeSelectConfig(msg) =
  headless_native_select.NativeSelectConfig(msg)

/// Construct a native select option.
pub fn native_select_option(
  value value: String,
  label label: String,
) -> NativeSelectOption {
  headless_native_select.native_select_option(value: value, label: label)
}

/// Mark a native select option as disabled.
pub fn native_select_option_disabled(
  option option: NativeSelectOption,
) -> NativeSelectOption {
  headless_native_select.native_select_option_disabled(option: option)
}

/// Construct a native select configuration.
pub fn native_select_config(
  options options: List(NativeSelectOption),
  value value: Option(String),
  on_change on_change: fn(String) -> msg,
) -> NativeSelectConfig(msg) {
  headless_native_select.native_select_config(
    options: options,
    value: value,
    on_change: on_change,
  )
}

/// Set a placeholder option for the native select.
pub fn native_select_placeholder(
  config config: NativeSelectConfig(msg),
  placeholder placeholder: String,
) -> NativeSelectConfig(msg) {
  headless_native_select.native_select_placeholder(
    config: config,
    placeholder: placeholder,
  )
}

/// Disable the native select.
pub fn native_select_disabled(
  config config: NativeSelectConfig(msg),
) -> NativeSelectConfig(msg) {
  headless_native_select.native_select_disabled(config: config)
}

/// Append additional attributes to the native select.
pub fn native_select_attrs(
  config config: NativeSelectConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> NativeSelectConfig(msg) {
  headless_native_select.native_select_attrs(config: config, attrs: attrs)
}

fn select_styles(
  theme theme: theme.Theme,
  disabled disabled: Bool,
) -> List(weft.Attribute) {
  let #(input_bg, input_fg) = theme.input_surface(theme)
  let border = theme.border_color(theme)
  let radius = theme.radius_md(theme)

  list.flatten([
    [
      weft.display(value: weft.display_inline_flex()),
      weft.align_items(value: weft.align_items_center()),
      weft.height(length: weft.fixed(length: weft.px(pixels: 36))),
      weft.width(length: weft.fill()),
      weft.padding_xy(x: 12, y: 8),
      weft.rounded(radius: radius),
      weft.font_size(size: weft.rem(rem: 0.875)),
      weft.font_family(families: theme.font_families(theme)),
      weft.text_color(color: input_fg),
      weft.background(color: input_bg),
      weft.border(
        width: weft.px(pixels: 1),
        style: weft.border_style_solid(),
        color: border,
      ),
      weft.outline_none(),
      weft.appearance(value: weft.appearance_none()),
      weft.cursor(cursor: weft.cursor_pointer()),
      weft.transition(
        property: weft.transition_property_color(),
        duration: weft.ms(milliseconds: 150),
        easing: weft.ease(),
      ),
    ],
    case disabled {
      True -> [
        weft.alpha(opacity: theme.disabled_opacity(theme)),
        weft.cursor(cursor: weft.cursor_not_allowed()),
      ]
      False -> []
    },
  ])
}

/// Render a styled native `<select>` element.
pub fn native_select(
  theme theme: theme.Theme,
  config config: NativeSelectConfig(msg),
) -> weft_lustre.Element(msg) {
  let disabled =
    headless_native_select.native_select_config_disabled(config: config)

  let decorated =
    headless_native_select.native_select_attrs(config: config, attrs: [
      weft_lustre.styles(select_styles(theme: theme, disabled: disabled)),
    ])

  headless_native_select.native_select(config: decorated)
}
