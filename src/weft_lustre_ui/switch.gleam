//// Styled switch component for weft_lustre_ui.

import weft
import weft_lustre
import weft_lustre_ui/headless/switch as headless_switch
import weft_lustre_ui/theme

/// Styled switch configuration alias.
pub type SwitchConfig(msg) =
  headless_switch.SwitchConfig(msg)

/// Construct switch configuration.
pub fn switch_config(
  checked checked: Bool,
  on_toggle on_toggle: fn(Bool) -> msg,
) -> SwitchConfig(msg) {
  headless_switch.switch_config(checked: checked, on_toggle: on_toggle)
}

/// Disable switch.
pub fn switch_disabled(config config: SwitchConfig(msg)) -> SwitchConfig(msg) {
  headless_switch.switch_disabled(config: config)
}

/// Append switch attributes.
pub fn switch_attrs(
  config config: SwitchConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> SwitchConfig(msg) {
  headless_switch.switch_attrs(config: config, attrs: attrs)
}

fn styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  [
    weft.spacing(pixels: 8),
    weft.align_items(value: weft.align_items_center()),
    weft.font_family(families: theme.font_families(theme)),
    weft.font_size(size: weft.rem(rem: 0.875)),
  ]
}

/// Render styled switch.
pub fn switch(
  theme theme: theme.Theme,
  config config: SwitchConfig(msg),
  label label: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  headless_switch.switch(
    config: headless_switch.switch_attrs(config: config, attrs: [
      weft_lustre.styles(styles(theme: theme)),
    ]),
    label: label,
  )
}
