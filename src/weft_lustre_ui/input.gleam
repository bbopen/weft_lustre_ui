//// Form input components for weft_lustre_ui (themed).
////
//// These components render native form controls (`input`, `textarea`, `select`)
//// and style them using weft primitives. They are designed to work with both
//// client rendering and SSR via `element.to_string`.

import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute
import lustre/event
import weft
import weft_lustre
import weft_lustre_ui/theme

/// Mark a form control as required.
pub fn input_required() -> weft_lustre.Attribute(msg) {
  weft_lustre.html_attribute(attribute.required(True))
}

/// Attach a `name` attribute to a form control.
pub fn input_name(value value: String) -> weft_lustre.Attribute(msg) {
  weft_lustre.html_attribute(attribute.name(value))
}

/// Attach an `autocomplete` hint to a form control.
pub fn input_autocomplete(value value: String) -> weft_lustre.Attribute(msg) {
  weft_lustre.html_attribute(attribute.autocomplete(value))
}

/// Attach an `inputmode` hint to a form control.
pub fn input_inputmode(value value: String) -> weft_lustre.Attribute(msg) {
  weft_lustre.html_attribute(attribute.inputmode(value))
}

/// Enable spellchecking for a form control.
pub fn input_spellcheck_enabled() -> weft_lustre.Attribute(msg) {
  weft_lustre.html_attribute(attribute.spellcheck(True))
}

/// Disable spellchecking for a form control.
pub fn input_spellcheck_disabled() -> weft_lustre.Attribute(msg) {
  weft_lustre.html_attribute(attribute.spellcheck(False))
}

/// Focus a form control on initial page load (SSR) and when toggled true
/// (client).
pub fn input_autofocus() -> weft_lustre.Attribute(msg) {
  weft_lustre.html_attribute(attribute.autofocus(True))
}

type Kind {
  Text
  Email
  Password
  Search
  Url
  Tel
  Number
}

/// An `<input>` type for `text_input`.
pub opaque type TextInputType {
  TextInputType(value: Kind)
}

/// Input type `"text"`.
pub fn input_type_text() -> TextInputType {
  TextInputType(value: Text)
}

/// Input type `"email"`.
pub fn input_type_email() -> TextInputType {
  TextInputType(value: Email)
}

/// Input type `"password"`.
pub fn input_type_password() -> TextInputType {
  TextInputType(value: Password)
}

/// Input type `"search"`.
pub fn input_type_search() -> TextInputType {
  TextInputType(value: Search)
}

/// Input type `"url"`.
pub fn input_type_url() -> TextInputType {
  TextInputType(value: Url)
}

/// Input type `"tel"`.
pub fn input_type_tel() -> TextInputType {
  TextInputType(value: Tel)
}

/// Input type `"number"`.
pub fn input_type_number() -> TextInputType {
  TextInputType(value: Number)
}

fn kind_value(kind: Kind) -> String {
  case kind {
    Text -> "text"
    Email -> "email"
    Password -> "password"
    Search -> "search"
    Url -> "url"
    Tel -> "tel"
    Number -> "number"
  }
}

fn input_type_value(value: TextInputType) -> String {
  case value {
    TextInputType(value:) -> kind_value(value)
  }
}

