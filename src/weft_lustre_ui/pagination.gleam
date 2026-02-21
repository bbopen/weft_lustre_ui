//// Styled, theme-driven pagination component for weft_lustre_ui.
////
//// Renders a `<nav>` with `role="navigation"` containing themed previous/next
//// buttons and numbered page links. Active pages use accent background, and
//// buttons use hover surface effects. All styling is composed from `weft`
//// primitives.

import gleam/int
import gleam/list
import lustre/attribute
import lustre/event
import weft
import weft_lustre
import weft_lustre_ui/headless/pagination as headless_pagination
import weft_lustre_ui/theme

/// A page item in the pagination range.
pub type PageItem =
  headless_pagination.PageItem

/// Styled pagination configuration.
pub opaque type PaginationConfig(msg) {
  PaginationConfig(inner: headless_pagination.PaginationConfig(msg))
}

/// Construct a pagination configuration.
///
/// The `current` page and `total` page count are required, along with a
/// callback that receives the page number when a page is selected.
pub fn pagination_config(
  current current: Int,
  total total: Int,
  on_page on_page: fn(Int) -> msg,
) -> PaginationConfig(msg) {
  PaginationConfig(inner: headless_pagination.pagination_config(
    current: current,
    total: total,
    on_page: on_page,
  ))
}

/// Set the number of sibling pages shown around the current page.
///
/// Defaults to 1 if not set.
pub fn pagination_siblings(
  config config: PaginationConfig(msg),
  siblings siblings: Int,
) -> PaginationConfig(msg) {
  PaginationConfig(inner: headless_pagination.pagination_siblings(
    config: config.inner,
    siblings: siblings,
  ))
}

/// Append additional attributes to the root `<nav>` element.
pub fn pagination_attrs(
  config config: PaginationConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> PaginationConfig(msg) {
  PaginationConfig(inner: headless_pagination.pagination_attrs(
    config: config.inner,
    attrs: attrs,
  ))
}

fn nav_button_styles(
  theme theme: theme.Theme,
  disabled disabled: Bool,
) -> List(weft.Attribute) {
  let transparent = weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.0)
  let #(_, surface_fg) = theme.surface(theme)
  let radius = theme.radius_md(theme)

  list.flatten([
    [
      weft.display(value: weft.display_inline_flex()),
      weft.align_items(value: weft.align_items_center()),
      weft.justify_content(value: weft.justify_center()),
      weft.width(length: weft.fixed(length: weft.px(pixels: 36))),
      weft.height(length: weft.fixed(length: weft.px(pixels: 36))),
      weft.rounded(radius: radius),
      weft.font_size(size: weft.rem(rem: 0.875)),
      weft.font_weight(weight: weft.font_weight_value(weight: 500)),
      weft.font_family(families: theme.font_families(theme)),
      weft.text_color(color: surface_fg),
      weft.background(color: transparent),
      weft.border(
        width: weft.px(pixels: 0),
        style: weft.border_style_none(),
        color: transparent,
      ),
      weft.cursor(cursor: weft.cursor_pointer()),
      weft.outline_none(),
      weft.appearance(value: weft.appearance_none()),
      weft.transition(
        property: weft.transition_property_background_color(),
        duration: weft.ms(milliseconds: 150),
        easing: weft.ease(),
      ),
    ],
    case disabled {
      True -> [
        weft.alpha(opacity: theme.disabled_opacity(theme)),
        weft.cursor(cursor: weft.cursor_not_allowed()),
      ]
      False -> [
        weft.mouse_over(attrs: [
          weft.background(color: theme.hover_surface(theme)),
        ]),
      ]
    },
  ])
}

