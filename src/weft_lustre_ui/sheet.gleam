//// Styled sheet component for weft_lustre_ui.

import gleam/list
import weft
import weft_lustre
import weft_lustre_ui/headless/dialog as headless_dialog
import weft_lustre_ui/headless/sheet as headless_sheet
import weft_lustre_ui/theme

/// Styled sheet side alias.
pub type SheetSide =
  headless_sheet.SheetSide

/// Styled sheet configuration alias.
pub type SheetConfig(msg) =
  headless_sheet.SheetConfig(msg)

/// Left sheet side.
pub fn sheet_left() -> SheetSide {
  headless_sheet.sheet_left()
}

/// Right sheet side.
pub fn sheet_right() -> SheetSide {
  headless_sheet.sheet_right()
}

/// Construct sheet configuration.
pub fn sheet_config(
  open open: Bool,
  root_id root_id: String,
  label label: headless_dialog.DialogLabel,
  on_close on_close: msg,
) -> SheetConfig(msg) {
  headless_sheet.sheet_config(
    open: open,
    root_id: root_id,
    label: label,
    on_close: on_close,
  )
}

/// Label the sheet using `aria-label`.
pub fn sheet_label(value value: String) -> headless_dialog.DialogLabel {
  headless_dialog.dialog_label(value: value)
}

/// Label the sheet using `aria-labelledby`.
pub fn sheet_labelled_by(id id: String) -> headless_dialog.DialogLabel {
  headless_dialog.dialog_labelled_by(id: id)
}

/// Set sheet side.
pub fn sheet_side(
  config config: SheetConfig(msg),
  side side: SheetSide,
) -> SheetConfig(msg) {
  headless_sheet.sheet_side(config: config, side: side)
}

/// Append sheet attributes.
pub fn sheet_attrs(
  config config: SheetConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> SheetConfig(msg) {
  headless_sheet.sheet_attrs(config: config, attrs: attrs)
}

fn styles(
  theme theme: theme.Theme,
  side side: SheetSide,
) -> List(weft.Attribute) {
  let #(surface_bg, _surface_fg) = theme.surface(theme)

  let alignment_styles = case headless_sheet.sheet_side_is_left(side: side) {
    True -> [weft.justify_content(value: weft.justify_start())]
    False -> [weft.justify_content(value: weft.justify_end())]
  }

  list.flatten([
    [
      weft.width(length: weft.fixed(length: weft.px(pixels: 360))),
      weft.height(length: weft.fill()),
      weft.padding(pixels: 16),
      weft.spacing(pixels: 10),
      weft.background(color: surface_bg),
      weft.border(
        width: weft.px(pixels: 1),
        style: weft.border_style_solid(),
        color: theme.border_color(theme),
      ),
      weft.rounded(radius: theme.radius_md(theme)),
    ],
    alignment_styles,
  ])
}

/// Render a styled sheet.
pub fn sheet(
  theme theme: theme.Theme,
  config config: SheetConfig(msg),
  content content: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  let side = headless_sheet.sheet_config_side(config: config)
  let styled =
    headless_sheet.sheet_attrs(config: config, attrs: [
      weft_lustre.styles(styles(theme: theme, side: side)),
    ])

  headless_sheet.sheet(config: styled, content: content)
}
