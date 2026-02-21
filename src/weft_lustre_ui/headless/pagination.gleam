//// Headless (unstyled) pagination component for weft_lustre_ui.
////
//// Renders a `<nav>` with `role="navigation"` containing previous/next
//// buttons and numbered page links with correct ARIA attributes. Visual
//// appearance is not applied here; the styled wrapper handles colors,
//// sizing, and hover states.

import gleam/int
import gleam/list
import lustre/attribute
import lustre/event
import weft
import weft_lustre

/// Represents a page item in the pagination range.
pub type PageItem {
  /// A page number that can be clicked.
  Page(number: Int)
  /// An ellipsis indicating skipped pages.
  Ellipsis
}

/// Configuration for the pagination component.
pub opaque type PaginationConfig(msg) {
  PaginationConfig(
    current: Int,
    total: Int,
    on_page: fn(Int) -> msg,
    siblings: Int,
    attrs: List(weft_lustre.Attribute(msg)),
  )
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
  PaginationConfig(
    current: current,
    total: total,
    on_page: on_page,
    siblings: 1,
    attrs: [],
  )
}

/// Set the number of sibling pages shown around the current page.
///
/// Defaults to 1 if not set. Values less than 0 are treated as 0.
pub fn pagination_siblings(
  config config: PaginationConfig(msg),
  siblings siblings: Int,
) -> PaginationConfig(msg) {
  let clamped = case siblings < 0 {
    True -> 0
    False -> siblings
  }
  PaginationConfig(..config, siblings: clamped)
}

