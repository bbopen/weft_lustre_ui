//// Headless (unstyled) tooltip component built on the anchored overlay micro-solver.
////
//// This module provides a small, typed component layer over `weft_lustre/overlay`:
//// - renders tooltip content in the `Tooltip` structural layer
//// - provides an effect helper that measures DOM rectangles and dispatches a
////   `weft.OverlaySolution`
////
//// Visual styling is the responsibility of the caller (or the styled wrapper
//// in `weft_lustre_ui/tooltip`).

import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/effect
import weft
import weft_lustre
import weft_lustre/overlay

/// Tooltip configuration.
pub opaque type TooltipConfig(msg) {
  TooltipConfig(
    key: overlay.OverlayKey,
    prefer_sides: List(weft.OverlaySide),
    alignments: List(weft.OverlayAlign),
    offset_px: Int,
    viewport_padding_px: Int,
    arrow: Option(#(Int, Int)),
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default tooltip config for the given key.
pub fn tooltip_config(key key: overlay.OverlayKey) -> TooltipConfig(msg) {
  TooltipConfig(
    key: key,
    prefer_sides: [],
    alignments: [],
    offset_px: 8,
    viewport_padding_px: 8,
    arrow: None,
    attrs: [],
  )
}

/// Set the preferred side order for a tooltip.
pub fn tooltip_prefer_sides(
  config config: TooltipConfig(msg),
  sides sides: List(weft.OverlaySide),
) -> TooltipConfig(msg) {
  TooltipConfig(..config, prefer_sides: sides)
}

/// Set the allowed alignments for a tooltip.
pub fn tooltip_alignments(
  config config: TooltipConfig(msg),
  alignments alignments: List(weft.OverlayAlign),
) -> TooltipConfig(msg) {
  TooltipConfig(..config, alignments: alignments)
}

/// Set the tooltip offset from the anchor in pixels.
pub fn tooltip_offset_px(
  config config: TooltipConfig(msg),
  pixels pixels: Int,
) -> TooltipConfig(msg) {
  TooltipConfig(..config, offset_px: pixels)
}

/// Set the viewport padding used for safe placement.
pub fn tooltip_viewport_padding_px(
  config config: TooltipConfig(msg),
  pixels pixels: Int,
) -> TooltipConfig(msg) {
  TooltipConfig(..config, viewport_padding_px: pixels)
}

/// Enable arrow solving with the given size and edge padding (pixels).
pub fn tooltip_arrow(
  config config: TooltipConfig(msg),
  size_px size_px: Int,
  edge_padding_px edge_padding_px: Int,
) -> TooltipConfig(msg) {
  TooltipConfig(..config, arrow: Some(#(size_px, edge_padding_px)))
}

/// Append additional attributes to the tooltip overlay root.
///
/// Attributes are appended, so later attributes can override earlier ones.
pub fn tooltip_attrs(
  config config: TooltipConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> TooltipConfig(msg) {
  case config {
    TooltipConfig(attrs: existing, ..) ->
      TooltipConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Render tooltip content into the `Tooltip` layer.
///
/// - When `solution` is `None`, the tooltip is rendered with
///   `overlay.overlay_unpositioned()` (measurable but hidden).
/// - When `solution` is `Some`, the tooltip is rendered with
///   `overlay.overlay_position_fixed(solution:)`.
pub fn tooltip_overlay(
  config config: TooltipConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
  solution solution: Option(weft.OverlaySolution),
  content content: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  case config {
    TooltipConfig(key: key, attrs: extra, ..) -> {
      let positioned = case solution {
        Some(solution) -> overlay.overlay_position_fixed(solution: solution)
        None -> overlay.overlay_unpositioned()
      }

      let overlay_attrs =
        [overlay.overlay_root(key: key), positioned, ..attrs]
        |> list.append(extra)

      weft_lustre.tooltip(child: weft_lustre.el(
        attrs: overlay_attrs,
        child: content,
      ))
    }
  }
}

/// Effect helper for positioning a tooltip after paint.
///
/// Call this when the tooltip becomes visible (and again on resize/scroll if
/// needed). It dispatches `on_positioned(solution)` on the JS target and is a
/// no-op on Erlang/SSR.
pub fn tooltip_effect(
  config config: TooltipConfig(msg),
  on_positioned on_positioned: fn(weft.OverlaySolution) -> msg,
) -> effect.Effect(msg) {
  case config {
    TooltipConfig(
      key: key,
      prefer_sides: prefer_sides,
      alignments: alignments,
      offset_px: offset_px,
      viewport_padding_px: viewport_padding_px,
      arrow: arrow,
      attrs: _attrs,
    ) ->
      overlay.position_overlay_on_paint(
        key: key,
        prefer_sides: prefer_sides,
        alignments: alignments,
        offset_px: offset_px,
        viewport_padding_px: viewport_padding_px,
        arrow: arrow,
        on_positioned: on_positioned,
      )
  }
}
