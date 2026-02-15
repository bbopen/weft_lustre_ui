//// UI kit for weft_lustre — headless + styled components.

import weft_lustre_ui/theme

/// A UI kit theme.
pub type Theme =
  theme.Theme

/// Font metrics used to improve baseline alignment and clipping behavior for
/// UI components.
pub type FontAdjustment =
  theme.FontAdjustment

/// Construct a default theme.
pub fn theme_default() -> Theme {
  theme.theme_default()
}
