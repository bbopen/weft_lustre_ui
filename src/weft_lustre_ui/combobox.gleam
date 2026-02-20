//// Styled combobox component for weft_lustre_ui.
////
//// Wraps the headless combobox with theme-driven trigger, panel, search input,
//// and option-row styles. The panel is portalled via
//// `weft_lustre.anchored_overlay` when `anchor_rect` is provided, falling back
//// to a fixed-position overlay otherwise.

import gleam/option.{type Option}
import lustre/effect.{type Effect}
import weft
import weft_lustre
import weft_lustre_ui/headless/combobox as headless_combobox
import weft_lustre_ui/theme

/// Styled combobox configuration alias.
pub type ComboboxConfig(a, msg) =
  headless_combobox.ComboboxConfig(a, msg)

/// A single combobox option with a typed value and display label.
pub type ComboboxOption(a) =
  headless_combobox.ComboboxOption(a)

/// Construct a `ComboboxOption`.
pub fn combobox_option(value value: a, label label: String) -> ComboboxOption(a) {
  headless_combobox.combobox_option(value: value, label: label)
}

/// Construct combobox configuration.
pub fn combobox_config(
  options options: List(ComboboxOption(a)),
  value value: Option(a),
  on_select on_select: fn(Option(a)) -> msg,
  search search: String,
  on_search on_search: fn(String) -> msg,
  open open: Bool,
  on_toggle on_toggle: fn(Bool) -> msg,
  placeholder placeholder: String,
  anchor_rect anchor_rect: Option(weft.Rect),
  overlay_size overlay_size: weft.Size,
  viewport viewport: weft.Size,
  option_to_string option_to_string: fn(a) -> String,
) -> ComboboxConfig(a, msg) {
  headless_combobox.combobox_config(
    options: options,
    value: value,
    on_select: on_select,
    search: search,
    on_search: on_search,
    open: open,
    on_toggle: on_toggle,
    placeholder: placeholder,
    anchor_rect: anchor_rect,
    overlay_size: overlay_size,
    viewport: viewport,
    option_to_string: option_to_string,
  )
}