fn page_button_styles(
  theme theme: theme.Theme,
  active active: Bool,
) -> List(weft.Attribute) {
  let transparent = weft.rgba(red: 0, green: 0, blue: 0, alpha: 0.0)
  let #(_, surface_fg) = theme.surface(theme)
  let #(accent_bg, accent_fg) = theme.accent(theme)
  let radius = theme.radius_md(theme)
  let border_color = theme.border_color(theme)

  let #(bg, fg, border_w, border_s, border_c) = case active {
    True -> #(
      accent_bg,
      accent_fg,
      weft.px(pixels: 1),
      weft.border_style_solid(),
      border_color,
    )
    False -> #(
      transparent,
      surface_fg,
      weft.px(pixels: 0),
      weft.border_style_none(),
      transparent,
    )
  }

  list.flatten([
    [
      weft.display(value: weft.display_inline_flex()),
      weft.align_items(value: weft.align_items_center()),
      weft.justify_content(value: weft.justify_center()),
      weft.width(length: weft.fixed(length: weft.px(pixels: 36))),
      weft.height(length: weft.fixed(length: weft.px(pixels: 36))),
      weft.rounded(radius: radius),
      weft.font_size(size: weft.rem(rem: 0.875)),
      weft.font_weight(weight: weft.font_weight_value(weight: 500)),
      weft.font_family(families: theme.font_families(theme)),
      weft.text_color(color: fg),
      weft.background(color: bg),
      weft.border(width: border_w, style: border_s, color: border_c),
      weft.cursor(cursor: weft.cursor_pointer()),
      weft.outline_none(),
      weft.appearance(value: weft.appearance_none()),
      weft.transition(
        property: weft.transition_property_background_color(),
        duration: weft.ms(milliseconds: 150),
        easing: weft.ease(),
      ),
    ],
    case active {
      False -> [
        weft.mouse_over(attrs: [
          weft.background(color: theme.hover_surface(theme)),
        ]),
      ]
      True -> []
    },
  ])
}

fn ellipsis_styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  let #(_, surface_fg) = theme.surface(theme)

  [
    weft.display(value: weft.display_inline_flex()),
    weft.align_items(value: weft.align_items_center()),
    weft.justify_content(value: weft.justify_center()),
    weft.width(length: weft.fixed(length: weft.px(pixels: 36))),
    weft.height(length: weft.fixed(length: weft.px(pixels: 36))),
    weft.font_size(size: weft.rem(rem: 0.875)),
    weft.font_family(families: theme.font_families(theme)),
    weft.text_color(color: surface_fg),
  ]
}

fn render_styled_page_button(
  theme theme: theme.Theme,
  page page: Int,
  current current: Int,
  on_page on_page: fn(Int) -> msg,
) -> weft_lustre.Element(msg) {
  let is_active = page == current

  let aria_attrs = case is_active {
    True -> [
      weft_lustre.html_attribute(attribute.attribute("aria-current", "page")),
    ]
    False -> []
  }

  weft_lustre.element_tag(tag: "li", base_weft_attrs: [], attrs: [], children: [
    weft_lustre.element_tag(
      tag: "button",
      base_weft_attrs: [weft.el_layout()],
      attrs: list.flatten([
        [
          weft_lustre.html_attribute(attribute.type_("button")),
          weft_lustre.styles(page_button_styles(theme: theme, active: is_active)),
          weft_lustre.html_attribute(event.on_click(on_page(page))),
        ],
        aria_attrs,
      ]),
      children: [weft_lustre.text(content: int.to_string(page))],
    ),
  ])
}

fn render_styled_ellipsis(theme theme: theme.Theme) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(tag: "li", base_weft_attrs: [], attrs: [], children: [
    weft_lustre.element_tag(
      tag: "span",
      base_weft_attrs: [weft.el_layout()],
      attrs: [
        weft_lustre.html_attribute(attribute.attribute("aria-hidden", "true")),
        weft_lustre.styles(ellipsis_styles(theme: theme)),
      ],
      children: [weft_lustre.text(content: "...")],
    ),
  ])
}

fn render_styled_page_item(
  theme theme: theme.Theme,
  item item: headless_pagination.PageItem,
  current current: Int,
  on_page on_page: fn(Int) -> msg,
) -> weft_lustre.Element(msg) {
  case item {
    headless_pagination.Page(number:) ->
      render_styled_page_button(
        theme: theme,
        page: number,
        current: current,
        on_page: on_page,
      )
    headless_pagination.Ellipsis -> render_styled_ellipsis(theme: theme)
  }
}

