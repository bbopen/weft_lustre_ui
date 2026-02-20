//// Headless combobox — portal-based searchable select component.
////
//// Provides a trigger button that opens a panel with a text search input and
//// a filtered list of options. The panel escapes overflow/z-index contexts via
//// `weft_lustre.anchored_overlay` when an anchor rect is available, or falls
//// back to `weft_lustre.in_front` with fixed positioning otherwise.
////
//// Anchor measurement is the responsibility of the caller. The recommended
//// pattern is to capture `clientX`/`clientY` from the trigger's click event and
//// construct a `weft.Rect` from those values, passing it as `anchor_rect` to
//// `combobox_config`. See `combobox_measure_on_open` for a typed placeholder.
////
//// Visual styling is the responsibility of the caller (or the styled wrapper
//// in `weft_lustre_ui/combobox`).

import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/event
import weft
import weft_lustre

/// A single option in the combobox.
pub type ComboboxOption(a) {
  /// A selectable item with a typed value and a display label.
  ComboboxOption(value: a, label: String)
}

/// Configuration for the combobox component.
pub opaque type ComboboxConfig(a, msg) {
  ComboboxConfig(
    options: List(ComboboxOption(a)),
    value: Option(a),
    on_select: fn(Option(a)) -> msg,
    search: String,
    on_search: fn(String) -> msg,
    open: Bool,
    on_toggle: fn(Bool) -> msg,
    placeholder: String,
    anchor_rect: Option(weft.Rect),
    overlay_size: weft.Size,
    viewport: weft.Size,
    attrs: List(weft_lustre.Attribute(msg)),
    trigger_attrs: List(weft_lustre.Attribute(msg)),
    panel_attrs: List(weft_lustre.Attribute(msg)),
    search_input_attrs: List(weft_lustre.Attribute(msg)),
    option_attrs_fn: fn(a, Bool) -> List(weft_lustre.Attribute(msg)),
    option_to_string: fn(a) -> String,
  )
}

/// Construct a `ComboboxOption` with a typed value and display label.
pub fn combobox_option(value value: a, label label: String) -> ComboboxOption(a) {
  ComboboxOption(value: value, label: label)
}

/// Construct combobox configuration.
pub fn combobox_config(
  options options: List(ComboboxOption(a)),
  value value: Option(a),
  on_select on_select: fn(Option(a)) -> msg,
  search search: String,
  on_search on_search: fn(String) -> msg,
  open open: Bool,
  on_toggle on_toggle: fn(Bool) -> msg,
  placeholder placeholder: String,
  anchor_rect anchor_rect: Option(weft.Rect),
  overlay_size overlay_size: weft.Size,
  viewport viewport: weft.Size,
  option_to_string option_to_string: fn(a) -> String,
) -> ComboboxConfig(a, msg) {
  ComboboxConfig(
    options: options,
    value: value,
    on_select: on_select,
    search: search,
    on_search: on_search,
    open: open,
    on_toggle: on_toggle,
    placeholder: placeholder,
    anchor_rect: anchor_rect,
    overlay_size: overlay_size,
    viewport: viewport,
    attrs: [],
    trigger_attrs: [],
    panel_attrs: [],
    search_input_attrs: [],
    option_attrs_fn: fn(_value, _is_selected) { [] },
    option_to_string: option_to_string,
  )
}

