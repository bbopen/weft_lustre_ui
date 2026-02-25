//// Styled input-otp primitives for shadcn compatibility.
////
//// Applies theme-driven default styling to `headless/input_otp` slots.

import gleam/list
import weft
import weft_lustre
import weft_lustre_ui/headless/input_otp as headless_input_otp
import weft_lustre_ui/theme

/// Styled input-otp configuration alias.
pub type InputOtpConfig(msg) =
  headless_input_otp.InputOtpConfig(msg)

/// Construct an input-otp configuration.
pub fn input_otp_config(
  theme _theme: theme.Theme,
  value value: String,
  on_change on_change: fn(String) -> msg,
) -> InputOtpConfig(msg) {
  headless_input_otp.input_otp_config(value: value, on_change: on_change)
}

/// Set the number of OTP slots.
pub fn input_otp_length(
  theme _theme: theme.Theme,
  config config: InputOtpConfig(msg),
  length length: Int,
) -> InputOtpConfig(msg) {
  headless_input_otp.input_otp_length(config: config, length: length)
}

/// Disable OTP input.
pub fn input_otp_disabled(
  theme _theme: theme.Theme,
  config config: InputOtpConfig(msg),
) -> InputOtpConfig(msg) {
  headless_input_otp.input_otp_disabled(config: config)
}

/// Append root attributes.
pub fn input_otp_attrs(
  theme _theme: theme.Theme,
  config config: InputOtpConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> InputOtpConfig(msg) {
  headless_input_otp.input_otp_attrs(config: config, attrs: attrs)
}

/// Append container attributes.
pub fn input_otp_container_attrs(
  theme _theme: theme.Theme,
  config config: InputOtpConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> InputOtpConfig(msg) {
  headless_input_otp.input_otp_container_attrs(config: config, attrs: attrs)
}

/// Append group attributes.
pub fn input_otp_group_attrs(
  theme _theme: theme.Theme,
  config config: InputOtpConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> InputOtpConfig(msg) {
  headless_input_otp.input_otp_group_attrs(config: config, attrs: attrs)
}

/// Append slot attributes.
pub fn input_otp_slot_attrs(
  theme _theme: theme.Theme,
  config config: InputOtpConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> InputOtpConfig(msg) {
  headless_input_otp.input_otp_slot_attrs(config: config, attrs: attrs)
}

fn root_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  [
    weft.row_layout(),
    weft.align_items(value: weft.align_items_center()),
    weft.spacing(pixels: 8),
    weft.font_family(families: theme.font_families(theme)),
  ]
}

fn group_styles() -> List(weft.Attribute) {
  [
    weft.row_layout(),
    weft.align_items(value: weft.align_items_center()),
    weft.spacing(pixels: 0),
  ]
}

fn slot_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  let #(input_bg, input_fg) = theme.input_surface(theme)

  [
    weft.display(value: weft.display_inline_flex()),
    weft.align_items(value: weft.align_items_center()),
    weft.justify_content(value: weft.justify_center()),
    weft.width(length: weft.fixed(length: weft.px(pixels: 36))),
    weft.height(length: weft.fixed(length: weft.px(pixels: 36))),
    weft.border(
      width: weft.px(pixels: 1),
      style: weft.border_style_solid(),
      color: theme.border_color(theme),
    ),
    weft.background(color: input_bg),
    weft.text_color(color: input_fg),
    weft.text_align(align: weft.text_align_center()),
    weft.outline_none(),
    weft.font_family(families: theme.font_families(theme)),
    weft.font_size(size: weft.rem(rem: 0.875)),
  ]
}

fn separator_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  [
    weft.display(value: weft.display_inline_flex()),
    weft.align_items(value: weft.align_items_center()),
    weft.justify_content(value: weft.justify_center()),
    weft.width(length: weft.fixed(length: weft.px(pixels: 12))),
    weft.text_color(color: theme.muted_text(theme)),
  ]
}

/// Render a styled input-otp root.
pub fn input_otp(
  theme theme: theme.Theme,
  config config: InputOtpConfig(msg),
) -> weft_lustre.Element(msg) {
  headless_input_otp.input_otp(
    config: config
    |> headless_input_otp.input_otp_attrs(attrs: [
      weft_lustre.styles(root_styles(theme: theme)),
    ])
    |> headless_input_otp.input_otp_group_attrs(attrs: [
      weft_lustre.styles(group_styles()),
    ])
    |> headless_input_otp.input_otp_slot_attrs(attrs: [
      weft_lustre.styles(slot_styles(theme: theme)),
    ]),
  )
}

/// Render a styled OTP slot group.
pub fn input_otp_group(
  theme _theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  headless_input_otp.input_otp_group(
    attrs: list.append([weft_lustre.styles(group_styles())], attrs),
    children: children,
  )
}

/// Render a styled controlled OTP slot.
pub fn input_otp_slot(
  theme theme: theme.Theme,
  index index: Int,
  value value: String,
  on_input on_input: fn(String) -> msg,
  disabled disabled: Bool,
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> weft_lustre.Element(msg) {
  headless_input_otp.input_otp_slot(
    index: index,
    value: value,
    on_input: on_input,
    disabled: disabled,
    attrs: list.append([weft_lustre.styles(slot_styles(theme: theme))], attrs),
  )
}

/// Render a styled OTP separator slot.
pub fn input_otp_separator(
  theme theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> weft_lustre.Element(msg) {
  headless_input_otp.input_otp_separator(attrs: list.append(
    [weft_lustre.styles(separator_styles(theme: theme))],
    attrs,
  ))
}
