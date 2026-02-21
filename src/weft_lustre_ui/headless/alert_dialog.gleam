//// Headless (unstyled) alert dialog component for weft_lustre_ui.
////
//// An alert dialog is a modal dialog that requires explicit user action to
//// dismiss. Unlike a regular dialog, the scrim/backdrop click does NOT close
//// the alert dialog -- the user must click an action or cancel button.
////
//// This module reuses the dialog infrastructure from `weft_lustre_ui/headless/dialog`
//// but renders `role="alertdialog"` instead of `role="dialog"` and disables
//// scrim-click dismissal.

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

/// An alert dialog label strategy.
pub opaque type AlertDialogLabel {
  AlertDialogLabel(value: Label)
}

/// Label the alert dialog using `aria-label="..."`.
pub fn alert_dialog_label(value value: String) -> AlertDialogLabel {
  AlertDialogLabel(value: AriaLabel(value))
}

/// Label the alert dialog using `aria-labelledby="..."`.
pub fn alert_dialog_labelled_by(id id: String) -> AlertDialogLabel {
  AlertDialogLabel(value: LabelledBy(id))
}

fn label_attrs(label: AlertDialogLabel) -> List(attribute.Attribute(msg)) {
  case label {
    AlertDialogLabel(value: AriaLabel(value)) -> [attribute.aria_label(value)]
    AlertDialogLabel(value: LabelledBy(id)) -> [attribute.aria_labelledby(id)]
  }
}

/// Alert dialog configuration.
pub opaque type AlertDialogConfig(msg) {
  AlertDialogConfig(
    root_id: String,
    label: AlertDialogLabel,
    described_by: Option(String),
    on_close: msg,
    attrs: List(weft_lustre.Attribute(msg)),
    scrim_attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default alert dialog config.
///
/// Alert dialogs always have scrim-click dismissal disabled. The user must
/// explicitly interact with an action or cancel button.
pub fn alert_dialog_config(
  root_id root_id: String,
  label label: AlertDialogLabel,
  on_close on_close: msg,
) -> AlertDialogConfig(msg) {
  AlertDialogConfig(
    root_id: root_id,
    label: label,
    described_by: None,
    on_close: on_close,
    attrs: [],
    scrim_attrs: [],
  )
}

/// Set `aria-describedby` to reference an element inside the alert dialog.
pub fn alert_dialog_described_by(
  config config: AlertDialogConfig(msg),
  id id: String,
) -> AlertDialogConfig(msg) {
  AlertDialogConfig(..config, described_by: Some(id))
}

/// Append additional attributes to the alert dialog root.
pub fn alert_dialog_attrs(
  config config: AlertDialogConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> AlertDialogConfig(msg) {
  case config {
    AlertDialogConfig(attrs: existing, ..) ->
      AlertDialogConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Append additional attributes to the scrim element.
pub fn alert_dialog_scrim_attrs(
  config config: AlertDialogConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> AlertDialogConfig(msg) {
  case config {
    AlertDialogConfig(scrim_attrs: existing, ..) ->
      AlertDialogConfig(..config, scrim_attrs: list.append(existing, attrs))
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

/// Render an alert dialog in the `Modal` layer.
///
/// This function renders:
/// - a full-viewport scrim (NOT clickable -- alert dialogs require explicit dismissal)
/// - a dialog root node with `role="alertdialog"` and `aria-modal="true"`
///
/// Focus trapping and Escape handling are installed separately via
/// `weft_lustre/modal.modal_focus_trap`.
pub fn alert_dialog(
  config config: AlertDialogConfig(msg),
  content content: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  case config {
    AlertDialogConfig(
      root_id: root_id,
      label: label,
      described_by: described_by,
      on_close: _on_close,
      attrs: attrs,
      scrim_attrs: scrim_attrs,
    ) -> {
      // Alert dialogs do NOT close on scrim click -- scrim is non-interactive
      let scrim =
        weft_lustre.el(
          attrs: list.flatten([
            [weft_lustre.styles(scrim_styles())],
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
          [attribute.role("alertdialog")],
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

/// Render an alert dialog content wrapper.
pub fn alert_dialog_content(
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.column_layout()],
    attrs: [],
    children: children,
  )
}

/// Render an alert dialog header section.
pub fn alert_dialog_header(
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.column_layout()],
    attrs: [],
    children: children,
  )
}

/// Render an alert dialog footer section.
pub fn alert_dialog_footer(
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.row_layout()],
    attrs: [],
    children: children,
  )
}

/// Render an alert dialog title.
pub fn alert_dialog_title(
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "h2",
    base_weft_attrs: [weft.el_layout()],
    attrs: [],
    children: children,
  )
}

/// Render an alert dialog description.
pub fn alert_dialog_description(
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "p",
    base_weft_attrs: [weft.el_layout()],
    attrs: [],
    children: children,
  )
}

/// Render an alert dialog action button.
///
/// Action buttons confirm the destructive or primary action.
pub fn alert_dialog_action(
  on_click on_click: msg,
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "button",
    base_weft_attrs: [weft.el_layout()],
    attrs: [
      weft_lustre.html_attribute(attribute.type_("button")),
      weft_lustre.html_attribute(event.on_click(on_click)),
    ],
    children: children,
  )
}

/// Render an alert dialog cancel button.
///
/// Cancel buttons dismiss the alert dialog without performing the action.
pub fn alert_dialog_cancel(
  on_click on_click: msg,
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "button",
    base_weft_attrs: [weft.el_layout()],
    attrs: [
      weft_lustre.html_attribute(attribute.type_("button")),
      weft_lustre.html_attribute(event.on_click(on_click)),
    ],
    children: children,
  )
}