/// Append root-level attributes to the combobox container.
pub fn combobox_attrs(
  config config: ComboboxConfig(a, msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ComboboxConfig(a, msg) {
  case config {
    ComboboxConfig(attrs: existing, ..) ->
      ComboboxConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Append trigger button attributes.
pub fn combobox_trigger_attrs(
  config config: ComboboxConfig(a, msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ComboboxConfig(a, msg) {
  case config {
    ComboboxConfig(trigger_attrs: existing, ..) ->
      ComboboxConfig(..config, trigger_attrs: list.append(existing, attrs))
  }
}

/// Append panel container attributes.
pub fn combobox_panel_attrs(
  config config: ComboboxConfig(a, msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ComboboxConfig(a, msg) {
  case config {
    ComboboxConfig(panel_attrs: existing, ..) ->
      ComboboxConfig(..config, panel_attrs: list.append(existing, attrs))
  }
}

/// Append search input attributes (appended to the built-in type/value/on_input attrs).
pub fn combobox_search_input_attrs(
  config config: ComboboxConfig(a, msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ComboboxConfig(a, msg) {
  case config {
    ComboboxConfig(search_input_attrs: existing, ..) ->
      ComboboxConfig(..config, search_input_attrs: list.append(existing, attrs))
  }
}

/// Set a function that returns additional attributes for each option row.
///
/// The function receives the option value and a boolean indicating whether
/// the option is currently selected, and returns a list of attributes to
/// append to that option's root element.
pub fn combobox_option_attrs_fn(
  config config: ComboboxConfig(a, msg),
  option_attrs_fn option_attrs_fn: fn(a, Bool) ->
    List(weft_lustre.Attribute(msg)),
) -> ComboboxConfig(a, msg) {
  ComboboxConfig(..config, option_attrs_fn: option_attrs_fn)
}

fn filter_options(
  options: List(ComboboxOption(a)),
  search: String,
) -> List(ComboboxOption(a)) {
  case string.is_empty(search) {
    True -> options
    False ->
      list.filter(options, fn(opt) {
        string.contains(string.lowercase(opt.label), string.lowercase(search))
      })
  }
}

fn selected_label(
  value: Option(a),
  options: List(ComboboxOption(a)),
  option_to_string: fn(a) -> String,
  placeholder: String,
) -> String {
  case value {
    None -> placeholder
    Some(v) -> {
      let target = option_to_string(v)
      let found =
        list.find(options, fn(opt) { option_to_string(opt.value) == target })
      case found {
        Ok(opt) -> opt.label
        Error(Nil) -> placeholder
      }
    }
  }
}

fn build_panel(
  config: ComboboxConfig(a, msg),
  filtered: List(ComboboxOption(a)),
) -> weft_lustre.Element(msg) {
  case config {
    ComboboxConfig(
      value: selected_value,
      on_select: on_select,
      search: search,
      on_search: on_search,
      on_toggle: on_toggle,
      panel_attrs: panel_attrs,
      search_input_attrs: search_input_attrs,
      option_attrs_fn: option_attrs_fn,
      option_to_string: option_to_string,
      ..,
    ) -> {
      let search_input =
        weft_lustre.element_tag(
          tag: "input",
          base_weft_attrs: [weft.el_layout()],
          attrs: list.append(
            [
              weft_lustre.html_attribute(attribute.type_("text")),
              weft_lustre.html_attribute(attribute.value(search)),
              weft_lustre.html_attribute(attribute.placeholder("Search…")),
              weft_lustre.html_attribute(event.on_input(on_search)),
            ],
            search_input_attrs,
          ),
          children: [],
        )

      let option_rows =
        list.map(filtered, fn(opt) {
          let is_selected =
            option.map(selected_value, fn(v) {
              option_to_string(v) == option_to_string(opt.value)
            })
            |> option.unwrap(or: False)

          let extra_attrs = option_attrs_fn(opt.value, is_selected)

          weft_lustre.el(
            attrs: list.append(
              [
                weft_lustre.html_attribute(
                  event.on_click({
                    let select_msg = on_select(Some(opt.value))
                    let _ = on_toggle(False)
                    select_msg
                  }),
                ),
                weft_lustre.html_attribute(
                  attribute.data("weft-combobox-selected", case is_selected {
                    True -> "true"
                    False -> "false"
                  }),
                ),
              ],
              extra_attrs,
            ),
            child: weft_lustre.text(content: opt.label),
          )
        })

      weft_lustre.column(attrs: panel_attrs, children: [
        search_input,
        weft_lustre.column(attrs: [], children: option_rows),
      ])
    }
  }
}

/// Render the headless combobox.
///
/// Always renders the trigger button. When `open` is `True`, the option panel
/// is portalled via `weft_lustre.anchored_overlay` if `anchor_rect` is
/// available, or via `weft_lustre.in_front` with fixed fallback positioning
/// otherwise.
pub fn combobox(
  config config: ComboboxConfig(a, msg),
) -> weft_lustre.Element(msg) {
  case config {
    ComboboxConfig(
      options: options,
      value: value,
      search: search,
      open: open,
      on_toggle: on_toggle,
      placeholder: placeholder,
      anchor_rect: anchor_rect,
      overlay_size: overlay_size,
      viewport: viewport,
      attrs: attrs,
      trigger_attrs: trigger_attrs,
      option_to_string: option_to_string,
      ..,
    ) -> {
      let label = selected_label(value, options, option_to_string, placeholder)

      let trigger =
        weft_lustre.element_tag(
          tag: "button",
          base_weft_attrs: [weft.el_layout()],
          attrs: [
            weft_lustre.html_attribute(attribute.type_("button")),
            weft_lustre.html_attribute(event.on_click(on_toggle(!open))),
            ..trigger_attrs
          ],
          children: [weft_lustre.text(content: label)],
        )

      let overlay = case open {
        False -> weft_lustre.none()
        True -> {
          let filtered = filter_options(options, search)
          let panel = build_panel(config, filtered)

          case anchor_rect {
            Some(anchor) ->
              weft_lustre.anchored_overlay(
                layer: weft_lustre.layer_in_front(),
                anchor: anchor,
                overlay_size: overlay_size,
                viewport: weft.rect(
                  x: 0,
                  y: 0,
                  width: weft.size_width(viewport),
                  height: weft.size_height(viewport),
                ),
                preferred_sides: [weft.overlay_side_below()],
                child: panel,
              )
            None ->
              weft_lustre.in_front(child: weft_lustre.el(
                attrs: [
                  weft_lustre.styles([
                    weft.position(value: weft.position_fixed()),
                    weft.top(length: weft.px(pixels: 0)),
                    weft.left(length: weft.px(pixels: 0)),
                  ]),
                ],
                child: panel,
              ))
          }
        }
      }

      weft_lustre.column(
        attrs: [
          weft_lustre.styles([
            weft.display(value: weft.display_inline_flex()),
            weft.align_items(value: weft.align_items_start()),
          ]),
          ..attrs
        ],
        children: [trigger, overlay],
      )
    }
  }
}

/// Placeholder effect for combobox anchor measurement.
///
/// This function provides a typed hook for callers that wish to perform trigger
/// measurement before showing the panel. Because DOM measurement requires
/// platform-specific APIs that are outside this cross-target package, this
/// always returns `effect.none()`.
///
/// Recommended pattern: capture `clientX`/`clientY` from the trigger button's
/// click event, build a `weft.Rect` with those coordinates, and pass the rect
/// as `anchor_rect` to `combobox_config`. The `viewport` parameter of
/// `combobox_config` should hold the current `window.innerWidth`/`innerHeight`
/// values, also sourced from click-event or resize-event data in the parent
/// model.
pub fn combobox_measure_on_open(
  trigger_id trigger_id: String,
  open open: Bool,
  on_measure on_measure: fn(weft.Rect, weft.Size, weft.Size) -> msg,
) -> Effect(msg) {
  let _ = trigger_id
  let _ = open
  let _ = on_measure
  effect.none()
}