/// Append root-level attributes.
pub fn combobox_attrs(
  config config: ComboboxConfig(a, msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ComboboxConfig(a, msg) {
  headless_combobox.combobox_attrs(config: config, attrs: attrs)
}

/// Append trigger button attributes.
pub fn combobox_trigger_attrs(
  config config: ComboboxConfig(a, msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ComboboxConfig(a, msg) {
  headless_combobox.combobox_trigger_attrs(config: config, attrs: attrs)
}

/// Append panel container attributes.
pub fn combobox_panel_attrs(
  config config: ComboboxConfig(a, msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ComboboxConfig(a, msg) {
  headless_combobox.combobox_panel_attrs(config: config, attrs: attrs)
}

/// Placeholder effect for trigger measurement.
///
/// Returns `effect.none()` on all targets. Callers should capture click
/// coordinates from the trigger event and pass them as `anchor_rect` instead.
pub fn combobox_measure_on_open(
  trigger_id trigger_id: String,
  open open: Bool,
  on_measure on_measure: fn(weft.Rect, weft.Size, weft.Size) -> msg,
) -> Effect(msg) {
  headless_combobox.combobox_measure_on_open(
    trigger_id: trigger_id,
    open: open,
    on_measure: on_measure,
  )
}

fn trigger_styles(t: theme.Theme) -> List(weft.Attribute) {
  let #(surface_bg, surface_fg) = theme.surface(t)

  [
    weft.display(value: weft.display_inline_flex()),
    weft.align_items(value: weft.align_items_center()),
    weft.spacing(pixels: 6),
    weft.padding_xy(x: 10, y: 6),
    weft.rounded(radius: theme.radius_md(t)),
    weft.border(
      width: weft.px(pixels: 1),
      style: weft.border_style_solid(),
      color: theme.border_color(t),
    ),
    weft.background(color: surface_bg),
    weft.text_color(color: surface_fg),
    weft.font_size(size: weft.rem(rem: 0.8125)),
    weft.font_weight(weight: weft.font_weight_value(weight: 580)),
    weft.cursor(cursor: weft.cursor_pointer()),
    weft.outline_none(),
    weft.appearance(value: weft.appearance_none()),
    weft.font_family(families: theme.font_families(t)),
  ]
}

fn panel_styles(t: theme.Theme) -> List(weft.Attribute) {
  let #(overlay_bg, overlay_fg) = theme.overlay_surface(t)

  [
    weft.background(color: overlay_bg),
    weft.text_color(color: overlay_fg),
    weft.rounded(radius: theme.radius_md(t)),
    weft.border(
      width: weft.px(pixels: 1),
      style: weft.border_style_solid(),
      color: theme.border_color(t),
    ),
    weft.shadows(shadows: [
      weft.shadow(
        x: weft.px(pixels: 0),
        y: weft.px(pixels: 8),
        blur: weft.px(pixels: 24),
        spread: weft.px(pixels: -12),
        color: theme.tooltip_shadow(t),
      ),
    ]),
    weft.width(length: weft.minimum(
      base: weft.shrink(),
      min: weft.px(pixels: 200),
    )),
    weft.height(length: weft.maximum(
      base: weft.shrink(),
      max: weft.px(pixels: 300),
    )),
    weft.overflow_y(overflow: weft.overflow_auto()),
    weft.font_family(families: theme.font_families(t)),
    weft.font_size(size: weft.rem(rem: 0.875)),
  ]
}

fn search_input_styles(t: theme.Theme) -> List(weft.Attribute) {
  [
    weft.width(length: weft.fill()),
    weft.padding_xy(x: 8, y: 6),
    weft.border(
      width: weft.px(pixels: 0),
      style: weft.border_style_solid(),
      color: theme.border_color(t),
    ),
    weft.background(color: weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.0)),
    weft.outline_none(),
    weft.font_family(families: theme.font_families(t)),
    weft.font_size(size: weft.rem(rem: 0.875)),
  ]
}

fn option_row_styles(t: theme.Theme, is_selected: Bool) -> List(weft.Attribute) {
  let #(accent_bg, accent_fg) = theme.accent(theme: t)
  let #(_, overlay_fg) = theme.overlay_surface(t)
  let hover_color = theme.hover_surface(theme: t)

  let base_bg = case is_selected {
    True -> accent_bg
    False -> weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.0)
  }

  let base_fg = case is_selected {
    True -> accent_fg
    False -> overlay_fg
  }

  [
    weft.padding_xy(x: 8, y: 6),
    weft.cursor(cursor: weft.cursor_pointer()),
    weft.background(color: base_bg),
    weft.text_color(color: base_fg),
    weft.rounded(radius: theme.radius_md(t)),
    weft.mouse_over(attrs: [weft.background(color: hover_color)]),
  ]
}

/// Render the styled combobox.
///
/// Applies theme tokens to the trigger button, panel container, search input,
/// and each option row. Option rows receive selected-state styling using
/// `theme.accent` colors when the option value matches the configured `value`.
pub fn combobox(
  theme theme: theme.Theme,
  config config: ComboboxConfig(a, msg),
) -> weft_lustre.Element(msg) {
  let t = theme

  let styled_config =
    config
    |> headless_combobox.combobox_trigger_attrs(attrs: [
      weft_lustre.styles(trigger_styles(t)),
    ])
    |> headless_combobox.combobox_panel_attrs(attrs: [
      weft_lustre.styles(panel_styles(t)),
    ])
    |> headless_combobox.combobox_search_input_attrs(attrs: [
      weft_lustre.styles(search_input_styles(t)),
    ])
    |> headless_combobox.combobox_option_attrs_fn(
      option_attrs_fn: fn(_value, is_selected) {
        [weft_lustre.styles(option_row_styles(t, is_selected))]
      },
    )

  headless_combobox.combobox(config: styled_config)
}
