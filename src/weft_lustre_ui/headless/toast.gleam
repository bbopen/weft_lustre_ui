//// Headless (unstyled) toast region and toast item for weft_lustre_ui.
////
//// Toasts are rendered structurally in the `Toast` layer via `toast_region`.
//// This avoids z-index stacking-context issues and keeps CSS generation
//// deterministic through `weft_lustre.layout`.
////
//// Visual styling is the responsibility of the caller (or the styled wrapper
//// in `weft_lustre_ui/toast`).

import gleam/list
import lustre/attribute
import lustre/effect
import lustre/event
import weft
import weft_lustre
import weft_lustre/time

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

/// Toast configuration.
pub opaque type ToastConfig(msg) {
  ToastConfig(on_dismiss: msg, attrs: List(weft_lustre.Attribute(msg)))
}

/// Construct a default toast config.
pub fn toast_config(on_dismiss on_dismiss: msg) -> ToastConfig(msg) {
  ToastConfig(on_dismiss: on_dismiss, attrs: [])
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

fn region_styles(corner: Corner) -> List(weft.Attribute) {
  let base = [
    weft.position(value: weft.position_fixed()),
    weft.pointer_events(value: weft.pointer_events_none()),
  ]

  let x = case corner {
    TopLeft -> [weft.left(length: weft.px(pixels: 0))]
    BottomLeft -> [weft.left(length: weft.px(pixels: 0))]
    TopRight -> [weft.right(length: weft.px(pixels: 0))]
    BottomRight -> [weft.right(length: weft.px(pixels: 0))]
  }

  let y = case corner {
    TopLeft -> [weft.top(length: weft.px(pixels: 0))]
    TopRight -> [weft.top(length: weft.px(pixels: 0))]
    BottomLeft -> [weft.bottom(length: weft.px(pixels: 0))]
    BottomRight -> [weft.bottom(length: weft.px(pixels: 0))]
  }

  let align = case corner {
    TopLeft -> [weft.align_items(value: weft.align_items_start())]
    BottomLeft -> [weft.align_items(value: weft.align_items_start())]
    TopRight -> [weft.align_items(value: weft.align_items_end())]
    BottomRight -> [weft.align_items(value: weft.align_items_end())]
  }

  list.flatten([base, x, y, align])
}

fn close_button(on_dismiss: msg) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "button",
    base_weft_attrs: [weft.el_layout()],
    attrs: [
      weft_lustre.html_attribute(attribute.type_("button")),
      weft_lustre.html_attribute(event.on_click(on_dismiss)),
      weft_lustre.html_attribute(attribute.aria_label("Dismiss")),
    ],
    children: [weft_lustre.text(content: "x")],
  )
}

/// Render a toast item.
pub fn toast(
  config config: ToastConfig(msg),
  content content: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  case config {
    ToastConfig(on_dismiss: on_dismiss, attrs: attrs) -> {
      let required_html_attrs = [
        weft_lustre.html_attribute(attribute.role("status")),
        weft_lustre.html_attribute(attribute.aria_live("polite")),
        weft_lustre.html_attribute(attribute.aria_atomic(True)),
      ]

      let structure_attrs = [
        weft_lustre.styles([
          // Re-enable pointer events on the toast item itself.
          weft.pointer_events(value: weft.pointer_events_auto()),
        ]),
      ]

      weft_lustre.row(
        attrs: list.flatten([structure_attrs, required_html_attrs, attrs]),
        children: [content, close_button(on_dismiss)],
      )
    }
  }
}

/// Render a fixed-position toast region in the `Toast` layer.
pub fn toast_region(
  corner corner: ToastCorner,
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let region =
    weft_lustre.column(
      attrs: [weft_lustre.styles(region_styles(corner_value(corner)))],
      children: children,
    )

  weft_lustre.toast(child: region)
}

/// Schedule an auto-dismiss timer.
///
/// This delegates to `weft_lustre/time.dispatch_after(...)`:
/// - JavaScript target: dispatches `on_dismiss` after `after_ms` milliseconds.
/// - Erlang/SSR target: returns `effect.none()`.
pub fn toast_auto_dismiss(
  after_ms after_ms: Int,
  on_dismiss on_dismiss: msg,
) -> effect.Effect(msg) {
  time.dispatch_after(after_ms: after_ms, msg: on_dismiss)
}
