//// Toast region and item component for weft_lustre_ui (themed).
////
//// Toasts are rendered structurally in the `Toast` layer via `toast_region`.
//// This avoids z-index stacking-context issues and keeps CSS generation
//// deterministic through `weft_lustre.layout`.

import gleam/list
import lustre/attribute
import lustre/effect
import lustre/event
import weft
import weft_lustre
import weft_lustre/time
import weft_lustre_ui/theme

type Corner {
  TopLeft
  TopRight
  BottomLeft
  BottomRight
}

/// A toast region corner (viewport attachment point).
pub opaque type ToastCorner {
  ToastCorner(value: Corner)
}

/// Top-left toast corner.
pub fn toast_corner_top_left() -> ToastCorner {
  ToastCorner(value: TopLeft)
}

/// Top-right toast corner.
pub fn toast_corner_top_right() -> ToastCorner {
  ToastCorner(value: TopRight)
}

/// Bottom-left toast corner.
pub fn toast_corner_bottom_left() -> ToastCorner {
  ToastCorner(value: BottomLeft)
}

/// Bottom-right toast corner.
pub fn toast_corner_bottom_right() -> ToastCorner {
  ToastCorner(value: BottomRight)
}

fn corner_value(corner: ToastCorner) -> Corner {
  case corner {
    ToastCorner(value:) -> value
  }
}

type Variant {
  Neutral
  Info
  Danger
}

/// A toast visual variant.
pub opaque type ToastVariant {
  ToastVariant(value: Variant)
}

/// Neutral toast variant (uses overlay surface tokens).
pub fn toast_variant_neutral() -> ToastVariant {
  ToastVariant(value: Neutral)
}

/// Info toast variant (uses primary tokens).
pub fn toast_variant_info() -> ToastVariant {
  ToastVariant(value: Info)
}

/// Danger toast variant (uses danger tokens).
pub fn toast_variant_danger() -> ToastVariant {
  ToastVariant(value: Danger)
}

fn variant_value(variant: ToastVariant) -> Variant {
  case variant {
    ToastVariant(value:) -> value
  }
}