/// Render a styled pagination component.
///
/// Produces a themed `<nav>` with centered page buttons, previous/next
/// navigation, and ellipsis indicators. Active pages use the accent
/// background/foreground pair with an outline. Disabled navigation buttons
/// render at reduced opacity.
pub fn pagination(
  theme theme: theme.Theme,
  config config: PaginationConfig(msg),
) -> weft_lustre.Element(msg) {
  let current =
    headless_pagination.pagination_config_current(config: config.inner)
  let total = headless_pagination.pagination_config_total(config: config.inner)
  let on_page =
    headless_pagination.pagination_config_on_page(config: config.inner)
  let siblings =
    headless_pagination.pagination_config_siblings(config: config.inner)
  let attrs = headless_pagination.pagination_config_attrs(config: config.inner)

  let items =
    headless_pagination.pagination_range(
      current: current,
      total: total,
      siblings: siblings,
    )

  let page_elements =
    list.map(items, fn(item) {
      render_styled_page_item(
        theme: theme,
        item: item,
        current: current,
        on_page: on_page,
      )
    })

  let is_first = current <= 1
  let is_last = current >= total

  let prev_button =
    weft_lustre.element_tag(
      tag: "li",
      base_weft_attrs: [],
      attrs: [],
      children: [
        weft_lustre.element_tag(
          tag: "button",
          base_weft_attrs: [weft.el_layout()],
          attrs: list.flatten([
            [
              weft_lustre.html_attribute(attribute.type_("button")),
              weft_lustre.html_attribute(attribute.attribute(
                "aria-label",
                "Go to previous page",
              )),
              weft_lustre.styles(nav_button_styles(
                theme: theme,
                disabled: is_first,
              )),
            ],
            case is_first {
              True -> [
                weft_lustre.html_attribute(attribute.disabled(True)),
              ]
              False -> [
                weft_lustre.html_attribute(event.on_click(on_page(current - 1))),
              ]
            },
          ]),
          children: [weft_lustre.text(content: "\u{2039}")],
        ),
      ],
    )

  let next_button =
    weft_lustre.element_tag(
      tag: "li",
      base_weft_attrs: [],
      attrs: [],
      children: [
        weft_lustre.element_tag(
          tag: "button",
          base_weft_attrs: [weft.el_layout()],
          attrs: list.flatten([
            [
              weft_lustre.html_attribute(attribute.type_("button")),
              weft_lustre.html_attribute(attribute.attribute(
                "aria-label",
                "Go to next page",
              )),
              weft_lustre.styles(nav_button_styles(
                theme: theme,
                disabled: is_last,
              )),
            ],
            case is_last {
              True -> [
                weft_lustre.html_attribute(attribute.disabled(True)),
              ]
              False -> [
                weft_lustre.html_attribute(event.on_click(on_page(current + 1))),
              ]
            },
          ]),
          children: [weft_lustre.text(content: "\u{203A}")],
        ),
      ],
    )

  let all_items = list.flatten([[prev_button], page_elements, [next_button]])

  let nav_styles = [
    weft.display(value: weft.display_flex()),
    weft.justify_content(value: weft.justify_center()),
    weft.width(length: weft.fill()),
  ]

  let ul_styles = [
    weft.row_layout(),
    weft.display(value: weft.display_flex()),
    weft.align_items(value: weft.align_items_center()),
    weft.spacing(pixels: 4),
  ]

  let ul_element =
    weft_lustre.element_tag(
      tag: "ul",
      base_weft_attrs: [weft.el_layout()],
      attrs: [weft_lustre.styles(ul_styles)],
      children: all_items,
    )

  weft_lustre.element_tag(
    tag: "nav",
    base_weft_attrs: [weft.el_layout()],
    attrs: list.flatten([
      [
        weft_lustre.html_attribute(attribute.role("navigation")),
        weft_lustre.html_attribute(attribute.attribute(
          "aria-label",
          "pagination",
        )),
        weft_lustre.styles(nav_styles),
      ],
      attrs,
    ]),
    children: [ul_element],
  )
}
