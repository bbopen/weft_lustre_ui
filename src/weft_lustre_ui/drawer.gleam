//// Styled drawer component for weft_lustre_ui.

import weft
import weft_lustre
import weft_lustre_ui/headless/dialog as headless_dialog
import weft_lustre_ui/headless/drawer as headless_drawer
import weft_lustre_ui/theme

/// Styled drawer configuration alias.
pub type DrawerConfig(msg) =
  headless_drawer.DrawerConfig(msg)

/// Construct drawer configuration.
pub fn drawer_config(
  open open: Bool,
  root_id root_id: String,
  label label: headless_dialog.DialogLabel,
  on_close on_close: msg,
) -> DrawerConfig(msg) {
  headless_drawer.drawer_config(
    open: open,
    root_id: root_id,
    label: label,
    on_close: on_close,
  )
}

/// Label the drawer using `aria-label`.
pub fn drawer_label(value value: String) -> headless_dialog.DialogLabel {
  headless_dialog.dialog_label(value: value)
}

/// Label the drawer using `aria-labelledby`.
pub fn drawer_labelled_by(id id: String) -> headless_dialog.DialogLabel {
  headless_dialog.dialog_labelled_by(id: id)
}

/// Append drawer attributes.
pub fn drawer_attrs(
  config config: DrawerConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> DrawerConfig(msg) {
  headless_drawer.drawer_attrs(config: config, attrs: attrs)
}

fn styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  let #(surface_bg, _surface_fg) = theme.surface(theme)

  [
    weft.width(length: weft.fixed(length: weft.pct(pct: 100.0))),
    weft.height(length: weft.fixed(length: weft.px(pixels: 360))),
    weft.padding(pixels: 16),
    weft.spacing(pixels: 10),
    weft.background(color: surface_bg),
    weft.border(
      width: weft.px(pixels: 1),
      style: weft.border_style_solid(),
      color: theme.border_color(theme),
    ),
    weft.rounded(radius: theme.radius_md(theme)),
  ]
}

/// Render styled drawer.
pub fn drawer(
  theme theme: theme.Theme,
  config config: DrawerConfig(msg),
  content content: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  headless_drawer.drawer(
    config: headless_drawer.drawer_attrs(config: config, attrs: [
      weft_lustre.styles(styles(theme: theme)),
    ]),
    content: content,
  )
}
