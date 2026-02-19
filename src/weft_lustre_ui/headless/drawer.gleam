//// Headless drawer wrapper for weft_lustre_ui.

import weft_lustre
import weft_lustre_ui/headless/dialog

/// Drawer configuration.
pub opaque type DrawerConfig(msg) {
  DrawerConfig(open: Bool, dialog: dialog.DialogConfig(msg))
}

/// Construct drawer configuration.
pub fn drawer_config(
  open open: Bool,
  root_id root_id: String,
  label label: dialog.DialogLabel,
  on_close on_close: msg,
) -> DrawerConfig(msg) {
  DrawerConfig(
    open: open,
    dialog: dialog.dialog_config(
      root_id: root_id,
      label: label,
      on_close: on_close,
    ),
  )
}

/// Append drawer attributes.
pub fn drawer_attrs(
  config config: DrawerConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> DrawerConfig(msg) {
  case config {
    DrawerConfig(dialog: d, ..) ->
      DrawerConfig(
        ..config,
        dialog: dialog.dialog_attrs(config: d, attrs: attrs),
      )
  }
}

/// Render headless drawer.
pub fn drawer(
  config config: DrawerConfig(msg),
  content content: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  case config {
    DrawerConfig(open: open, dialog: d) ->
      case open {
        True -> dialog.dialog(config: d, content: content)
        False -> weft_lustre.none()
      }
  }
}
