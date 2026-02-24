//// Headless input-otp primitives for shadcn compatibility.
////
//// Provides a pure-Gleam controlled OTP input surface with group/slot
//// composition helpers and predictable update behavior.

import gleam/int
import gleam/list
import gleam/string
import lustre/attribute
import lustre/event
import weft
import weft_lustre

/// Input-otp configuration.
pub opaque type InputOtpConfig(msg) {
  InputOtpConfig(
    value: String,
    on_change: fn(String) -> msg,
    length: Int,
    disabled: Bool,
    attrs: List(weft_lustre.Attribute(msg)),
    container_attrs: List(weft_lustre.Attribute(msg)),
    group_attrs: List(weft_lustre.Attribute(msg)),
    slot_attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct an input-otp configuration.
pub fn input_otp_config(
  value value: String,
  on_change on_change: fn(String) -> msg,
) -> InputOtpConfig(msg) {
  InputOtpConfig(
    value: value,
    on_change: on_change,
    length: 6,
    disabled: False,
    attrs: [],
    container_attrs: [],
    group_attrs: [],
    slot_attrs: [],
  )
}

fn clamp_length(length: Int) -> Int {
  int.max(length, 1)
}

/// Set the number of OTP slots.
pub fn input_otp_length(
  config config: InputOtpConfig(msg),
  length length: Int,
) -> InputOtpConfig(msg) {
  InputOtpConfig(..config, length: clamp_length(length))
}

/// Disable OTP input.
pub fn input_otp_disabled(
  config config: InputOtpConfig(msg),
) -> InputOtpConfig(msg) {
  InputOtpConfig(..config, disabled: True)
}

/// Append root attributes.
pub fn input_otp_attrs(
  config config: InputOtpConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> InputOtpConfig(msg) {
  case config {
    InputOtpConfig(attrs: existing, ..) ->
      InputOtpConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Append container attributes.
pub fn input_otp_container_attrs(
  config config: InputOtpConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> InputOtpConfig(msg) {
  case config {
    InputOtpConfig(container_attrs: existing, ..) ->
      InputOtpConfig(..config, container_attrs: list.append(existing, attrs))
  }
}

/// Append group attributes.
pub fn input_otp_group_attrs(
  config config: InputOtpConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> InputOtpConfig(msg) {
  case config {
    InputOtpConfig(group_attrs: existing, ..) ->
      InputOtpConfig(..config, group_attrs: list.append(existing, attrs))
  }
}

/// Append slot attributes.
pub fn input_otp_slot_attrs(
  config config: InputOtpConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> InputOtpConfig(msg) {
  case config {
    InputOtpConfig(slot_attrs: existing, ..) ->
      InputOtpConfig(..config, slot_attrs: list.append(existing, attrs))
  }
}

fn normalized_chars(value: String, length: Int) -> List(String) {
  let target = clamp_length(length)
  let chars = value |> string.to_graphemes() |> list.take(up_to: target)
  let missing = target - list.length(chars)

  case missing > 0 {
    True -> list.append(chars, list.repeat(item: "", times: missing))
    False -> chars
  }
}

fn first_grapheme_or_empty(value: String) -> String {
  case string.to_graphemes(value) {
    [head, ..] -> head
    [] -> ""
  }
}

fn replace_slot(
  chars chars: List(String),
  index index: Int,
  value value: String,
) -> String {
  chars
  |> list.index_map(with: fn(char, i) {
    case i == index {
      True -> value
      False -> char
    }
  })
  |> string.join(with: "")
}

/// Render an input-otp root.
pub fn input_otp(config config: InputOtpConfig(msg)) -> weft_lustre.Element(msg) {
  case config {
    InputOtpConfig(
      value: value,
      on_change: on_change,
      length: length,
      disabled: disabled,
      attrs: attrs,
      container_attrs: container_attrs,
      group_attrs: group_attrs,
      slot_attrs: slot_attrs,
    ) -> {
      let chars = normalized_chars(value, length)

      let slot_children =
        list.index_map(chars, with: fn(char, index) {
          input_otp_slot(
            index: index,
            value: char,
            on_input: fn(input) {
              let next = first_grapheme_or_empty(input)
              on_change(replace_slot(chars, index, next))
            },
            disabled: disabled,
            attrs: slot_attrs,
          )
        })

      weft_lustre.element_tag(
        tag: "div",
        base_weft_attrs: [weft.el_layout()],
        attrs: list.flatten([
          [
            weft_lustre.html_attribute(attribute.attribute(
              "data-slot",
              "input-otp",
            )),
          ],
          case disabled {
            True -> [
              weft_lustre.html_attribute(attribute.attribute(
                "data-disabled",
                "true",
              )),
            ]
            False -> []
          },
          attrs,
          container_attrs,
        ]),
        children: [input_otp_group(attrs: group_attrs, children: slot_children)],
      )
    }
  }
}

/// Render an OTP slot group.
pub fn input_otp_group(
  attrs attrs: List(weft_lustre.Attribute(msg)),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.row_layout()],
    attrs: list.append(
      [
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "input-otp-group",
        )),
      ],
      attrs,
    ),
    children: children,
  )
}

/// Render a controlled OTP slot.
pub fn input_otp_slot(
  index index: Int,
  value value: String,
  on_input on_input: fn(String) -> msg,
  disabled disabled: Bool,
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> weft_lustre.Element(msg) {
  let required_attrs =
    list.flatten([
      [weft_lustre.html_attribute(attribute.type_("text"))],
      [weft_lustre.html_attribute(attribute.inputmode("numeric"))],
      [weft_lustre.html_attribute(attribute.attribute("maxlength", "1"))],
      [
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "input-otp-slot",
        )),
      ],
      [
        weft_lustre.html_attribute(attribute.attribute(
          "data-index",
          int.to_string(index),
        )),
      ],
      [weft_lustre.html_attribute(attribute.value(value))],
      [weft_lustre.html_attribute(event.on_input(on_input))],
      case disabled {
        True -> [weft_lustre.html_attribute(attribute.disabled(True))]
        False -> []
      },
    ])

  weft_lustre.element_tag(
    tag: "input",
    base_weft_attrs: [weft.el_layout()],
    attrs: list.append(required_attrs, attrs),
    children: [],
  )
}

/// Render an OTP separator slot.
pub fn input_otp_separator(
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> weft_lustre.Element(msg) {
  weft_lustre.element_tag(
    tag: "div",
    base_weft_attrs: [weft.el_layout()],
    attrs: list.append(
      [
        weft_lustre.html_attribute(attribute.attribute(
          "data-slot",
          "input-otp-separator",
        )),
        weft_lustre.html_attribute(attribute.role("separator")),
      ],
      attrs,
    ),
    children: [weft_lustre.text(content: "-")],
  )
}