/// Toast configuration.
pub opaque type ToastConfig(msg) {
  ToastConfig(
    on_dismiss: msg,
    variant: ToastVariant,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default toast config.
pub fn toast_config(on_dismiss on_dismiss: msg) -> ToastConfig(msg) {
  ToastConfig(
    on_dismiss: on_dismiss,
    variant: toast_variant_neutral(),
    attrs: [],
  )
}

/// Set a toast variant.
pub fn toast_variant(
  config config: ToastConfig(msg),
  variant variant: ToastVariant,
) -> ToastConfig(msg) {
  ToastConfig(..config, variant: variant)
}

/// Append additional attributes to the toast item.
///
/// Attributes are appended, so later attributes can override earlier ones.
pub fn toast_attrs(
  config config: ToastConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ToastConfig(msg) {
  case config {
    ToastConfig(attrs: existing, ..) ->
      ToastConfig(..config, attrs: list.append(existing, attrs))
  }
}

fn non_negative(value: Int) -> Int {
  case value < 0 {
    True -> 0
    False -> value
  }
}

fn region_styles(corner: Corner, t: theme.Theme) -> List(weft.Attribute) {
  let space = theme.space_md(t)

  let base = [
    weft.position(value: weft.position_fixed()),
    weft.pointer_events(value: weft.pointer_events_none()),
    weft.spacing(pixels: space),
  ]

  let x = case corner {
    TopLeft -> [weft.left(length: weft.px(pixels: space))]
    BottomLeft -> [weft.left(length: weft.px(pixels: space))]
    TopRight -> [weft.right(length: weft.px(pixels: space))]
    BottomRight -> [weft.right(length: weft.px(pixels: space))]
  }

  let y = case corner {
    TopLeft -> [weft.top(length: weft.px(pixels: space))]
    TopRight -> [weft.top(length: weft.px(pixels: space))]
    BottomLeft -> [weft.bottom(length: weft.px(pixels: space))]
    BottomRight -> [weft.bottom(length: weft.px(pixels: space))]
  }

  let align = case corner {
    TopLeft -> [weft.align_items(value: weft.align_items_start())]
    BottomLeft -> [weft.align_items(value: weft.align_items_start())]
    TopRight -> [weft.align_items(value: weft.align_items_end())]
    BottomRight -> [weft.align_items(value: weft.align_items_end())]
  }

  list.flatten([base, x, y, align])
}

fn toast_colors(variant: Variant, t: theme.Theme) -> #(weft.Color, weft.Color) {
  case variant {
    Neutral -> theme.overlay_surface(t)
    Info -> theme.primary(t)
    Danger -> theme.danger(t)
  }
}

fn toast_styles(variant: Variant, t: theme.Theme) -> List(weft.Attribute) {
  let #(bg, fg) = toast_colors(variant, t)

  let shadow =
    weft.shadow(
      x: weft.px(pixels: 0),
      y: weft.px(pixels: 10),
      blur: weft.px(pixels: 28),
      spread: weft.px(pixels: -10),
      color: theme.toast_shadow(t),
    )

  [
    weft.pointer_events(value: weft.pointer_events_auto()),
    weft.background(color: bg),
    weft.text_color(color: fg),
    weft.padding(pixels: theme.space_md(t)),
    weft.rounded(radius: theme.radius_md(t)),
    weft.border(
      width: weft.px(pixels: 1),
      style: weft.border_style_solid(),
      color: theme.border_color(t),
    ),
    weft.width(length: weft.maximum(
      base: weft.shrink(),
      max: weft.rem(rem: 24.0),
    )),
    weft.shadows(shadows: [shadow]),
  ]
}

fn close_button(t: theme.Theme, on_dismiss: msg) -> weft_lustre.Element(msg) {
  let pad = non_negative(theme.space_md(t) - 4)

  let base = [
    weft.display(value: weft.display_inline_flex()),
    weft.align_items(value: weft.align_items_center()),
    weft.justify_content(value: weft.justify_center()),
    weft.padding_xy(x: pad, y: pad),
    weft.rounded(radius: weft.px(pixels: 9999)),
    weft.background(color: theme.toast_close_button_background(t)),
    weft.cursor(cursor: weft.cursor_pointer()),
    weft.user_select(value: weft.user_select_none()),
    weft.appearance(value: weft.appearance_none()),
    weft.outline_none(),
    weft.mouse_over(attrs: [weft.alpha(opacity: 0.75)]),
  ]

  weft_lustre.element_tag(
    tag: "button",
    base_weft_attrs: [weft.el_layout()],
    attrs: [
      weft_lustre.styles(base),
      weft_lustre.html_attribute(attribute.type_("button")),
      weft_lustre.html_attribute(event.on_click(on_dismiss)),
      weft_lustre.html_attribute(attribute.aria_label("Dismiss")),
    ],
    children: [weft_lustre.text(content: "x")],
  )
}

/// Render a toast item.
pub fn toast(
  theme theme: theme.Theme,
  config config: ToastConfig(msg),
  content content: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  case config {
    ToastConfig(on_dismiss: on_dismiss, variant: variant, attrs: attrs) -> {
      let required_html_attrs = [
        weft_lustre.html_attribute(attribute.role("status")),
        weft_lustre.html_attribute(attribute.aria_live("polite")),
        weft_lustre.html_attribute(attribute.aria_atomic(True)),
      ]

      let content_node =
        weft_lustre.el(
          attrs: [weft_lustre.styles([weft.width(length: weft.fill())])],
          child: content,
        )

      weft_lustre.row(
        attrs: list.flatten([
          [weft_lustre.styles(toast_styles(variant_value(variant), theme))],
          required_html_attrs,
          attrs,
        ]),
        children: [content_node, close_button(theme, on_dismiss)],
      )
    }
  }
}

/// Render a fixed-position toast region in the `Toast` layer.
pub fn toast_region(
  theme theme: theme.Theme,
  corner corner: ToastCorner,
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let region =
    weft_lustre.column(
      attrs: [weft_lustre.styles(region_styles(corner_value(corner), theme))],
      children: children,
    )

  weft_lustre.toast(child: region)
}

/// Schedule an auto-dismiss timer (JS-only).
///
/// - JavaScript target: dispatches `on_dismiss` after `after_ms` milliseconds.
/// - Erlang/SSR target: returns `effect.none()`.
pub fn toast_auto_dismiss(
  after_ms after_ms: Int,
  on_dismiss on_dismiss: msg,
) -> effect.Effect(msg) {
  time.dispatch_after(after_ms: after_ms, msg: on_dismiss)
}
