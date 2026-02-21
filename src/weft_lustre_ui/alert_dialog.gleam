//// Styled, theme-driven alert dialog component for weft_lustre_ui.
////
//// An alert dialog is a modal dialog that requires explicit user action to
//// dismiss. It uses `role="alertdialog"` and disables scrim-click dismissal.
////
//// This module reuses the dialog visual styling and composes with the headless
//// alert dialog infrastructure.

import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute
import lustre/event
import weft
import weft_lustre
import weft_lustre/modal
import weft_lustre_ui/theme

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
/// Alert dialogs always have scrim-click dismissal disabled.
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

fn container_styles(space_md: Int) -> List(weft.Attribute) {
  [
    weft.position(value: weft.position_fixed()),
    weft.inset(length: weft.px(pixels: 0)),
    weft.display(value: weft.display_flex()),
    weft.align_items(value: weft.align_items_center()),
    weft.justify_content(value: weft.justify_center()),
    weft.padding(pixels: space_md),
  ]
}

fn scrim_styles(t: theme.Theme) -> List(weft.Attribute) {
  [
    weft.position(value: weft.position_fixed()),
    weft.inset(length: weft.px(pixels: 0)),
    weft.background(color: theme.scrim_color(t)),
  ]
}

fn dialog_styles(t: theme.Theme) -> List(weft.Attribute) {
  let #(surface_bg, surface_fg) = theme.surface(t)

  let shadow =
    weft.shadow(
      x: weft.px(pixels: 0),
      y: weft.px(pixels: 20),
      blur: weft.px(pixels: 60),
      spread: weft.px(pixels: -20),
      color: theme.dialog_shadow(t),
    )

  [
    weft.background(color: surface_bg),
    weft.text_color(color: surface_fg),
    weft.rounded(radius: theme.radius_md(t)),
    weft.border(
      width: weft.px(pixels: 1),
      style: weft.border_style_solid(),
      color: theme.border_color(t),
    ),
    weft.padding(pixels: theme.space_md(t) + 12),
    weft.width(length: weft.maximum(
      base: weft.fixed(length: weft.vw(vw: 90.0)),
      max: weft.rem(rem: 32.0),
    )),
    weft.height(length: weft.maximum(
      base: weft.shrink(),
      max: weft.vh(vh: 90.0),
    )),
    weft.scroll_y(),
    weft.shadows(shadows: [shadow]),
  ]
}

/// Render a styled alert dialog in the `Modal` layer.
///
/// This function renders:
/// - a themed full-viewport scrim (NOT clickable)
/// - a dialog root node with `role="alertdialog"` and `aria-modal="true"`
pub fn alert_dialog(
  theme theme: theme.Theme,
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
      // Alert dialogs do NOT close on scrim click
      let scrim =
        weft_lustre.el(
          attrs: list.flatten([
            [weft_lustre.styles(scrim_styles(theme))],
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
          base_weft_attrs: [weft.column_layout()],
          attrs: list.flatten([
            [
              weft_lustre.styles(dialog_styles(theme)),
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
          attrs: [
            weft_lustre.styles(container_styles(theme.space_md(theme))),
          ],
          children: [scrim, dialog_node],
        )

      weft_lustre.modal(child: container)
    }
  }
}

/// Render a styled alert dialog content wrapper.
pub fn alert_dialog_content(
  theme theme: theme.Theme,
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let space = theme.space_md(theme)

  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.column_layout()],
    attrs: [weft_lustre.styles([weft.spacing(pixels: space)])],
    children: children,
  )
}

/// Render a styled alert dialog header section.
pub fn alert_dialog_header(
  theme theme: theme.Theme,
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.column_layout()],
    attrs: [
      weft_lustre.styles([weft.spacing(pixels: theme.space_md(theme) / 2)]),
    ],
    children: children,
  )
}

/// Render a styled alert dialog footer section.
///
/// Footer renders as a flex row with gap for action/cancel buttons.
pub fn alert_dialog_footer(
  theme theme: theme.Theme,
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.row_layout()],
    attrs: [
      weft_lustre.styles([
        weft.spacing(pixels: theme.space_md(theme)),
        weft.justify_content(value: weft.justify_end()),
      ]),
    ],
    children: children,
  )
}