/// Configuration for a controlled text input.
pub opaque type TextInputConfig(msg) {
  TextInputConfig(
    value: String,
    on_input: fn(String) -> msg,
    input_type: TextInputType,
    placeholder: Option(String),
    disabled: Bool,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default text input config.
pub fn text_input_config(
  value value: String,
  on_input on_input: fn(String) -> msg,
) -> TextInputConfig(msg) {
  TextInputConfig(
    value: value,
    on_input: on_input,
    input_type: input_type_text(),
    placeholder: None,
    disabled: False,
    attrs: [],
  )
}

/// Set the `<input type="...">` value.
pub fn text_input_type(
  config config: TextInputConfig(msg),
  input_type input_type: TextInputType,
) -> TextInputConfig(msg) {
  TextInputConfig(..config, input_type: input_type)
}

/// Set an optional placeholder string.
pub fn text_input_placeholder(
  config config: TextInputConfig(msg),
  value value: String,
) -> TextInputConfig(msg) {
  TextInputConfig(..config, placeholder: Some(value))
}

/// Disable the input.
pub fn text_input_disabled(
  config config: TextInputConfig(msg),
) -> TextInputConfig(msg) {
  TextInputConfig(..config, disabled: True)
}

/// Append additional weft_lustre attributes to the input.
///
/// Attributes are appended, so later attributes can override earlier ones.
pub fn text_input_attrs(
  config config: TextInputConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> TextInputConfig(msg) {
  case config {
    TextInputConfig(attrs: existing, ..) ->
      TextInputConfig(..config, attrs: list.append(existing, attrs))
  }
}

fn max_int(a: Int, b: Int) -> Int {
  case a >= b {
    True -> a
    False -> b
  }
}

fn padding_for(space_md: Int) -> #(Int, Int) {
  let x = max_int(10, space_md)
  let y = max_int(8, space_md - 4)
  #(x, y)
}

fn base_text_control_styles(
  t: theme.Theme,
  disabled: Bool,
) -> List(weft.Attribute) {
  let #(surface_bg, surface_fg) = theme.input_surface(t)
  let border = theme.border_color(t)
  let radius = theme.radius_md(t)
  let #(pad_x, pad_y) = padding_for(theme.space_md(t))

  let cursor = case disabled {
    True -> weft.cursor_not_allowed()
    False -> weft.cursor_text()
  }

  [
    weft.display(value: weft.display_block()),
    // Ensure the control can fill available width regardless of parent
    // `align-items` settings.
    weft.width(length: weft.fixed(length: weft.pct(pct: 100.0))),
    weft.padding_xy(x: pad_x, y: pad_y),
    weft.rounded(radius: radius),
    weft.background(color: surface_bg),
    weft.text_color(color: surface_fg),
    weft.border(
      width: weft.px(pixels: 1),
      style: weft.border_style_solid(),
      color: border,
    ),
    weft.font_family(families: theme.font_families(t)),
    weft.font_size(size: weft.rem(rem: 0.875)),
    weft.line_height(height: weft.line_height_multiple(multiplier: 1.4)),
    weft.appearance(value: weft.appearance_none()),
    weft.outline_none(),
    weft.cursor(cursor: cursor),
    weft.transitions(transitions: [
      weft.transition_item(
        property: weft.transition_property_all(),
        duration: weft.ms(milliseconds: 120),
        easing: weft.ease_out(),
      ),
      weft.transition_item(
        property: weft.transition_property_box_shadow(),
        duration: weft.ms(milliseconds: 120),
        easing: weft.ease_out(),
      ),
    ]),
    weft.when(query: weft.prefers_reduced_motion(), attrs: [
      weft.transitions(transitions: []),
    ]),
    weft.focus_visible(attrs: [
      weft.outline(width: weft.px(pixels: 2), color: theme.focus_ring_color(t)),
      weft.outline_offset(length: weft.px(pixels: 2)),
    ]),
    weft.disabled(attrs: [
      weft.alpha(opacity: theme.disabled_opacity(t)),
      weft.cursor(cursor: weft.cursor_not_allowed()),
    ]),
  ]
}

/// Render a controlled text input.
pub fn text_input(
  theme theme: theme.Theme,
  config config: TextInputConfig(msg),
) -> weft_lustre.Element(msg) {
  case config {
    TextInputConfig(
      value: value,
      on_input: on_input,
      input_type: input_type,
      placeholder: placeholder,
      disabled: disabled,
      attrs: attrs,
    ) -> {
      let required_html_attrs =
        list.flatten([
          [
            weft_lustre.html_attribute(
              attribute.type_(input_type_value(input_type)),
            ),
          ],
          // Ensure controlled updates work on the client.
          [weft_lustre.html_attribute(attribute.value(value))],
          [weft_lustre.html_attribute(event.on_input(on_input))],
          case placeholder {
            None -> []
            Some(p) -> [weft_lustre.html_attribute(attribute.placeholder(p))]
          },
          case disabled {
            True -> [weft_lustre.html_attribute(attribute.disabled(True))]
            False -> []
          },
        ])

      let styles = base_text_control_styles(theme, disabled)
      let select_styles =
        list.append(styles, [
          weft.height(length: weft.fixed(length: weft.px(pixels: 32))),
          weft.padding_xy(x: 12, y: 6),
        ])

      let all_attrs =
        [weft_lustre.styles(select_styles), ..attrs]
        |> list.append(required_html_attrs)

      weft_lustre.element_tag(
        tag: "input",
        base_weft_attrs: [weft.el_layout()],
        attrs: all_attrs,
        children: [],
      )
    }
  }
}

/// Configuration for a controlled textarea.
pub opaque type TextareaConfig(msg) {
  TextareaConfig(
    value: String,
    on_input: fn(String) -> msg,
    placeholder: Option(String),
    rows: Option(Int),
    disabled: Bool,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default textarea config.
pub fn textarea_config(
  value value: String,
  on_input on_input: fn(String) -> msg,
) -> TextareaConfig(msg) {
  TextareaConfig(
    value: value,
    on_input: on_input,
    placeholder: None,
    rows: None,
    disabled: False,
    attrs: [],
  )
}

/// Set an optional placeholder string.
pub fn textarea_placeholder(
  config config: TextareaConfig(msg),
  value value: String,
) -> TextareaConfig(msg) {
  TextareaConfig(..config, placeholder: Some(value))
}

/// Set the textarea `rows` attribute.
pub fn textarea_rows(
  config config: TextareaConfig(msg),
  rows rows: Int,
) -> TextareaConfig(msg) {
  TextareaConfig(..config, rows: Some(rows))
}

/// Disable the textarea.
pub fn textarea_disabled(
  config config: TextareaConfig(msg),
) -> TextareaConfig(msg) {
  TextareaConfig(..config, disabled: True)
}

/// Append additional weft_lustre attributes to the textarea.
///
/// Attributes are appended, so later attributes can override earlier ones.
pub fn textarea_attrs(
  config config: TextareaConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> TextareaConfig(msg) {
  case config {
    TextareaConfig(attrs: existing, ..) ->
      TextareaConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Render a controlled textarea.
pub fn textarea(
  theme theme: theme.Theme,
  config config: TextareaConfig(msg),
) -> weft_lustre.Element(msg) {
  case config {
    TextareaConfig(
      value: value,
      on_input: on_input,
      placeholder: placeholder,
      rows: rows,
      disabled: disabled,
      attrs: attrs,
    ) -> {
      let required_html_attrs =
        list.flatten([
          // Ensure controlled updates work on the client.
          [weft_lustre.html_attribute(attribute.value(value))],
          [weft_lustre.html_attribute(event.on_input(on_input))],
          case placeholder {
            None -> []
            Some(p) -> [weft_lustre.html_attribute(attribute.placeholder(p))]
          },
          case rows {
            None -> []
            Some(r) -> [weft_lustre.html_attribute(attribute.rows(r))]
          },
          case disabled {
            True -> [weft_lustre.html_attribute(attribute.disabled(True))]
            False -> []
          },
        ])

      let styles = base_text_control_styles(theme, disabled)

      let all_attrs =
        [weft_lustre.styles(styles), ..attrs]
        |> list.append(required_html_attrs)

      // For SSR, the textarea value must be rendered as text content.
      let content = weft_lustre.text(content: value)

      weft_lustre.element_tag(
        tag: "textarea",
        base_weft_attrs: [weft.el_layout()],
        attrs: all_attrs,
        children: [content],
      )
    }
  }
}

/// A select option for the `select` component.
pub opaque type SelectOption {
  SelectOption(value: String, label: String, disabled: Bool)
}

/// Construct a select option.
pub fn select_option(value value: String, label label: String) -> SelectOption {
  SelectOption(value: value, label: label, disabled: False)
}

/// Disable a select option.
pub fn select_option_disabled(option option: SelectOption) -> SelectOption {
  SelectOption(..option, disabled: True)
}

fn option_value(option: SelectOption) -> String {
  case option {
    SelectOption(value:, ..) -> value
  }
}

fn option_label(option: SelectOption) -> String {
  case option {
    SelectOption(label:, ..) -> label
  }
}

fn option_disabled(option: SelectOption) -> Bool {
  case option {
    SelectOption(disabled:, ..) -> disabled
  }
}

/// Configuration for a controlled select.
pub opaque type SelectConfig(msg) {
  SelectConfig(
    value: String,
    on_change: fn(String) -> msg,
    options: List(SelectOption),
    disabled: Bool,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default select config.
pub fn select_config(
  value value: String,
  on_change on_change: fn(String) -> msg,
  options options: List(SelectOption),
) -> SelectConfig(msg) {
  SelectConfig(
    value: value,
    on_change: on_change,
    options: options,
    disabled: False,
    attrs: [],
  )
}

/// Disable the select.
pub fn select_disabled(config config: SelectConfig(msg)) -> SelectConfig(msg) {
  SelectConfig(..config, disabled: True)
}

/// Append additional weft_lustre attributes to the select.
///
/// Attributes are appended, so later attributes can override earlier ones.
pub fn select_attrs(
  config config: SelectConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> SelectConfig(msg) {
  case config {
    SelectConfig(attrs: existing, ..) ->
      SelectConfig(..config, attrs: list.append(existing, attrs))
  }
}

fn option_node(
  option: SelectOption,
  selected_value: String,
) -> weft_lustre.Element(msg) {
  let value = option_value(option)

  let attrs =
    list.flatten([
      [weft_lustre.html_attribute(attribute.value(value))],
      // For SSR, mark the matching option as selected.
      case value == selected_value {
        True -> [weft_lustre.html_attribute(attribute.selected(True))]
        False -> []
      },
      case option_disabled(option) {
        True -> [weft_lustre.html_attribute(attribute.disabled(True))]
        False -> []
      },
    ])

  weft_lustre.element_tag(
    tag: "option",
    base_weft_attrs: [weft.el_layout()],
    attrs: attrs,
    children: [weft_lustre.text(content: option_label(option))],
  )
}

/// Render a controlled select.
pub fn select(
  theme theme: theme.Theme,
  config config: SelectConfig(msg),
) -> weft_lustre.Element(msg) {
  case config {
    SelectConfig(
      value: value,
      on_change: on_change,
      options: options,
      disabled: disabled,
      attrs: attrs,
    ) -> {
      let required_html_attrs =
        list.flatten([
          // Ensure controlled updates work on the client.
          [weft_lustre.html_attribute(attribute.value(value))],
          [weft_lustre.html_attribute(event.on_change(on_change))],
          case disabled {
            True -> [weft_lustre.html_attribute(attribute.disabled(True))]
            False -> []
          },
        ])

      // Start from the shared base, then apply select-specific overrides.
      // The overrides MUST come after the base declarations so they win in the
      // generated CSS class (later same-property declarations take precedence).
      //
      // Key fixes:
      //   1. Fixed height + reduced vertical padding (4 px vs the base 8 px)
      //      ensures the 0.875 rem × 1.4 line-height (~19.6 px) fits inside
      //      the 32 - 8 = 24 px content box — preventing font clipping.
      //   2. `cursor_pointer` replaces the base `cursor_text` which is wrong
      //      for a drop-down control.
      let pad_x = max_int(10, theme.space_md(theme))
      let styles =
        list.append(base_text_control_styles(theme, disabled), [
          weft.height(length: weft.fixed(length: weft.px(pixels: 32))),
          weft.padding_xy(x: pad_x, y: 4),
          weft.cursor(cursor: case disabled {
            True -> weft.cursor_not_allowed()
            False -> weft.cursor_pointer()
          }),
        ])

      let all_attrs =
        [weft_lustre.styles(styles), ..attrs]
        |> list.append(required_html_attrs)

      weft_lustre.element_tag(
        tag: "select",
        base_weft_attrs: [weft.el_layout()],
        attrs: all_attrs,
        children: list.map(options, fn(option) { option_node(option, value) }),
      )
    }
  }
}
