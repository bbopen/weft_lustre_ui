//// Headless sheet wrapper built on top of headless dialog.

import weft_lustre
import weft_lustre_ui/headless/dialog

type Side {
  Left
  Right
}

/// Sheet side.
pub opaque type SheetSide {
  SheetSide(value: Side)
}

/// Left sheet side.
pub fn sheet_left() -> SheetSide {
  SheetSide(value: Left)
}

/// Right sheet side.
pub fn sheet_right() -> SheetSide {
  SheetSide(value: Right)
}

/// Is the side left?
pub fn sheet_side_is_left(side side: SheetSide) -> Bool {
  case side {
    SheetSide(value: Left) -> True
    SheetSide(value: Right) -> False
  }
}

/// Is the side right?
pub fn sheet_side_is_right(side side: SheetSide) -> Bool {
  case side {
    SheetSide(value: Left) -> False
    SheetSide(value: Right) -> True
  }
}

/// Headless sheet configuration.
pub opaque type SheetConfig(msg) {
  SheetConfig(open: Bool, side: SheetSide, dialog: dialog.DialogConfig(msg))
}

/// Construct sheet configuration.
pub fn sheet_config(
  open open: Bool,
  root_id root_id: String,
  label label: dialog.DialogLabel,
  on_close on_close: msg,
) -> SheetConfig(msg) {
  SheetConfig(
    open: open,
    side: sheet_right(),
    dialog: dialog.dialog_config(
      root_id: root_id,
      label: label,
      on_close: on_close,
    ),
  )
}

/// Set sheet side.
pub fn sheet_side(
  config config: SheetConfig(msg),
  side side: SheetSide,
) -> SheetConfig(msg) {
  SheetConfig(..config, side: side)
}

/// Append dialog attributes.
pub fn sheet_attrs(
  config config: SheetConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> SheetConfig(msg) {
  case config {
    SheetConfig(dialog: d, ..) ->
      SheetConfig(
        ..config,
        dialog: dialog.dialog_attrs(config: d, attrs: attrs),
      )
  }
}

/// Read configured side.
pub fn sheet_config_side(config config: SheetConfig(msg)) -> SheetSide {
  case config {
    SheetConfig(side:, ..) -> side
  }
}

/// Render headless sheet.
pub fn sheet(
  config config: SheetConfig(msg),
  content content: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  case config {
    SheetConfig(open: open, dialog: d, ..) ->
      case open {
        True -> dialog.dialog(config: d, content: content)
        False -> weft_lustre.none()
      }
  }
}