/// Render a styled alert dialog title.
pub fn alert_dialog_title(
  theme theme: theme.Theme,
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let #(_surface_bg, surface_fg) = theme.surface(theme)

  weft_lustre.element_tag(
    tag: "h2",
    base_weft_attrs: [weft.el_layout()],
    attrs: [
      weft_lustre.styles([
        weft.text_color(color: surface_fg),
        weft.font_size(size: weft.rem(rem: 1.125)),
        weft.font_weight(weight: weft.font_weight_value(weight: 600)),
        weft.line_height(height: weft.line_height_multiple(multiplier: 1.2)),
      ]),
    ],
    children: children,
  )
}

/// Render a styled alert dialog description.
pub fn alert_dialog_description(
  theme theme: theme.Theme,
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "p",
    base_weft_attrs: [weft.el_layout()],
    attrs: [
      weft_lustre.styles([
        weft.text_color(color: theme.muted_text(theme)),
        weft.font_size(size: weft.rem(rem: 0.875)),
        weft.line_height(height: weft.line_height_multiple(multiplier: 1.5)),
      ]),
    ],
    children: children,
  )
}

/// Render a styled alert dialog action button.
///
/// Uses primary theme colors for the action button.
pub fn alert_dialog_action(
  theme theme: theme.Theme,
  on_click on_click: msg,
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let #(primary_bg, primary_fg) = theme.primary(theme)
  let radius = theme.radius_md(theme)
  let space = theme.space_md(theme)

  let styles = [
    weft.background(color: primary_bg),
    weft.text_color(color: primary_fg),
    weft.rounded(radius: radius),
    weft.padding_xy(x: space + 4, y: space / 2 + 2),
    weft.font_size(size: weft.rem(rem: 0.875)),
    weft.font_weight(weight: weft.font_weight_value(weight: 500)),
    weft.cursor(cursor: weft.cursor_pointer()),
    weft.border(
      width: weft.px(pixels: 0),
      style: weft.border_style_none(),
      color: primary_bg,
    ),
    weft.display(value: weft.display_inline_flex()),
    weft.align_items(value: weft.align_items_center()),
    weft.justify_content(value: weft.justify_center()),
  ]

  weft_lustre.element_tag(
    tag: "button",
    base_weft_attrs: [weft.el_layout()],
    attrs: [
      weft_lustre.styles(styles),
      weft_lustre.html_attribute(attribute.type_("button")),
      weft_lustre.html_attribute(event.on_click(on_click)),
    ],
    children: children,
  )
}

/// Render a styled alert dialog cancel button.
///
/// Uses outline style for the cancel button.
pub fn alert_dialog_cancel(
  theme theme: theme.Theme,
  on_click on_click: msg,
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let #(surface_bg, surface_fg) = theme.surface(theme)
  let border = theme.border_color(theme)
  let radius = theme.radius_md(theme)
  let space = theme.space_md(theme)

  let styles = [
    weft.background(color: surface_bg),
    weft.text_color(color: surface_fg),
    weft.rounded(radius: radius),
    weft.padding_xy(x: space + 4, y: space / 2 + 2),
    weft.font_size(size: weft.rem(rem: 0.875)),
    weft.font_weight(weight: weft.font_weight_value(weight: 500)),
    weft.cursor(cursor: weft.cursor_pointer()),
    weft.border(
      width: weft.px(pixels: 1),
      style: weft.border_style_solid(),
      color: border,
    ),
    weft.display(value: weft.display_inline_flex()),
    weft.align_items(value: weft.align_items_center()),
    weft.justify_content(value: weft.justify_center()),
  ]

  weft_lustre.element_tag(
    tag: "button",
    base_weft_attrs: [weft.el_layout()],
    attrs: [
      weft_lustre.styles(styles),
      weft_lustre.html_attribute(attribute.type_("button")),
      weft_lustre.html_attribute(event.on_click(on_click)),
    ],
    children: children,
  )
}
