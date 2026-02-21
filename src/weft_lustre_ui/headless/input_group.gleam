//// Headless (unstyled) input group component for weft_lustre_ui.
////
//// Provides a container with `role="group"` for grouping an input with
//// prefix/suffix addons, text labels, and inline buttons. Visual appearance
//// is not applied here; the styled wrapper handles border, radius, and color
//// treatment.

import gleam/list
import lustre/attribute
import weft
import weft_lustre

type Align {
  Start
  End
}

/// Alignment for input group addons.
pub opaque type AddonAlign {
  AddonAlign(value: Align)
}

/// Addon appears before the input (left in LTR).
pub fn addon_inline_start() -> AddonAlign {
  AddonAlign(value: Start)
}

/// Addon appears after the input (right in LTR).
pub fn addon_inline_end() -> AddonAlign {
  AddonAlign(value: End)
}

/// Configuration for the input group.
pub opaque type InputGroupConfig(msg) {
  InputGroupConfig(disabled: Bool, attrs: List(weft_lustre.Attribute(msg)))
}

/// Construct an input group configuration.
pub fn input_group_config() -> InputGroupConfig(msg) {
  InputGroupConfig(disabled: False, attrs: [])
}

/// Mark the input group as disabled.
pub fn input_group_disabled(
  config config: InputGroupConfig(msg),
) -> InputGroupConfig(msg) {
  InputGroupConfig(..config, disabled: True)
}

/// Append root attributes.
pub fn input_group_attrs(
  config config: InputGroupConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> InputGroupConfig(msg) {
  case config {
    InputGroupConfig(attrs: existing, ..) ->
      InputGroupConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Internal: read the disabled state from an input group config.
@internal
pub fn input_group_config_disabled(config config: InputGroupConfig(msg)) -> Bool {
  case config {
    InputGroupConfig(disabled:, ..) -> disabled
  }
}

/// Internal: read the attributes from an input group config.
@internal
pub fn input_group_config_attrs(
  config config: InputGroupConfig(msg),
) -> List(weft_lustre.Attribute(msg)) {
  case config {
    InputGroupConfig(attrs:, ..) -> attrs
  }
}

/// Check if an addon align value is inline-start.
pub fn addon_align_is_start(align align: AddonAlign) -> Bool {
  case align {
    AddonAlign(value: Start) -> True
    AddonAlign(value: End) -> False
  }
}

/// Check if an addon align value is inline-end.
pub fn addon_align_is_end(align align: AddonAlign) -> Bool {
  case align {
    AddonAlign(value: Start) -> False
    AddonAlign(value: End) -> True
  }
}

/// Render the input group container.
///
/// Produces a `div` with `role="group"` and row layout. When disabled,
/// child controls inherit the disabled context.
pub fn input_group(
  config config: InputGroupConfig(msg),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  case config {
    InputGroupConfig(disabled: disabled, attrs: attrs) -> {
      let group_attrs =
        list.flatten([
          [weft_lustre.html_attribute(attribute.role("group"))],
          case disabled {
            True -> [
              weft_lustre.html_attribute(attribute.attribute(
                "data-disabled",
                "",
              )),
            ]
            False -> []
          },
          attrs,
        ])

      weft_lustre.element_tag(
        tag: "div",
        base_weft_attrs: [weft.row_layout()],
        attrs: group_attrs,
        children: children,
      )
    }
  }
}

/// Render an addon container (prefix or suffix).
///
/// Uses CSS `order` to position the addon: `order(-1)` for inline-start
/// (before the input) and `order(999)` for inline-end (after the input).
pub fn input_group_addon(
  align align: AddonAlign,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let order_value = case align {
    AddonAlign(value: Start) -> -1
    AddonAlign(value: End) -> 999
  }

  let addon_attrs =
    list.flatten([
      [
        weft_lustre.styles([
          weft.display(value: weft.display_flex()),
          weft.align_items(value: weft.align_items_center()),
          weft.order(value: order_value),
        ]),
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "input-group-addon",
        )),
      ],
      attrs,
    ])

  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.el_layout()],
    attrs: addon_attrs,
    children: children,
  )
}

/// Render the input element within the group.
///
/// The input fills remaining horizontal space via `width: fill()`.
pub fn input_group_input(
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> weft_lustre.Element(msg) {
  let input_attrs =
    list.flatten([
      [
        weft_lustre.styles([weft.width(length: weft.fill())]),
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "input-group-control",
        )),
      ],
      attrs,
    ])

  weft_lustre.element_tag(
    tag: "input",
    base_weft_attrs: [weft.el_layout()],
    attrs: input_attrs,
    children: [],
  )
}

/// Render a text element within an addon.
///
/// Produces a `span` suitable for static labels or icon wrappers.
pub fn input_group_text(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let text_attrs =
    list.flatten([
      [
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "input-group-text",
        )),
      ],
      attrs,
    ])

  weft_lustre.element_tag(
    tag: "span",
    base_weft_attrs: [weft.el_layout()],
    attrs: text_attrs,
    children: children,
  )
}
