//// Headless (unstyled) dialog (modal) composition for weft_lustre_ui.
////
//// This module composes the structural layer system and modal helpers into a
//// first-class dialog view:
//// - scrim + dialog content are rendered in the `Modal` structural layer
//// - background inert behavior is handled by `weft_lustre.layout` when a modal
////   layer node exists
//// - focus trapping is installed separately via `weft_lustre/modal.modal_focus_trap`
////
//// Visual styling is the responsibility of the caller (or the styled wrapper
//// in `weft_lustre_ui/dialog`).

import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute
import lustre/event
import weft
import weft_lustre
import weft_lustre/modal

type Label {
  AriaLabel(String)
  LabelledBy(String)
}

/// A dialog label strategy.
pub opaque type DialogLabel {
  DialogLabel(value: Label)
}

/// Label the dialog using `aria-label="..."`.
pub fn dialog_label(value value: String) -> DialogLabel {
  DialogLabel(value: AriaLabel(value))
}

/// Label the dialog using `aria-labelledby="..."`.
pub fn dialog_labelled_by(id id: String) -> DialogLabel {
  DialogLabel(value: LabelledBy(id))
}

fn label_attrs(label: DialogLabel) -> List(attribute.Attribute(msg)) {
  case label {
    DialogLabel(value: AriaLabel(value)) -> [attribute.aria_label(value)]
    DialogLabel(value: LabelledBy(id)) -> [attribute.aria_labelledby(id)]
  }
}

/// Dialog configuration.
pub opaque type DialogConfig(msg) {
  DialogConfig(
    root_id: String,
    label: DialogLabel,
    described_by: Option(String),
    on_close: msg,
    close_on_scrim_click: Bool,
    attrs: List(weft_lustre.Attribute(msg)),
    scrim_attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default dialog config.
pub fn dialog_config(
  root_id root_id: String,
  label label: DialogLabel,
  on_close on_close: msg,
) -> DialogConfig(msg) {
  DialogConfig(
    root_id: root_id,
    label: label,
    described_by: None,
    on_close: on_close,
    close_on_scrim_click: True,
    attrs: [],
    scrim_attrs: [],
  )
}

/// Set `aria-describedby` to reference an element inside the dialog.
pub fn dialog_described_by(
  config config: DialogConfig(msg),
  id id: String,
) -> DialogConfig(msg) {
  DialogConfig(..config, described_by: Some(id))
}

/// Disable closing the dialog when clicking the scrim.
pub fn dialog_no_scrim_close(
  config config: DialogConfig(msg),
) -> DialogConfig(msg) {
  DialogConfig(..config, close_on_scrim_click: False)
}

/// Append additional attributes to the dialog root.
///
/// Attributes are appended, so later attributes can override earlier ones.
pub fn dialog_attrs(
  config config: DialogConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> DialogConfig(msg) {
  case config {
    DialogConfig(attrs: existing, ..) ->
      DialogConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Append additional attributes to the scrim element.
///
/// Attributes are appended, so later attributes can override earlier ones.
pub fn dialog_scrim_attrs(
  config config: DialogConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> DialogConfig(msg) {
  case config {
    DialogConfig(scrim_attrs: existing, ..) ->
      DialogConfig(..config, scrim_attrs: list.append(existing, attrs))
  }
}

fn container_styles() -> List(weft.Attribute) {
  [
    weft.position(value: weft.position_fixed()),
    weft.inset(length: weft.px(pixels: 0)),
    weft.display(value: weft.display_flex()),
    weft.align_items(value: weft.align_items_center()),
    weft.justify_content(value: weft.justify_center()),
  ]
}

fn scrim_styles() -> List(weft.Attribute) {
  [
    weft.position(value: weft.position_fixed()),
    weft.inset(length: weft.px(pixels: 0)),
  ]
}

fn dialog_structure_styles() -> List(weft.Attribute) {
  [
    // Keep dialogs usable by default even without styling:
    // - constrain within the viewport
    // - scroll vertically if content is large
    weft.width(length: weft.maximum(
      base: weft.fixed(length: weft.vw(vw: 90.0)),
      max: weft.rem(rem: 36.0),
    )),
    weft.height(length: weft.maximum(
      base: weft.shrink(),
      max: weft.vh(vh: 90.0),
    )),
    weft.scroll_y(),
  ]
}

/// Render a dialog in the `Modal` layer.
///
/// This function renders:
/// - a full-viewport scrim (clickable by default)
/// - a dialog root node with `role="dialog"` and `aria-modal="true"`
///
/// Focus trapping and Escape handling are installed separately via
/// `weft_lustre/modal.modal_focus_trap`.
pub fn dialog(
  config config: DialogConfig(msg),
  content content: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  case config {
    DialogConfig(
      root_id: root_id,
      label: label,
      described_by: described_by,
      on_close: on_close,
      close_on_scrim_click: close_on_scrim_click,
      attrs: attrs,
      scrim_attrs: scrim_attrs,
    ) -> {
      let scrim_click = case close_on_scrim_click {
        True -> [weft_lustre.html_attribute(event.on_click(on_close))]
        False -> []
      }

      let scrim =
        weft_lustre.el(
          attrs: list.flatten([
            [weft_lustre.styles(scrim_styles())],
            scrim_click,
            scrim_attrs,
          ]),
          child: weft_lustre.none(),
        )

      let described = case described_by {
        None -> []
        Some(id) -> [attribute.aria_describedby(id)]
      }

      let dialog_html_attrs =
        list.flatten([
          [attribute.role("dialog")],
          [attribute.aria_modal(True)],
          label_attrs(label),
          described,
        ])

      let dialog_node =
        weft_lustre.element_tag(
          tag: "div",
          base_weft_attrs: [weft.el_layout()],
          attrs: list.flatten([
            [
              weft_lustre.styles(dialog_structure_styles()),
              modal.modal_root_id(value: root_id),
            ],
            list.map(dialog_html_attrs, weft_lustre.html_attribute),
            attrs,
          ]),
          children: [content],
        )

      let container =
        weft_lustre.element_tag(
          tag: "div",
          base_weft_attrs: [weft.el_layout()],
          attrs: [weft_lustre.styles(container_styles())],
          children: [scrim, dialog_node],
        )

      weft_lustre.modal(child: container)
    }
  }
}
