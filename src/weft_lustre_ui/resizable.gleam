//// Styled resizable panel primitives for shadcn compatibility.
////
//// Adds theme-driven visuals to structural panel groups and handles.
//// Runtime drag behavior remains application-controlled.

import gleam/list
import weft
import weft_lustre
import weft_lustre_ui/headless/resizable as headless_resizable
import weft_lustre_ui/theme

/// Panel group orientation token alias.
pub type ResizableOrientation =
  headless_resizable.ResizableOrientation

/// Styled panel group configuration alias.
pub type ResizablePanelGroupConfig(msg) =
  headless_resizable.ResizablePanelGroupConfig(msg)

/// Styled handle configuration alias.
pub type ResizableHandleConfig(msg) =
  headless_resizable.ResizableHandleConfig(msg)

/// Horizontal panel split orientation.
pub fn resizable_horizontal(theme _theme: theme.Theme) -> ResizableOrientation {
  headless_resizable.resizable_horizontal()
}

/// Vertical panel split orientation.
pub fn resizable_vertical(theme _theme: theme.Theme) -> ResizableOrientation {
  headless_resizable.resizable_vertical()
}

/// Construct a default panel group configuration.
pub fn resizable_panel_group_config(
  theme _theme: theme.Theme,
) -> ResizablePanelGroupConfig(msg) {
  headless_resizable.resizable_panel_group_config()
}

/// Set panel group orientation.
pub fn resizable_panel_group_orientation(
  theme _theme: theme.Theme,
  config config: ResizablePanelGroupConfig(msg),
  orientation orientation: ResizableOrientation,
) -> ResizablePanelGroupConfig(msg) {
  headless_resizable.resizable_panel_group_orientation(
    config: config,
    orientation: orientation,
  )
}

