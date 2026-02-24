//// Headless resizable panel primitives for shadcn compatibility.
////
//// This module provides structural `panel-group`, `panel`, and `handle`
//// elements. Drag-resize behavior is intentionally not implemented here.

import gleam/list
import lustre/attribute
import weft
import weft_lustre

type Orientation {
  Horizontal
  Vertical
}

/// Panel group orientation token.
pub opaque type ResizableOrientation {
  ResizableOrientation(value: Orientation)
}

/// Horizontal panel split orientation.
pub fn resizable_horizontal() -> ResizableOrientation {
  ResizableOrientation(value: Horizontal)
}

/// Vertical panel split orientation.
pub fn resizable_vertical() -> ResizableOrientation {
  ResizableOrientation(value: Vertical)
}

/// Resizable panel group configuration.
pub opaque type ResizablePanelGroupConfig(msg) {
  ResizablePanelGroupConfig(
    orientation: ResizableOrientation,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default panel group configuration.
pub fn resizable_panel_group_config() -> ResizablePanelGroupConfig(msg) {
  ResizablePanelGroupConfig(orientation: resizable_horizontal(), attrs: [])
}

/// Set panel group orientation.
pub fn resizable_panel_group_orientation(
  config config: ResizablePanelGroupConfig(msg),
  orientation orientation: ResizableOrientation,
) -> ResizablePanelGroupConfig(msg) {
  ResizablePanelGroupConfig(..config, orientation: orientation)
}

/// Append panel group attributes.
pub fn resizable_panel_group_attrs(
  config config: ResizablePanelGroupConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ResizablePanelGroupConfig(msg) {
  case config {
    ResizablePanelGroupConfig(attrs: existing, ..) ->
      ResizablePanelGroupConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Resizable handle configuration.
pub opaque type ResizableHandleConfig(msg) {
  ResizableHandleConfig(
    orientation: ResizableOrientation,
    with_handle: Bool,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default handle configuration.
pub fn resizable_handle_config() -> ResizableHandleConfig(msg) {
  ResizableHandleConfig(
    orientation: resizable_vertical(),
    with_handle: False,
    attrs: [],
  )
}

/// Set handle orientation.
pub fn resizable_handle_orientation(
  config config: ResizableHandleConfig(msg),
  orientation orientation: ResizableOrientation,
) -> ResizableHandleConfig(msg) {
  ResizableHandleConfig(..config, orientation: orientation)
}

/// Enable visual grip affordance on the handle.
pub fn resizable_handle_with_handle(
  config config: ResizableHandleConfig(msg),
) -> ResizableHandleConfig(msg) {
  ResizableHandleConfig(..config, with_handle: True)
}

/// Append handle attributes.
pub fn resizable_handle_attrs(
  config config: ResizableHandleConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ResizableHandleConfig(msg) {
  case config {
    ResizableHandleConfig(attrs: existing, ..) ->
      ResizableHandleConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Internal: read configured orientation.
@internal
pub fn resizable_panel_group_config_orientation(
  config config: ResizablePanelGroupConfig(msg),
) -> ResizableOrientation {
  case config {
    ResizablePanelGroupConfig(orientation:, ..) -> orientation
  }
}

/// Internal: check orientation equals horizontal.
@internal
pub fn resizable_orientation_is_horizontal(
  orientation orientation: ResizableOrientation,
) -> Bool {
  case orientation {
    ResizableOrientation(value: Horizontal) -> True
    ResizableOrientation(value: Vertical) -> False
  }
}

/// Internal: check orientation equals vertical.
@internal
pub fn resizable_orientation_is_vertical(
  orientation orientation: ResizableOrientation,
) -> Bool {
  case orientation {
    ResizableOrientation(value: Horizontal) -> False
    ResizableOrientation(value: Vertical) -> True
  }
}

/// Internal: read configured handle orientation.
@internal
pub fn resizable_handle_config_orientation(
  config config: ResizableHandleConfig(msg),
) -> ResizableOrientation {
  case config {
    ResizableHandleConfig(orientation:, ..) -> orientation
  }
}

/// Internal: read whether handle grip is enabled.
@internal
pub fn resizable_handle_config_with_handle(
  config config: ResizableHandleConfig(msg),
) -> Bool {
  case config {
    ResizableHandleConfig(with_handle:, ..) -> with_handle
  }
}

/// Set handle orientation based on a panel-group configuration.
pub fn resizable_handle_orientation_from_group(
  config config: ResizableHandleConfig(msg),
  group_config group_config: ResizablePanelGroupConfig(msg),
) -> ResizableHandleConfig(msg) {
  let group_orientation =
    resizable_panel_group_config_orientation(config: group_config)
  let orientation = case group_orientation {
    ResizableOrientation(value: Horizontal) -> resizable_vertical()
    ResizableOrientation(value: Vertical) -> resizable_horizontal()
  }

  resizable_handle_orientation(config: config, orientation: orientation)
}

/// Render a panel group container.
pub fn resizable_panel_group(
  config config: ResizablePanelGroupConfig(msg),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  case config {
    ResizablePanelGroupConfig(orientation: orientation, attrs: attrs) -> {
      let orientation_value = case orientation {
        ResizableOrientation(value: Horizontal) -> "horizontal"
        ResizableOrientation(value: Vertical) -> "vertical"
      }

      weft_lustre.element_tag(
        tag: "div",
        base_weft_attrs: [weft.el_layout()],
        attrs: list.append(
          [
            weft_lustre.html_attribute(attribute.attribute(
              "data-slot",
              "resizable-panel-group",
            )),
            weft_lustre.html_attribute(attribute.attribute(
              "aria-orientation",
              orientation_value,
            )),
          ],
          attrs,
        ),
        children: children,
      )
    }
  }
}

/// Render a panel container.
pub fn resizable_panel(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.el_layout()],
    attrs: list.append(
      [
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "resizable-panel",
        )),
      ],
      attrs,
    ),
    children: children,
  )
}

/// Render a resize handle.
pub fn resizable_handle(
  config config: ResizableHandleConfig(msg),
) -> weft_lustre.Element(msg) {
  case config {
    ResizableHandleConfig(
      orientation: orientation,
      with_handle: with_handle,
      attrs: attrs,
    ) -> {
      let orientation_value = case orientation {
        ResizableOrientation(value: Horizontal) -> "horizontal"
        ResizableOrientation(value: Vertical) -> "vertical"
      }

      let grip = case with_handle {
        True -> [
          weft_lustre.element_tag(
            tag: "span",
            base_weft_attrs: [weft.el_layout()],
            attrs: [
              weft_lustre.html_attribute(attribute.attribute(
                "data-slot",
                "resizable-grip",
              )),
            ],
            children: [],
          ),
        ]
        False -> []
      }

      weft_lustre.element_tag(
        tag: "div",
        base_weft_attrs: [weft.el_layout()],
        attrs: list.append(
          [
            weft_lustre.html_attribute(attribute.attribute(
              "data-slot",
              "resizable-handle",
            )),
            weft_lustre.html_attribute(attribute.attribute(
              "aria-orientation",
              orientation_value,
            )),
          ],
          attrs,
        ),
        children: grip,
      )
    }
  }
}