/// Append additional attributes to the root `<nav>` element.
pub fn pagination_attrs(
  config config: PaginationConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> PaginationConfig(msg) {
  case config {
    PaginationConfig(attrs: existing, ..) ->
      PaginationConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Internal: read the current page from a pagination config.
@internal
pub fn pagination_config_current(config config: PaginationConfig(msg)) -> Int {
  case config {
    PaginationConfig(current:, ..) -> current
  }
}

/// Internal: read the total page count from a pagination config.
@internal
pub fn pagination_config_total(config config: PaginationConfig(msg)) -> Int {
  case config {
    PaginationConfig(total:, ..) -> total
  }
}

/// Internal: read the on_page callback from a pagination config.
@internal
pub fn pagination_config_on_page(
  config config: PaginationConfig(msg),
) -> fn(Int) -> msg {
  case config {
    PaginationConfig(on_page:, ..) -> on_page
  }
}

/// Internal: read the siblings count from a pagination config.
@internal
pub fn pagination_config_siblings(config config: PaginationConfig(msg)) -> Int {
  case config {
    PaginationConfig(siblings:, ..) -> siblings
  }
}

/// Internal: read the attrs from a pagination config.
@internal
pub fn pagination_config_attrs(
  config config: PaginationConfig(msg),
) -> List(weft_lustre.Attribute(msg)) {
  case config {
    PaginationConfig(attrs:, ..) -> attrs
  }
}

/// Compute the range of page items to display.
///
/// Always shows the first and last page, the current page, and `siblings`
/// pages on each side of current. Uses `Ellipsis` where pages are skipped.
/// If only one page would be hidden between two visible pages, that page
/// is shown instead of an ellipsis.
///
/// Returns an empty list when `total` is less than 1.
pub fn pagination_range(
  current current: Int,
  total total: Int,
  siblings siblings: Int,
) -> List(PageItem) {
  case total < 1 {
    True -> []
    False -> {
      let clamped_current = clamp(current, 1, total)
      let sibling_start = clamp(clamped_current - siblings, 1, total)
      let sibling_end = clamp(clamped_current + siblings, 1, total)

      // Build sorted unique list of must-show pages
      let must_show =
        build_page_set(
          sibling_start: sibling_start,
          sibling_end: sibling_end,
          total: total,
        )

      // Walk through must-show and fill gaps
      fill_gaps(must_show, [])
    }
  }
}

fn clamp(value: Int, min: Int, max: Int) -> Int {
  case value < min {
    True -> min
    False ->
      case value > max {
        True -> max
        False -> value
      }
  }
}

fn build_page_set(
  sibling_start sibling_start: Int,
  sibling_end sibling_end: Int,
  total total: Int,
) -> List(Int) {
  // Start with page 1
  let pages = [1]

  // Add sibling range
  let pages = add_range(pages, sibling_start, sibling_end)

  // Add last page
  let pages = case total > 1 {
    True -> insert_sorted(pages, total)
    False -> pages
  }

  pages
}

fn add_range(pages: List(Int), from: Int, to: Int) -> List(Int) {
  case from > to {
    True -> pages
    False -> add_range(insert_sorted(pages, from), from + 1, to)
  }
}

fn insert_sorted(pages: List(Int), value: Int) -> List(Int) {
  insert_sorted_acc(pages, value, [])
}

fn insert_sorted_acc(
  remaining: List(Int),
  value: Int,
  acc: List(Int),
) -> List(Int) {
  case remaining {
    [] -> list.reverse([value, ..acc])
    [head, ..tail] ->
      case value == head {
        // Already present, skip
        True -> list.append(list.reverse(acc), remaining)
        False ->
          case value < head {
            True -> list.append(list.reverse([value, ..acc]), remaining)
            False -> insert_sorted_acc(tail, value, [head, ..acc])
          }
      }
  }
}

fn fill_gaps(pages: List(Int), acc: List(PageItem)) -> List(PageItem) {
  case pages {
    [] -> list.reverse(acc)
    [page] -> list.reverse([Page(number: page), ..acc])
    [current_page, next_page, ..rest] -> {
      let gap = next_page - current_page
      case gap {
        // Adjacent pages — no filler needed
        1 -> fill_gaps([next_page, ..rest], [Page(number: current_page), ..acc])
        // Gap of exactly 2 — one missing page, show it instead of ellipsis
        2 ->
          fill_gaps([next_page, ..rest], [
            Page(number: current_page + 1),
            Page(number: current_page),
            ..acc
          ])
        // Gap of 3+ — use ellipsis
        _ ->
          fill_gaps([next_page, ..rest], [
            Ellipsis,
            Page(number: current_page),
            ..acc
          ])
      }
    }
  }
}

fn render_page_button(
  page: Int,
  current: Int,
  on_page: fn(Int) -> msg,
) -> weft_lustre.Element(msg) {
  let is_active = page == current

  let aria_attrs = case is_active {
    True -> [
      weft_lustre.html_attribute(attribute.attribute("aria-current", "page")),
    ]
    False -> []
  }

  let click_handler = [
    weft_lustre.html_attribute(event.on_click(on_page(page))),
  ]

  weft_lustre.element_tag(tag: "li", base_weft_attrs: [], attrs: [], children: [
    weft_lustre.element_tag(
      tag: "button",
      base_weft_attrs: [weft.el_layout()],
      attrs: list.flatten([
        [weft_lustre.html_attribute(attribute.type_("button"))],
        aria_attrs,
        click_handler,
      ]),
      children: [weft_lustre.text(content: int.to_string(page))],
    ),
  ])
}

fn render_ellipsis() -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(tag: "li", base_weft_attrs: [], attrs: [], children: [
    weft_lustre.element_tag(
      tag: "span",
      base_weft_attrs: [weft.el_layout()],
      attrs: [
        weft_lustre.html_attribute(attribute.attribute("aria-hidden", "true")),
      ],
      children: [weft_lustre.text(content: "...")],
    ),
  ])
}

fn render_page_item(
  item: PageItem,
  current: Int,
  on_page: fn(Int) -> msg,
) -> weft_lustre.Element(msg) {
  case item {
    Page(number:) -> render_page_button(number, current, on_page)
    Ellipsis -> render_ellipsis()
  }
}

/// Render a headless pagination component.
///
/// Produces a `<nav>` element with `role="navigation"` and
/// `aria-label="pagination"` containing previous/next buttons and numbered
/// page buttons. The active page receives `aria-current="page"`. Previous
/// and next buttons are disabled at the boundaries.
pub fn pagination(
  config config: PaginationConfig(msg),
) -> weft_lustre.Element(msg) {
  case config {
    PaginationConfig(current:, total:, on_page:, siblings:, attrs:) -> {
      let items =
        pagination_range(current: current, total: total, siblings: siblings)

      let page_elements =
        list.map(items, fn(item) { render_page_item(item, current, on_page) })

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
                ],
                case is_first {
                  True -> [
                    weft_lustre.html_attribute(attribute.disabled(True)),
                  ]
                  False -> [
                    weft_lustre.html_attribute(
                      event.on_click(on_page(current - 1)),
                    ),
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
                ],
                case is_last {
                  True -> [
                    weft_lustre.html_attribute(attribute.disabled(True)),
                  ]
                  False -> [
                    weft_lustre.html_attribute(
                      event.on_click(on_page(current + 1)),
                    ),
                  ]
                },
              ]),
              children: [weft_lustre.text(content: "\u{203A}")],
            ),
          ],
        )

      let all_items =
        list.flatten([[prev_button], page_elements, [next_button]])

      let ul_attrs = [
        weft_lustre.styles([
          weft.row_layout(),
          weft.display(value: weft.display_flex()),
          weft.align_items(value: weft.align_items_center()),
          weft.spacing(pixels: 4),
        ]),
      ]

      let ul_element =
        weft_lustre.element_tag(
          tag: "ul",
          base_weft_attrs: [weft.el_layout()],
          attrs: ul_attrs,
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
          ],
          attrs,
        ]),
        children: [ul_element],
      )
    }
  }
}