/// Append panel group attributes.
pub fn resizable_panel_group_attrs(
  theme _theme: theme.Theme,
  config config: ResizablePanelGroupConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ResizablePanelGroupConfig(msg) {
  headless_resizable.resizable_panel_group_attrs(config: config, attrs: attrs)
}

/// Construct a default handle configuration.
pub fn resizable_handle_config(
  theme _theme: theme.Theme,
) -> ResizableHandleConfig(msg) {
  headless_resizable.resizable_handle_config()
}

/// Enable visual grip affordance on the handle.
pub fn resizable_handle_with_handle(
  theme _theme: theme.Theme,
  config config: ResizableHandleConfig(msg),
) -> ResizableHandleConfig(msg) {
  headless_resizable.resizable_handle_with_handle(config: config)
}

/// Set handle orientation.
pub fn resizable_handle_orientation(
  theme _theme: theme.Theme,
  config config: ResizableHandleConfig(msg),
  orientation orientation: ResizableOrientation,
) -> ResizableHandleConfig(msg) {
  headless_resizable.resizable_handle_orientation(
    config: config,
    orientation: orientation,
  )
}

/// Append handle attributes.
pub fn resizable_handle_attrs(
  theme _theme: theme.Theme,
  config config: ResizableHandleConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ResizableHandleConfig(msg) {
  headless_resizable.resizable_handle_attrs(config: config, attrs: attrs)
}

/// Read the configured panel group orientation.
pub fn resizable_panel_group_config_orientation(
  theme _theme: theme.Theme,
  config config: ResizablePanelGroupConfig(msg),
) -> ResizableOrientation {
  headless_resizable.resizable_panel_group_config_orientation(config: config)
}

/// Check whether orientation is horizontal.
pub fn resizable_orientation_is_horizontal(
  theme _theme: theme.Theme,
  orientation orientation: ResizableOrientation,
) -> Bool {
  headless_resizable.resizable_orientation_is_horizontal(
    orientation: orientation,
  )
}

/// Check whether orientation is vertical.
pub fn resizable_orientation_is_vertical(
  theme _theme: theme.Theme,
  orientation orientation: ResizableOrientation,
) -> Bool {
  headless_resizable.resizable_orientation_is_vertical(orientation: orientation)
}

/// Check whether handle config enables the grip affordance.
pub fn resizable_handle_config_with_handle(
  theme _theme: theme.Theme,
  config config: ResizableHandleConfig(msg),
) -> Bool {
  headless_resizable.resizable_handle_config_with_handle(config: config)
}

/// Read configured handle orientation.
pub fn resizable_handle_config_orientation(
  theme _theme: theme.Theme,
  config config: ResizableHandleConfig(msg),
) -> ResizableOrientation {
  headless_resizable.resizable_handle_config_orientation(config: config)
}

/// Set handle orientation from panel group orientation.
pub fn resizable_handle_orientation_from_group(
  theme _theme: theme.Theme,
  config config: ResizableHandleConfig(msg),
  group_config group_config: ResizablePanelGroupConfig(msg),
) -> ResizableHandleConfig(msg) {
  headless_resizable.resizable_handle_orientation_from_group(
    config: config,
    group_config: group_config,
  )
}

fn group_styles(
  orientation orientation: ResizableOrientation,
) -> List(weft.Attribute) {
  case
    headless_resizable.resizable_orientation_is_vertical(
      orientation: orientation,
    )
  {
    True -> [
      weft.column_layout(),
      weft.height(length: weft.fill()),
      weft.width(length: weft.fill()),
    ]
    False -> [
      weft.row_layout(),
      weft.height(length: weft.fill()),
      weft.width(length: weft.fill()),
    ]
  }
}

/// Render a styled panel group container.
pub fn resizable_panel_group(
  theme theme: theme.Theme,
  config config: ResizablePanelGroupConfig(msg),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let orientation =
    headless_resizable.resizable_panel_group_config_orientation(config: config)

  headless_resizable.resizable_panel_group(
    config: config
      |> headless_resizable.resizable_panel_group_attrs(attrs: [
        weft_lustre.styles(
          list.append(group_styles(orientation: orientation), [
            weft.font_family(families: theme.font_families(theme)),
          ]),
        ),
      ]),
    children: children,
  )
}

/// Render a styled panel container.
pub fn resizable_panel(
  theme theme: theme.Theme,
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  let #(_, surface_fg) = theme.surface(theme)

  headless_resizable.resizable_panel(
    attrs: list.append(
      [
        weft_lustre.styles([
          weft.width(length: weft.fill()),
          weft.height(length: weft.fill()),
          weft.text_color(color: surface_fg),
        ]),
      ],
      attrs,
    ),
    children: children,
  )
}

/// Render a styled resize handle.
pub fn resizable_handle(
  theme theme: theme.Theme,
  config config: ResizableHandleConfig(msg),
) -> weft_lustre.Element(msg) {
  let with_handle =
    headless_resizable.resizable_handle_config_with_handle(config: config)
  let orientation =
    headless_resizable.resizable_handle_config_orientation(config: config)

  let base_styles =
    list.flatten([
      [
        weft.display(value: weft.display_flex()),
        weft.align_items(value: weft.align_items_center()),
        weft.justify_content(value: weft.justify_center()),
        weft.background(color: theme.border_color(theme)),
      ],
      case
        headless_resizable.resizable_orientation_is_horizontal(
          orientation: orientation,
        )
      {
        True -> [
          weft.width(length: weft.fixed(length: weft.pct(pct: 100.0))),
          weft.height(length: weft.fixed(length: weft.px(pixels: 1))),
        ]
        False -> [
          weft.width(length: weft.fixed(length: weft.px(pixels: 1))),
          weft.height(length: weft.fixed(length: weft.pct(pct: 100.0))),
        ]
      },
    ])

  let grip_styles = case with_handle {
    True ->
      list.flatten([
        [
          weft.display(value: weft.display_block()),
          weft.rounded(radius: weft.px(pixels: 4)),
          weft.background(color: theme.muted_text(theme)),
        ],
        case
          headless_resizable.resizable_orientation_is_horizontal(
            orientation: orientation,
          )
        {
          True -> [
            weft.width(length: weft.fixed(length: weft.px(pixels: 24))),
            weft.height(length: weft.fixed(length: weft.px(pixels: 10))),
          ]
          False -> [
            weft.width(length: weft.fixed(length: weft.px(pixels: 10))),
            weft.height(length: weft.fixed(length: weft.px(pixels: 24))),
          ]
        },
      ])
    False -> []
  }

  headless_resizable.resizable_handle(
    config: config
    |> headless_resizable.resizable_handle_attrs(attrs: [
      weft_lustre.styles(base_styles),
      weft_lustre.styles(grip_styles),
    ]),
  )
}
