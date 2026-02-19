//// Styled sonner-compatible wrappers backed by styled toast primitives.

import weft_lustre
import weft_lustre_ui/theme
import weft_lustre_ui/toast

/// Styled sonner corner alias.
pub type SonnerCorner =
  toast.ToastCorner

/// Styled sonner configuration alias.
pub type SonnerConfig(msg) =
  toast.ToastConfig(msg)

/// Top-left sonner corner.
pub fn sonner_corner_top_left() -> SonnerCorner {
  toast.toast_corner_top_left()
}

/// Top-right sonner corner.
pub fn sonner_corner_top_right() -> SonnerCorner {
  toast.toast_corner_top_right()
}

/// Bottom-left sonner corner.
pub fn sonner_corner_bottom_left() -> SonnerCorner {
  toast.toast_corner_bottom_left()
}

/// Bottom-right sonner corner.
pub fn sonner_corner_bottom_right() -> SonnerCorner {
  toast.toast_corner_bottom_right()
}

/// Construct sonner config.
pub fn sonner_config(on_dismiss on_dismiss: msg) -> SonnerConfig(msg) {
  toast.toast_config(on_dismiss: on_dismiss)
}

/// Append sonner attributes.
pub fn sonner_attrs(
  config config: SonnerConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> SonnerConfig(msg) {
  toast.toast_attrs(config: config, attrs: attrs)
}

/// Render styled sonner toast item.
pub fn sonner(
  theme theme: theme.Theme,
  config config: SonnerConfig(msg),
  content content: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  toast.toast(theme: theme, config: config, content: content)
}

/// Render styled sonner region.
pub fn sonner_region(
  theme theme: theme.Theme,
  corner corner: SonnerCorner,
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  toast.toast_region(theme: theme, corner: corner, children: children)
}
