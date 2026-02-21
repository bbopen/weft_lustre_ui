//// Styled, theme-driven input group component for weft_lustre_ui.
////
//// Renders a container with `role="group"` and flex layout for grouping an
//// input with prefix/suffix addons. The container owns the border and radius;
//// the inner input is borderless so the group reads as a single control.

import gleam/list
import lustre/attribute
import weft
import weft_lustre
import weft_lustre_ui/headless/input_group as headless_input_group
import weft_lustre_ui/theme

/// Styled addon alignment alias.
pub type AddonAlign =
  headless_input_group.AddonAlign

/// Styled input group configuration alias.
pub type InputGroupConfig(msg) =
  headless_input_group.InputGroupConfig(msg)

/// Addon appears before the input (left in LTR).
pub fn addon_inline_start() -> AddonAlign {
  headless_input_group.addon_inline_start()
}

/// Addon appears after the input (right in LTR).
pub fn addon_inline_end() -> AddonAlign {
  headless_input_group.addon_inline_end()
}

/// Construct an input group configuration.
pub fn input_group_config() -> InputGroupConfig(msg) {
  headless_input_group.input_group_config()
}

/// Mark the input group as disabled.
pub fn input_group_disabled(
  config config: InputGroupConfig(msg),
) -> InputGroupConfig(msg) {
  headless_input_group.input_group_disabled(config: config)
}

/// Append root attributes.
pub fn input_group_attrs(
  config config: InputGroupConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> InputGroupConfig(msg) {
  headless_input_group.input_group_attrs(config: config, attrs: attrs)
}

fn group_styles(
  theme theme: theme.Theme,
  disabled disabled: Bool,
) -> List(weft.Attribute) {
  let border = theme.border_color(theme)
  let radius = theme.radius_md(theme)
  let #(surface_bg, _) = theme.input_surface(theme)
  let focus_ring = theme.focus_ring_color(theme)

  list.flatten([
    [
      weft.row_layout(),
      weft.align_items(value: weft.align_items_center()),
      weft.width(length: weft.fill()),
      weft.rounded(radius: radius),
      weft.background(color: surface_bg),
      weft.border(
        width: weft.px(pixels: 1),
        style: weft.border_style_solid(),
        color: border,
      ),
      weft.font_family(families: theme.font_families(theme)),
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
      weft.focus_within(attrs: [
        weft.outline(width: weft.px(pixels: 2), color: focus_ring),
        weft.outline_offset(length: weft.px(pixels: 2)),
      ]),
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

/// Render a styled input group.
pub fn input_group(
  theme theme: theme.Theme,
  config config: InputGroupConfig(msg),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let disabled =
    headless_input_group.input_group_config_disabled(config: config)
  let attrs = headless_input_group.input_group_config_attrs(config: config)

  let styled_attrs =
    list.flatten([
      [
        weft_lustre.html_attribute(attribute.role("group")),
        weft_lustre.styles(group_styles(theme: theme, disabled: disabled)),
      ],
      case disabled {
        True -> [
          weft_lustre.html_attribute(attribute.attribute("data-disabled", "")),
        ]
        False -> []
      },
      attrs,
    ])

  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.el_layout()],
    attrs: styled_attrs,
    children: children,
  )
}

fn addon_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  let muted = theme.muted_text(theme)

  [
    weft.display(value: weft.display_flex()),
    weft.align_items(value: weft.align_items_center()),
    weft.padding_xy(x: 10, y: 0),
    weft.text_color(color: muted),
    weft.font_size(size: weft.rem(rem: 0.875)),
  ]
}

/// Render a styled addon container (prefix or suffix).
pub fn input_group_addon(
  theme theme: theme.Theme,
  align align: AddonAlign,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let is_start = headless_input_group.addon_align_is_start(align: align)
  let order_value = case is_start {
    True -> -1
    False -> 999
  }

  let styled_attrs =
    list.flatten([
      [
        weft_lustre.styles(
          list.append(addon_styles(theme: theme), [
            weft.order(value: order_value),
          ]),
        ),
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "input-group-addon",
        )),
      ],
      attrs,
    ])

  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.el_layout()],
    attrs: styled_attrs,
    children: children,
  )
}

fn input_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  let #(_, surface_fg) = theme.input_surface(theme)

  [
    weft.width(length: weft.fill()),
    weft.background(color: weft.transparent()),
    weft.text_color(color: surface_fg),
    weft.border(
      width: weft.px(pixels: 0),
      style: weft.border_style_none(),
      color: weft.transparent(),
    ),
    weft.font_family(families: theme.font_families(theme)),
    weft.font_size(size: weft.rem(rem: 0.875)),
    weft.line_height(height: weft.line_height_multiple(multiplier: 1.4)),
    weft.padding_xy(x: 10, y: 8),
    weft.appearance(value: weft.appearance_none()),
    weft.outline_none(),
  ]
}

/// Render a styled input element within the group.
///
/// The input is borderless and transparent, inheriting the group container's
/// border and background.
pub fn input_group_input(
  theme theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> weft_lustre.Element(msg) {
  let styled_attrs =
    list.flatten([
      [
        weft_lustre.styles(input_styles(theme: theme)),
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "input-group-control",
        )),
      ],
      attrs,
    ])

  weft_lustre.element_tag(
    tag: "input",
    base_weft_attrs: [weft.el_layout()],
    attrs: styled_attrs,
    children: [],
  )
}

fn text_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  let muted = theme.muted_text(theme)

  [
    weft.display(value: weft.display_flex()),
    weft.align_items(value: weft.align_items_center()),
    weft.text_color(color: muted),
    weft.font_size(size: weft.rem(rem: 0.875)),
  ]
}

/// Render a styled text element within an addon.
///
/// Renders muted-color text sized slightly smaller than the input.
pub fn input_group_text(
  theme theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let styled_attrs =
    list.flatten([
      [
        weft_lustre.styles(text_styles(theme: theme)),
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "input-group-text",
        )),
      ],
      attrs,
    ])

  weft_lustre.element_tag(
    tag: "span",
    base_weft_attrs: [weft.el_layout()],
    attrs: styled_attrs,
    children: children,
  )
}
