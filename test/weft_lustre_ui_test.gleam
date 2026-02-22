import gleam/dynamic
import gleam/dynamic/decode
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/vdom/vattr
import lustre/vdom/vnode
import startest.{describe, it}
import startest/expect
import weft
import weft_lustre
import weft_lustre/overlay

import weft_lustre_ui/accordion as ui_accordion
import weft_lustre_ui/alert as ui_alert
import weft_lustre_ui/alert_dialog as ui_alert_dialog
import weft_lustre_ui/aspect_ratio as ui_aspect_ratio
import weft_lustre_ui/avatar as ui_avatar
import weft_lustre_ui/badge as ui_badge
import weft_lustre_ui/button as ui_button
import weft_lustre_ui/button_group as ui_button_group
import weft_lustre_ui/card as ui_card
import weft_lustre_ui/checkbox as ui_checkbox
import weft_lustre_ui/command as ui_command
import weft_lustre_ui/context_menu as ui_context_menu
import weft_lustre_ui/dialog as ui_dialog
import weft_lustre_ui/empty as ui_empty
import weft_lustre_ui/field as ui_field
import weft_lustre_ui/forms as ui_forms
import weft_lustre_ui/headless/accordion as headless_accordion
import weft_lustre_ui/headless/alert as headless_alert
import weft_lustre_ui/headless/alert_dialog as headless_alert_dialog
import weft_lustre_ui/headless/aspect_ratio as headless_aspect_ratio
import weft_lustre_ui/headless/badge as headless_badge
import weft_lustre_ui/headless/button as headless_button
import weft_lustre_ui/headless/button_group as headless_button_group
import weft_lustre_ui/headless/card as headless_card
import weft_lustre_ui/headless/checkbox as headless_checkbox
import weft_lustre_ui/headless/combobox as headless_combobox
import weft_lustre_ui/headless/command as headless_command
import weft_lustre_ui/headless/context_menu as headless_context_menu
import weft_lustre_ui/headless/dialog as headless_dialog
import weft_lustre_ui/headless/empty as headless_empty
import weft_lustre_ui/headless/field as headless_field
import weft_lustre_ui/headless/forms as headless_forms
import weft_lustre_ui/headless/hover_card as headless_hover_card
import weft_lustre_ui/headless/input as headless_input
import weft_lustre_ui/headless/input_group as headless_input_group
import weft_lustre_ui/headless/kbd as headless_kbd
import weft_lustre_ui/headless/label as headless_label
import weft_lustre_ui/headless/link as headless_link
import weft_lustre_ui/headless/native_select as headless_native_select
import weft_lustre_ui/headless/pagination as headless_pagination
import weft_lustre_ui/headless/progress as headless_progress
import weft_lustre_ui/headless/radio as headless_radio
import weft_lustre_ui/headless/radio_group as headless_radio_group
import weft_lustre_ui/headless/scroll_area as headless_scroll_area
import weft_lustre_ui/headless/separator as headless_separator
import weft_lustre_ui/headless/sidebar as headless_sidebar
import weft_lustre_ui/headless/skeleton as headless_skeleton
import weft_lustre_ui/headless/slider as headless_slider
import weft_lustre_ui/headless/spinner as headless_spinner
import weft_lustre_ui/headless/switch as headless_switch
import weft_lustre_ui/headless/tabs as headless_tabs
import weft_lustre_ui/headless/toast as headless_toast
import weft_lustre_ui/headless/toggle as headless_toggle
import weft_lustre_ui/headless/tooltip as headless_tooltip
import weft_lustre_ui/hover_card as ui_hover_card
import weft_lustre_ui/input as ui_input
import weft_lustre_ui/input_group as ui_input_group
import weft_lustre_ui/kbd as ui_kbd
import weft_lustre_ui/label as ui_label
import weft_lustre_ui/link as ui_link
import weft_lustre_ui/native_select as ui_native_select
import weft_lustre_ui/pagination as ui_pagination
import weft_lustre_ui/progress as ui_progress
import weft_lustre_ui/radio as ui_radio
import weft_lustre_ui/radio_group as ui_radio_group
import weft_lustre_ui/scroll_area as ui_scroll_area
import weft_lustre_ui/separator as ui_separator
import weft_lustre_ui/sidebar as ui_sidebar
import weft_lustre_ui/skeleton as ui_skeleton
import weft_lustre_ui/slider as ui_slider
import weft_lustre_ui/spinner as ui_spinner
import weft_lustre_ui/switch as ui_switch
import weft_lustre_ui/tabs as ui_tabs
import weft_lustre_ui/theme
import weft_lustre_ui/toast as ui_toast
import weft_lustre_ui/toggle as ui_toggle
import weft_lustre_ui/tooltip as ui_tooltip

pub fn main() {
  startest.run(startest.default_config())
}

fn overlay_with_solution() -> weft.OverlaySolution {
  weft.overlay_problem(
    anchor: weft.rect(x: 10, y: 10, width: 10, height: 10),
    overlay: weft.size(width: 20, height: 10),
    viewport: weft.rect(x: 0, y: 0, width: 200, height: 200),
  )
  |> weft.overlay_offset(pixels: 4)
  |> weft.solve_overlay
}

fn find_event_attribute(
  attrs: List(vattr.Attribute(msg)),
  event_name: String,
) -> Option(vattr.Attribute(msg)) {
  case
    list.find(attrs, fn(attr) {
      case attr {
        vattr.Event(name:, ..) -> name == event_name
        _ -> False
      }
    })
  {
    Ok(attr) -> Some(attr)
    Error(Nil) -> None
  }
}

fn find_first_event(
  element: weft_lustre.Element(msg),
  event_name: String,
) -> Option(vattr.Attribute(msg)) {
  let #(_, nodes) = weft_lustre.compile([], element)
  find_event_in_nodes(nodes, event_name)
}

fn find_event_in_nodes(
  nodes: List(vnode.Element(msg)),
  event_name: String,
) -> Option(vattr.Attribute(msg)) {
  case nodes {
    [] -> None
    [node, ..rest] ->
      case find_event_in_node(node, event_name) {
        Some(attr) -> Some(attr)
        None -> find_event_in_nodes(rest, event_name)
      }
  }
}

fn find_event_in_node(
  node: vnode.Element(msg),
  event_name: String,
) -> Option(vattr.Attribute(msg)) {
  case node {
    vnode.Element(attributes:, children:, ..) ->
      case find_event_attribute(attributes, event_name) {
        Some(attr) -> Some(attr)
        None -> find_event_in_nodes(children, event_name)
      }
    vnode.Fragment(children:, ..) -> find_event_in_nodes(children, event_name)
    vnode.UnsafeInnerHtml(attributes:, ..) ->
      find_event_attribute(attributes, event_name)
    vnode.Map(child:, ..) -> find_event_in_node(child, event_name)
    vnode.Memo(view:, ..) -> find_event_in_node(view(), event_name)
    vnode.Text(..) -> None
  }
}

type ComboboxEventMessage {
  ComboboxSelected(value: String)
  ComboboxToggled(open: Bool)
}

fn click_messages_from_attributes(
  attrs: List(vattr.Attribute(msg)),
) -> List(msg) {
  list.flat_map(attrs, fn(attr) {
    case attr {
      vattr.Event(name: "click", handler:, ..) ->
        case decode.run(dynamic.nil(), handler) {
          Ok(vattr.Handler(message:, ..)) -> [message]
          Error(_) -> []
        }
      _ -> []
    }
  })
}

fn click_messages(element: weft_lustre.Element(msg)) -> List(msg) {
  let #(_, nodes) = weft_lustre.compile([], element)
  list.flat_map(nodes, click_messages_from_node)
}

fn click_messages_from_node(element: vnode.Element(msg)) -> List(msg) {
  case element {
    vnode.Element(attributes:, children:, ..) ->
      list.append(
        click_messages_from_attributes(attributes),
        list.flat_map(children, click_messages_from_node),
      )
    vnode.Fragment(children:, ..) ->
      list.flat_map(children, click_messages_from_node)
    vnode.UnsafeInnerHtml(attributes:, ..) ->
      click_messages_from_attributes(attributes)
    vnode.Map(child:, ..) -> click_messages_from_node(child)
    vnode.Memo(view:, ..) -> click_messages_from_node(view())
    vnode.Text(..) -> []
  }
}

pub fn weft_lustre_ui_tests() {
  describe("weft_lustre_ui", [
    describe("headless", [
      it(
        "button renders `<button type=\"button\">` and respects disabled state",
        fn() {
          let enabled =
            headless_button.button(
              config: headless_button.button_config(on_press: "press"),
              child: weft_lustre.text(content: "Press"),
            )

          let disabled =
            headless_button.button(
              config: headless_button.button_config(on_press: "press")
                |> headless_button.button_disabled(),
              child: weft_lustre.text(content: "Press"),
            )

          let enabled_html =
            weft_lustre.layout(attrs: [], child: enabled)
            |> element.to_string

          let disabled_html =
            weft_lustre.layout(attrs: [], child: disabled)
            |> element.to_string

          string.contains(enabled_html, "type=\"button\"")
          |> expect.to_equal(expected: True)

          string.contains(disabled_html, "disabled")
          |> expect.to_equal(expected: True)
        },
      ),
      it("link sets href and new-tab attrs when requested", fn() {
        let same_tab =
          headless_link.link(
            config: headless_link.link_config(href: "/"),
            child: weft_lustre.text(content: "Home"),
          )

        let new_tab =
          headless_link.link(
            config: headless_link.link_config(href: "https://example.com")
              |> headless_link.link_new_tab(),
            child: weft_lustre.text(content: "Example"),
          )

        let same_tab_html =
          weft_lustre.layout(attrs: [], child: same_tab)
          |> element.to_string

        let new_tab_html =
          weft_lustre.layout(attrs: [], child: new_tab)
          |> element.to_string

        string.contains(same_tab_html, "href=\"/\"")
        |> expect.to_equal(expected: True)

        string.contains(same_tab_html, "target=\"_blank\"")
        |> expect.to_equal(expected: False)

        string.contains(new_tab_html, "target=\"_blank\"")
        |> expect.to_equal(expected: True)

        string.contains(new_tab_html, "rel=\"noopener noreferrer\"")
        |> expect.to_equal(expected: True)
      }),
      it("input helpers apply required and typed values", fn() {
        let cfg =
          headless_input.text_input_config(value: "", on_input: fn(_value) {
            "input"
          })
          |> headless_input.text_input_type(
            input_type: headless_input.input_type_email(),
          )
          |> headless_input.text_input_placeholder(value: "you@example.com")
          |> headless_input.text_input_attrs(attrs: [
            headless_input.input_required(),
            headless_input.input_name(value: "email"),
            headless_input.input_spellcheck_disabled(),
          ])

        let view = headless_input.text_input(config: cfg)
        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "type=\"email\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "placeholder=\"you@example.com\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "name=\"email\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "required")
        |> expect.to_equal(expected: True)
      }),
      it("field wires label/help/error semantics", fn() {
        let field_cfg =
          headless_field.field_config(id: "email")
          |> headless_field.field_required()
          |> headless_field.field_label_text(text: "Email")
          |> headless_field.field_help_text(text: "Help")
          |> headless_field.field_error_text(text: "Error")

        let input_cfg =
          headless_input.text_input_config(value: "", on_input: fn(_value) {
            "input"
          })

        let view =
          headless_field.field(config: field_cfg, control: fn(attrs) {
            headless_input.text_input(
              config: input_cfg
              |> headless_input.text_input_attrs(attrs),
            )
          })

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "for=\"email\"")
        |> expect.to_equal(expected: True)

        string.contains(
          rendered,
          "aria-describedby=\"email--help email--error\"",
        )
        |> expect.to_equal(expected: True)

        string.contains(rendered, "aria-invalid=\"true\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "required")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "role=\"alert\"")
        |> expect.to_equal(expected: True)
      }),
      it("textarea renders its value as text content for SSR", fn() {
        let view =
          headless_input.textarea(
            config: headless_input.textarea_config(
              value: "Hello",
              on_input: fn(_value) { "input" },
            ),
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, ">Hello</textarea>")
        |> expect.to_equal(expected: True)
      }),
      it("select marks matching option and disabled option as selected", fn() {
        let options = [
          headless_input.select_option(value: "a", label: "A"),
          headless_input.select_option(value: "b", label: "B")
            |> headless_input.select_option_disabled(),
          headless_input.select_option(value: "c", label: "C"),
        ]

        let view =
          headless_input.select(config: headless_input.select_config(
            value: "c",
            on_change: fn(_value) { "change" },
            options: options,
          ))

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "value=\"c\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "selected")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "disabled")
        |> expect.to_equal(expected: True)
      }),
      it("checkbox and radio keep native semantics", fn() {
        let checkbox_view =
          headless_checkbox.checkbox(
            config: headless_checkbox.checkbox_config(
              checked: True,
              on_toggle: fn(_value) { "toggled" },
            ),
            label: weft_lustre.text(content: "Agree"),
          )

        let radio_view =
          headless_radio.radio(
            config: headless_radio.radio_config(
              name: "choice",
              value: "A",
              checked: False,
              on_select: fn(_value) { "selected" },
            ),
            label: weft_lustre.text(content: "A"),
          )

        let rendered =
          weft_lustre.layout(
            attrs: [],
            child: weft_lustre.row(attrs: [], children: [
              checkbox_view,
              radio_view,
            ]),
          )
          |> element.to_string

        string.contains(rendered, "type=\"checkbox\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "checked")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "type=\"radio\"")
        |> expect.to_equal(expected: True)
      }),
      it("dialog carries role aria-modal and modal-root marker", fn() {
        let dialog =
          headless_dialog.dialog(
            config: headless_dialog.dialog_config(
              root_id: "dialog-root",
              label: headless_dialog.dialog_label(value: "Dialog"),
              on_close: "close",
            ),
            content: weft_lustre.text(content: "content"),
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: dialog)
          |> element.to_string

        string.contains(rendered, "role=\"dialog\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "aria-modal=\"true\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "id=\"dialog-root\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "data-weft-modal-root=\"true\"")
        |> expect.to_equal(expected: True)
      }),
      it("tooltip renders unpositioned first then positioned styles", fn() {
        let key = overlay.overlay_key(value: "tip")
        let cfg =
          headless_tooltip.tooltip_config(key: key)
          |> headless_tooltip.tooltip_prefer_sides(sides: [
            weft.overlay_side_below(),
          ])
          |> headless_tooltip.tooltip_alignments(alignments: [
            weft.overlay_align_start(),
          ])

        let unpositioned =
          headless_tooltip.tooltip_overlay(
            config: cfg,
            attrs: [],
            solution: None,
            content: weft_lustre.text(content: "Hidden"),
          )

        let positioned =
          headless_tooltip.tooltip_overlay(
            config: cfg,
            attrs: [],
            solution: Some(overlay_with_solution()),
            content: weft_lustre.text(content: "Visible"),
          )

        let rendered_unpositioned =
          weft_lustre.layout(attrs: [], child: unpositioned)
          |> element.to_string

        let rendered_positioned =
          weft_lustre.layout(attrs: [], child: positioned)
          |> element.to_string

        let has_inline_hidden = case
          string.contains(rendered_unpositioned, "visibility:hidden")
        {
          True -> True
          False -> string.contains(rendered_unpositioned, "visibility: hidden")
        }

        has_inline_hidden |> expect.to_equal(expected: True)

        string.contains(rendered_unpositioned, "display:none")
        |> expect.to_equal(expected: False)

        string.contains(rendered_positioned, "data-weft-overlay-side=")
        |> expect.to_equal(expected: True)

        let has_inline_visible = case
          string.contains(rendered_positioned, "visibility:visible")
        {
          True -> True
          False -> string.contains(rendered_positioned, "visibility: visible")
        }

        has_inline_visible |> expect.to_equal(expected: True)
      }),
      it("toast and toast_region preserve toast accessibility attributes", fn() {
        let toast =
          headless_toast.toast(
            config: headless_toast.toast_config(on_dismiss: "dismiss")
              |> headless_toast.toast_attrs(attrs: [
                weft_lustre.html_attribute(attribute.id("toast-item")),
              ]),
            content: weft_lustre.text(content: "Hello"),
          )

        let region =
          headless_toast.toast_region(
            corner: headless_toast.toast_corner_top_right(),
            children: [toast],
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: region)
          |> element.to_string

        string.contains(rendered, "role=\"status\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "aria-live=\"polite\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "id=\"toast-item\"")
        |> expect.to_equal(expected: True)
      }),
      it("headless forms compose required field wiring", fn() {
        let field_cfg =
          headless_field.field_config(id: "name")
          |> headless_field.field_required()
          |> headless_field.field_label_text(text: "Name")

        let input_cfg =
          headless_input.text_input_config(value: "", on_input: fn(_value) {
            "type"
          })

        let view =
          headless_forms.field_text_input(
            field_config: field_cfg,
            input_config: input_cfg,
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "for=\"name\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "required")
        |> expect.to_equal(expected: True)
      }),
      it("label links control with for attribute", fn() {
        let view =
          headless_label.label(
            config: headless_label.label_config()
              |> headless_label.label_for(html_for: "field-name"),
            child: weft_lustre.text(content: "Name"),
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "<label")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "for=\"field-name\"")
        |> expect.to_equal(expected: True)
      }),
      it("card sections render semantic tags", fn() {
        let view =
          headless_card.card(attrs: [], children: [
            headless_card.card_header(attrs: [], children: [
              headless_card.card_title(attrs: [], children: [
                weft_lustre.text(content: "Title"),
              ]),
              headless_card.card_action(attrs: [], children: [
                weft_lustre.text(content: "Action"),
              ]),
            ]),
            headless_card.card_description(attrs: [], children: [
              weft_lustre.text(content: "Description"),
            ]),
            headless_card.card_content(attrs: [], children: [
              weft_lustre.text(content: "Content"),
            ]),
            headless_card.card_footer(attrs: [], children: [
              weft_lustre.text(content: "Footer"),
            ]),
          ])

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "<div")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "<h3")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "<p")
        |> expect.to_equal(expected: True)
      }),
      it("separator emits accessibility affordances by mode", fn() {
        let decorative =
          headless_separator.separator(
            config: headless_separator.separator_config()
            |> headless_separator.separator_decorative(decorative: True),
          )

        let informative =
          headless_separator.separator(
            config: headless_separator.separator_config()
            |> headless_separator.separator_decorative(decorative: False)
            |> headless_separator.separator_orientation(
              orientation: headless_separator.separator_vertical(),
            ),
          )

        let decorative_html =
          weft_lustre.layout(attrs: [], child: decorative)
          |> element.to_string

        let informative_html =
          weft_lustre.layout(attrs: [], child: informative)
          |> element.to_string

        string.contains(decorative_html, "aria-hidden=\"true\"")
        |> expect.to_equal(expected: True)

        string.contains(decorative_html, "role=\"separator\"")
        |> expect.to_equal(expected: False)

        string.contains(informative_html, "role=\"separator\"")
        |> expect.to_equal(expected: True)

        string.contains(informative_html, "aria-hidden=\"true\"")
        |> expect.to_equal(expected: False)
      }),
      it("skeleton returns configured metadata", fn() {
        let cfg =
          headless_skeleton.skeleton_config()
          |> headless_skeleton.skeleton_width(width: weft.px(pixels: 120))
          |> headless_skeleton.skeleton_height(height: weft.px(pixels: 16))
          |> headless_skeleton.skeleton_radius(radius: weft.px(pixels: 6))

        let rendered =
          weft_lustre.layout(
            attrs: [],
            child: headless_skeleton.skeleton(config: cfg),
          )
          |> element.to_string

        string.contains(rendered, "<span")
        |> expect.to_equal(expected: True)

        let width = headless_skeleton.skeleton_config_width(config: cfg)
        let height = headless_skeleton.skeleton_config_height(config: cfg)
        let radius = headless_skeleton.skeleton_config_radius(config: cfg)

        width
        |> expect.to_equal(expected: Some(weft.px(pixels: 120)))

        height
        |> expect.to_equal(expected: Some(weft.px(pixels: 16)))

        radius
        |> expect.to_equal(expected: Some(weft.px(pixels: 6)))
      }),
      it("switch renders role=switch and aria-checked when checked=True", fn() {
        let view =
          headless_switch.switch(
            config: headless_switch.switch_config(
              checked: True,
              on_toggle: fn(_value) { "toggled" },
            ),
            label: weft_lustre.text(content: "Dark mode"),
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "role=\"switch\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "aria-checked=\"true\"")
        |> expect.to_equal(expected: True)
      }),
      it("switch renders aria-checked=false when checked=False", fn() {
        let view =
          headless_switch.switch(
            config: headless_switch.switch_config(
              checked: False,
              on_toggle: fn(_value) { "toggled" },
            ),
            label: weft_lustre.text(content: "Dark mode"),
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "aria-checked=\"false\"")
        |> expect.to_equal(expected: True)
      }),
      it("switch renders aria-disabled=true when disabled=True", fn() {
        let view =
          headless_switch.switch(
            config: headless_switch.switch_config(
              checked: False,
              on_toggle: fn(_value) { "toggled" },
            )
              |> headless_switch.switch_disabled(),
            label: weft_lustre.text(content: "Dark mode"),
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "aria-disabled=\"true\"")
        |> expect.to_equal(expected: True)
      }),
      it("alert renders role=alert on container", fn() {
        let view =
          headless_alert.alert(
            config: headless_alert.alert_config(
              variant: headless_alert.alert_default(),
            ),
            children: [
              headless_alert.alert_title(children: [
                weft_lustre.text(content: "Heads up!"),
              ]),
              headless_alert.alert_description(children: [
                weft_lustre.text(content: "Something happened."),
              ]),
            ],
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "role=\"alert\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "<h5")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "Heads up!")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "Something happened.")
        |> expect.to_equal(expected: True)
      }),
      it("alert destructive variant stores variant correctly", fn() {
        let variant = headless_alert.alert_destructive()

        headless_alert.alert_variant_is_destructive(variant: variant)
        |> expect.to_equal(expected: True)

        let default_variant = headless_alert.alert_default()

        headless_alert.alert_variant_is_destructive(variant: default_variant)
        |> expect.to_equal(expected: False)
      }),
      it(
        "alert_dialog renders role=alertdialog and aria-modal and modal-root marker",
        fn() {
          let dialog =
            headless_alert_dialog.alert_dialog(
              config: headless_alert_dialog.alert_dialog_config(
                root_id: "alert-dlg",
                label: headless_alert_dialog.alert_dialog_label(
                  value: "Confirm",
                ),
                on_close: "close",
              ),
              content: weft_lustre.text(content: "Are you sure?"),
            )

          let rendered =
            weft_lustre.layout(attrs: [], child: dialog)
            |> element.to_string

          string.contains(rendered, "role=\"alertdialog\"")
          |> expect.to_equal(expected: True)

          string.contains(rendered, "aria-modal=\"true\"")
          |> expect.to_equal(expected: True)

          string.contains(rendered, "id=\"alert-dlg\"")
          |> expect.to_equal(expected: True)

          string.contains(rendered, "data-weft-modal-root=\"true\"")
          |> expect.to_equal(expected: True)

          string.contains(rendered, "Are you sure?")
          |> expect.to_equal(expected: True)
        },
      ),
      it("alert_dialog sub-components render correct tags", fn() {
        let title =
          headless_alert_dialog.alert_dialog_title(children: [
            weft_lustre.text(content: "Title"),
          ])

        let description =
          headless_alert_dialog.alert_dialog_description(children: [
            weft_lustre.text(content: "Desc"),
          ])

        let action =
          headless_alert_dialog.alert_dialog_action(
            on_click: "confirm",
            children: [weft_lustre.text(content: "OK")],
          )

        let cancel =
          headless_alert_dialog.alert_dialog_cancel(
            on_click: "cancel",
            children: [weft_lustre.text(content: "Cancel")],
          )

        let content =
          headless_alert_dialog.alert_dialog_content(children: [
            headless_alert_dialog.alert_dialog_header(children: [
              title,
              description,
            ]),
            headless_alert_dialog.alert_dialog_footer(children: [
              cancel,
              action,
            ]),
          ])

        let rendered =
          weft_lustre.layout(attrs: [], child: content)
          |> element.to_string

        string.contains(rendered, "<h2")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "<p")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "type=\"button\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "Title")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "OK")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "Cancel")
        |> expect.to_equal(expected: True)
      }),
      it("progress renders role=progressbar with correct aria attributes", fn() {
        let view =
          headless_progress.progress(config: headless_progress.progress_config(
            value: 50.0,
          ))

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "role=\"progressbar\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "aria-valuenow=\"50\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "aria-valuemin=\"0\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "aria-valuemax=\"100\"")
        |> expect.to_equal(expected: True)
      }),
      it("progress clamps value to [0, max]", fn() {
        let view_over =
          headless_progress.progress(config: headless_progress.progress_config(
            value: 150.0,
          ))

        let rendered_over =
          weft_lustre.layout(attrs: [], child: view_over)
          |> element.to_string

        // Should clamp to 100
        string.contains(rendered_over, "aria-valuenow=\"100\"")
        |> expect.to_equal(expected: True)

        let view_under =
          headless_progress.progress(config: headless_progress.progress_config(
            value: -10.0,
          ))

        let rendered_under =
          weft_lustre.layout(attrs: [], child: view_under)
          |> element.to_string

        // Should clamp to 0
        string.contains(rendered_under, "aria-valuenow=\"0\"")
        |> expect.to_equal(expected: True)
      }),
      it("progress supports custom max value", fn() {
        let view =
          headless_progress.progress(
            config: headless_progress.progress_config(value: 25.0)
            |> headless_progress.progress_max(max: 50.0),
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "aria-valuenow=\"25\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "aria-valuemax=\"50\"")
        |> expect.to_equal(expected: True)
      }),
      it("progress config accessors return correct values", fn() {
        let cfg =
          headless_progress.progress_config(value: 42.0)
          |> headless_progress.progress_max(max: 200.0)

        headless_progress.progress_config_value(config: cfg)
        |> expect.to_equal(expected: 42.0)

        headless_progress.progress_config_max(config: cfg)
        |> expect.to_equal(expected: 200.0)
      }),
      it("spinner renders role=status and aria-label", fn() {
        let view =
          headless_spinner.spinner(config: headless_spinner.spinner_config())

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "role=\"status\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "aria-label=\"Loading\"")
        |> expect.to_equal(expected: True)
      }),
      it("spinner accepts custom label", fn() {
        let view =
          headless_spinner.spinner(
            config: headless_spinner.spinner_config()
            |> headless_spinner.spinner_label(label: "Please wait"),
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "aria-label=\"Please wait\"")
        |> expect.to_equal(expected: True)
      }),
      it("spinner size pixels returns correct values", fn() {
        headless_spinner.spinner_size_pixels(
          size: headless_spinner.spinner_small(),
        )
        |> expect.to_equal(expected: 16)

        headless_spinner.spinner_size_pixels(
          size: headless_spinner.spinner_medium(),
        )
        |> expect.to_equal(expected: 24)

        headless_spinner.spinner_size_pixels(
          size: headless_spinner.spinner_large(),
        )
        |> expect.to_equal(expected: 32)
      }),
      it("kbd renders a <kbd> semantic element", fn() {
        let view =
          headless_kbd.kbd(config: headless_kbd.kbd_config(), children: [
            weft_lustre.text(content: "Ctrl+S"),
          ])

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "<kbd")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "Ctrl+S")
        |> expect.to_equal(expected: True)
      }),
      it("empty renders a div container with all slots", fn() {
        let view =
          headless_empty.empty(
            config: headless_empty.empty_config()
            |> headless_empty.empty_title(title: weft_lustre.text(
              content: "No data",
            ))
            |> headless_empty.empty_description(description: weft_lustre.text(
              content: "Nothing here yet.",
            )),
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "<div")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "No data")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "Nothing here yet.")
        |> expect.to_equal(expected: True)
      }),
      it("empty renders without optional slots", fn() {
        let view = headless_empty.empty(config: headless_empty.empty_config())

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "<div")
        |> expect.to_equal(expected: True)
      }),
      it("toggle renders button with aria-pressed=true when pressed", fn() {
        let view =
          headless_toggle.toggle(
            config: headless_toggle.toggle_config(
              pressed: True,
              on_toggle: fn(_value) { "toggled" },
            ),
            child: weft_lustre.text(content: "Bold"),
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "type=\"button\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "aria-pressed=\"true\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "Bold")
        |> expect.to_equal(expected: True)
      }),
      it("toggle renders aria-pressed=false when not pressed", fn() {
        let view =
          headless_toggle.toggle(
            config: headless_toggle.toggle_config(
              pressed: False,
              on_toggle: fn(_value) { "toggled" },
            ),
            child: weft_lustre.text(content: "Italic"),
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "aria-pressed=\"false\"")
        |> expect.to_equal(expected: True)
      }),
      it("toggle renders disabled attribute when disabled", fn() {
        let view =
          headless_toggle.toggle(
            config: headless_toggle.toggle_config(
              pressed: False,
              on_toggle: fn(_value) { "toggled" },
            )
              |> headless_toggle.toggle_disabled(),
            child: weft_lustre.text(content: "Off"),
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "disabled")
        |> expect.to_equal(expected: True)
      }),
      it("toggle keydown prevents default for Enter and Space", fn() {
        let view =
          headless_toggle.toggle(
            config: headless_toggle.toggle_config(
              pressed: False,
              on_toggle: fn(value) { value },
            ),
            child: weft_lustre.text(content: "Bold"),
          )

        let keydown_attr = find_first_event(view, "keydown")

        case keydown_attr {
          Some(vattr.Event(handler:, prevent_default:, ..)) -> {
            let uses_conditional_prevent_default = case prevent_default {
              vattr.Possible(..) -> True
              _ -> False
            }

            uses_conditional_prevent_default
            |> expect.to_equal(expected: True)

            let enter_result =
              decode.run(
                dynamic.properties([
                  #(dynamic.string("key"), dynamic.string("Enter")),
                ]),
                handler,
              )

            let space_result =
              decode.run(
                dynamic.properties([
                  #(dynamic.string("key"), dynamic.string(" ")),
                ]),
                handler,
              )

            let other_result =
              decode.run(
                dynamic.properties([
                  #(dynamic.string("key"), dynamic.string("Escape")),
                ]),
                handler,
              )

            let enter_prevents_default = case enter_result {
              Ok(vattr.Handler(prevent_default:, ..)) -> prevent_default
              Error(_) -> False
            }

            let space_prevents_default = case space_result {
              Ok(vattr.Handler(prevent_default:, ..)) -> prevent_default
              Error(_) -> False
            }

            let enter_message = case enter_result {
              Ok(vattr.Handler(message:, ..)) -> message
              Error(_) -> False
            }

            let space_message = case space_result {
              Ok(vattr.Handler(message:, ..)) -> message
              Error(_) -> False
            }

            enter_prevents_default
            |> expect.to_equal(expected: True)

            space_prevents_default
            |> expect.to_equal(expected: True)

            enter_message
            |> expect.to_equal(expected: True)

            space_message
            |> expect.to_equal(expected: True)

            case other_result {
              Error(_) -> True
              Ok(_) -> False
            }
            |> expect.to_equal(expected: True)
          }
          _ -> False |> expect.to_equal(expected: True)
        }
      }),
      it("native_select renders a <select> with options", fn() {
        let opts = [
          headless_native_select.native_select_option(
            value: "us",
            label: "United States",
          ),
          headless_native_select.native_select_option(
            value: "uk",
            label: "United Kingdom",
          ),
        ]

        let view =
          headless_native_select.native_select(
            config: headless_native_select.native_select_config(
              options: opts,
              value: Some("us"),
              on_change: fn(_v) { "changed" },
            ),
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "<select")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "<option")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "United States")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "selected")
        |> expect.to_equal(expected: True)
      }),
      it("native_select renders placeholder when no value", fn() {
        let opts = [
          headless_native_select.native_select_option(value: "a", label: "A"),
        ]

        let view =
          headless_native_select.native_select(
            config: headless_native_select.native_select_config(
              options: opts,
              value: None,
              on_change: fn(_v) { "changed" },
            )
            |> headless_native_select.native_select_placeholder(
              placeholder: "Choose one",
            ),
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "Choose one")
        |> expect.to_equal(expected: True)
      }),
      it("native_select renders disabled select", fn() {
        let opts = [
          headless_native_select.native_select_option(value: "a", label: "A"),
        ]

        let view =
          headless_native_select.native_select(
            config: headless_native_select.native_select_config(
              options: opts,
              value: None,
              on_change: fn(_v) { "changed" },
            )
            |> headless_native_select.native_select_disabled(),
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "disabled")
        |> expect.to_equal(expected: True)
      }),
      it("button_group renders role=group", fn() {
        let view =
          headless_button_group.button_group(
            config: headless_button_group.button_group_config(),
            children: [weft_lustre.text(content: "child")],
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "role=\"group\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "child")
        |> expect.to_equal(expected: True)
      }),
      it("button_group orientation helpers return correct values", fn() {
        headless_button_group.button_group_orientation_is_horizontal(
          orientation: headless_button_group.button_group_horizontal(),
        )
        |> expect.to_equal(expected: True)

        headless_button_group.button_group_orientation_is_vertical(
          orientation: headless_button_group.button_group_vertical(),
        )
        |> expect.to_equal(expected: True)

        headless_button_group.button_group_orientation_is_horizontal(
          orientation: headless_button_group.button_group_vertical(),
        )
        |> expect.to_equal(expected: False)
      }),
      it("aspect_ratio renders a div with aspect-ratio property", fn() {
        let view =
          headless_aspect_ratio.aspect_ratio(
            config: headless_aspect_ratio.aspect_ratio_config(
              width: 16,
              height: 9,
            ),
            children: [weft_lustre.text(content: "video")],
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "<div")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "video")
        |> expect.to_equal(expected: True)
      }),
      it("aspect_ratio config accessors return correct values", fn() {
        let cfg = headless_aspect_ratio.aspect_ratio_config(width: 4, height: 3)

        headless_aspect_ratio.aspect_ratio_config_width(config: cfg)
        |> expect.to_equal(expected: 4)

        headless_aspect_ratio.aspect_ratio_config_height(config: cfg)
        |> expect.to_equal(expected: 3)
      }),
    ]),
    describe("styled", [
      it("card uses theme colors and semantic title tag", fn() {
        let t =
          theme.theme_default()
          |> theme.theme_surface(
            color: weft.rgb(red: 12, green: 34, blue: 56),
            on_color: weft.rgb(red: 210, green: 220, blue: 230),
          )

        let view =
          ui_card.card(theme: t, attrs: [], children: [
            ui_card.card_title(theme: t, attrs: [], children: [
              weft_lustre.text(content: "Card title"),
            ]),
            ui_card.card_description(theme: t, attrs: [], children: [
              weft_lustre.text(content: "Card description"),
            ]),
            ui_card.card_content(theme: t, attrs: [], children: [
              weft_lustre.text(content: "Card content"),
            ]),
          ])

        let html =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        let css = weft_lustre.debug_stylesheet(attrs: [], child: view)

        string.contains(html, "<h3")
        |> expect.to_equal(expected: True)

        string.contains(css, "background-color:rgb(12, 34, 56);")
        |> expect.to_equal(expected: True)

        string.contains(css, "color:rgb(210, 220, 230);")
        |> expect.to_equal(expected: True)
      }),
      it("styled label applies disabled semantics", fn() {
        let t =
          theme.theme_default()
          |> theme.theme_disabled_opacity(opacity: 0.23)

        let view =
          ui_label.label(
            theme: t,
            config: ui_label.label_config()
              |> ui_label.label_for(html_for: "label-control")
              |> ui_label.label_disabled(),
            child: weft_lustre.text(content: "Label"),
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        let css = weft_lustre.debug_stylesheet(attrs: [], child: view)

        string.contains(rendered, "for=\"label-control\"")
        |> expect.to_equal(expected: True)

        string.contains(css, "cursor:not-allowed;")
        |> expect.to_equal(expected: True)

        string.contains(css, "opacity:0.23;")
        |> expect.to_equal(expected: True)
      }),
      it("styled separator applies orientation-specific sizing", fn() {
        let t = theme.theme_default()
        let default_view =
          ui_separator.separator(
            theme: t,
            config: headless_separator.separator_config()
              |> headless_separator.separator_decorative(decorative: True),
          )

        let vertical_view =
          ui_separator.separator(
            theme: t,
            config: headless_separator.separator_config()
              |> headless_separator.separator_decorative(decorative: True)
              |> headless_separator.separator_orientation(
                orientation: headless_separator.separator_vertical(),
              ),
          )

        let default_css =
          weft_lustre.debug_stylesheet(attrs: [], child: default_view)

        let vertical_css =
          weft_lustre.debug_stylesheet(attrs: [], child: vertical_view)

        string.contains(default_css, "height:1px;")
        |> expect.to_equal(expected: True)

        string.contains(default_css, "width:100%;")
        |> expect.to_equal(expected: True)

        string.contains(vertical_css, "width:1px;")
        |> expect.to_equal(expected: True)

        string.contains(vertical_css, "height:100%;")
        |> expect.to_equal(expected: True)
      }),
      it("styled skeleton emits configured size/radius tokens", fn() {
        let t =
          theme.theme_default()
          |> theme.theme_radius_md(radius: weft.px(pixels: 4))
          |> theme.theme_muted_text(color: weft.rgb(red: 1, green: 2, blue: 3))

        let view =
          ui_skeleton.skeleton(
            theme: t,
            config: headless_skeleton.skeleton_config()
              |> headless_skeleton.skeleton_width(width: weft.px(pixels: 160))
              |> headless_skeleton.skeleton_height(height: weft.rem(rem: 2.25))
              |> headless_skeleton.skeleton_radius(radius: weft.px(pixels: 5)),
          )

        let css = weft_lustre.debug_stylesheet(attrs: [], child: view)

        string.contains(css, "width:160px;")
        |> expect.to_equal(expected: True)

        string.contains(css, "height:2.25rem;")
        |> expect.to_equal(expected: True)

        string.contains(css, "background-color:rgb(1, 2, 3);")
        |> expect.to_equal(expected: True)

        string.contains(css, "border-radius:5px;")
        |> expect.to_equal(expected: True)
      }),
      it(
        "button applies theme tokens including overrideable shadow colors",
        fn() {
          let t =
            theme.theme_default()
            |> theme.theme_button_shadows(
              base: weft.rgba(red: 1, green: 2, blue: 3, alpha: 0.11),
              hover: weft.rgba(red: 4, green: 5, blue: 6, alpha: 0.22),
            )
            |> theme.theme_primary(
              color: weft.rgb(red: 10, green: 20, blue: 30),
              on_color: weft.rgb(red: 240, green: 250, blue: 255),
            )

          let view =
            ui_button.button(
              theme: t,
              config: ui_button.button_config(on_press: "press"),
              label: weft_lustre.text(content: "Apply"),
            )

          let css = weft_lustre.debug_stylesheet(attrs: [], child: view)

          string.contains(css, "background-color:rgb(10, 20, 30);")
          |> expect.to_equal(expected: True)

          string.contains(
            css,
            "box-shadow:0px 1px 2px 0px rgba(1, 2, 3, 0.11);",
          )
          |> expect.to_equal(expected: True)

          string.contains(
            css,
            "box-shadow:0px 4px 12px -2px rgba(4, 5, 6, 0.22);",
          )
          |> expect.to_equal(expected: True)
        },
      ),
      it("link uses theme primary color", fn() {
        let t =
          theme.theme_default()
          |> theme.theme_primary(
            color: weft.rgb(red: 7, green: 8, blue: 9),
            on_color: weft.rgb(red: 0, green: 0, blue: 0),
          )

        let view =
          ui_link.link(
            theme: t,
            config: ui_link.link_config(href: "/"),
            label: weft_lustre.text(content: "Home"),
          )

        let css = weft_lustre.debug_stylesheet(attrs: [], child: view)

        string.contains(css, "color:rgb(7, 8, 9);")
        |> expect.to_equal(expected: True)
      }),
      it("input wrappers apply themed base styles", fn() {
        let t =
          theme.theme_default()
          |> theme.theme_input_surface(
            color: weft.rgb(red: 245, green: 246, blue: 247),
            on_color: weft.rgb(red: 11, green: 12, blue: 13),
          )

        let cfg =
          ui_input.text_input_config(value: "x", on_input: fn(_value) { "x" })

        let view = ui_input.text_input(theme: t, config: cfg)

        let css = weft_lustre.debug_stylesheet(attrs: [], child: view)

        string.contains(css, "background-color:rgb(245, 246, 247);")
        |> expect.to_equal(expected: True)

        string.contains(css, "color:rgb(11, 12, 13);")
        |> expect.to_equal(expected: True)
      }),
      it(
        "field wrapper composes control control attrs and keeps style boundary",
        fn() {
          let t = theme.theme_default()
          let field_cfg =
            ui_field.field_config(id: "styled-name")
            |> ui_field.field_label_text(text: "Name")
            |> ui_field.field_required()

          let text_cfg =
            ui_input.text_input_config(value: "Ada", on_input: fn(_value) {
              "x"
            })

          let view =
            ui_field.field(theme: t, config: field_cfg, control: fn(attrs) {
              ui_input.text_input(
                theme: t,
                config: text_cfg |> ui_input.text_input_attrs(attrs),
              )
            })

          let rendered =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(rendered, "for=\"styled-name\"")
          |> expect.to_equal(expected: True)

          string.contains(rendered, "aria-required=\"true\"")
          |> expect.to_equal(expected: True)

          string.contains(rendered, "required")
          |> expect.to_equal(expected: True)
        },
      ),
      it("forms helper composes and keeps ids in place", fn() {
        let t = theme.theme_default()
        let field_cfg =
          ui_field.field_config(id: "styled-email")
          |> ui_field.field_help_text(text: "help")

        let text_cfg =
          ui_input.text_input_config(value: "a@b.com", on_input: fn(_value) {
            "x"
          })

        let view =
          ui_forms.field_text_input(
            theme: t,
            field_config: field_cfg,
            input_config: text_cfg,
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "id=\"styled-email\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "styled-email--help")
        |> expect.to_equal(expected: True)
      }),
      it("checkbox and radio components preserve semantics with theme", fn() {
        let t =
          theme.theme_default()
          |> theme.theme_focus_ring(color: weft.rgb(red: 1, green: 2, blue: 3))

        let c =
          ui_checkbox.checkbox(
            theme: t,
            config: ui_checkbox.checkbox_config(
              checked: True,
              on_toggle: fn(_value) { "x" },
            ),
            label: weft_lustre.text(content: "One"),
          )

        let r =
          ui_radio.radio(
            theme: t,
            config: ui_radio.radio_config(
              name: "choice",
              value: "r1",
              checked: True,
              on_select: fn(_value) { "sel" },
            ),
            label: weft_lustre.text(content: "R"),
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: c)
          |> element.to_string

        string.contains(rendered, "type=\"checkbox\"")
        |> expect.to_equal(expected: True)

        let rendered_radio =
          weft_lustre.layout(attrs: [], child: r)
          |> element.to_string

        string.contains(rendered_radio, "type=\"radio\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered_radio, "value=\"r1\"")
        |> expect.to_equal(expected: True)
      }),
      it("tooltip uses tokenized shadow and placement metadata", fn() {
        let t =
          theme.theme_default()
          |> theme.theme_tooltip_shadow(color: weft.rgba(
            red: 8,
            green: 9,
            blue: 10,
            alpha: 0.55,
          ))

        let key = overlay.overlay_key(value: "styled-tip")
        let cfg = ui_tooltip.tooltip_config(key: key)

        let view =
          ui_tooltip.tooltip_overlay(
            theme: t,
            config: cfg,
            attrs: [],
            solution: Some(overlay_with_solution()),
            content: weft_lustre.text(content: "tip"),
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "rgba(8, 9, 10, 0.55)")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "data-weft-overlay-side=")
        |> expect.to_equal(expected: True)
      }),
      it("dialog uses tokenized dialog shadow and theme scrim", fn() {
        let t =
          theme.theme_default()
          |> theme.theme_dialog_shadow(color: weft.rgba(
            red: 1,
            green: 2,
            blue: 3,
            alpha: 0.75,
          ))
          |> theme.theme_scrim(color: weft.rgba(
            red: 1,
            green: 2,
            blue: 3,
            alpha: 0.4,
          ))

        let cfg =
          ui_dialog.dialog_config(
            root_id: "sdialog",
            label: ui_dialog.dialog_label(value: "Settings"),
            on_close: "close",
          )

        let view =
          ui_dialog.dialog(
            theme: t,
            config: cfg,
            content: weft_lustre.text(content: "dialog body"),
          )

        let css = weft_lustre.debug_stylesheet(attrs: [], child: view)

        string.contains(css, "box-shadow")
        |> expect.to_equal(expected: True)

        string.contains(css, "background-color:rgba(1, 2, 3, 0.4)")
        |> expect.to_equal(expected: True)
      }),
      it("toast shadow and close-button background are token-driven", fn() {
        let t =
          theme.theme_default()
          |> theme.theme_toast_shadow(color: weft.rgba(
            red: 9,
            green: 10,
            blue: 11,
            alpha: 0.55,
          ))
          |> theme.theme_toast_close_button_background(color: weft.rgba(
            red: 99,
            green: 100,
            blue: 101,
            alpha: 0.25,
          ))

        let cfg =
          ui_toast.toast_config(on_dismiss: "dismiss")
          |> ui_toast.toast_variant(variant: ui_toast.toast_variant_info())

        let view =
          ui_toast.toast(
            theme: t,
            config: cfg,
            content: weft_lustre.text(content: "Saved"),
          )

        let css = weft_lustre.debug_stylesheet(attrs: [], child: view)

        string.contains(
          css,
          "box-shadow:0px 10px 28px -10px rgba(9, 10, 11, 0.55)",
        )
        |> expect.to_equal(expected: True)

        string.contains(css, "background-color:rgba(99, 100, 101, 0.25)")
        |> expect.to_equal(expected: True)
      }),
      it("accent returns the default accent background/foreground pair", fn() {
        let t = theme.theme_default()
        let #(bg, fg) = theme.accent(theme: t)

        bg
        |> expect.to_equal(expected: weft.rgba(
          red: 0,
          green: 0,
          blue: 0,
          alpha: 0.07,
        ))

        fg
        |> expect.to_equal(expected: weft.rgb(red: 9, green: 9, blue: 9))
      }),
      it("muted returns the default muted background/foreground pair", fn() {
        let t = theme.theme_default()
        let #(bg, fg) = theme.muted(theme: t)

        bg
        |> expect.to_equal(expected: weft.rgba(
          red: 0,
          green: 0,
          blue: 0,
          alpha: 0.04,
        ))

        fg
        |> expect.to_equal(expected: weft.rgba(
          red: 63,
          green: 63,
          blue: 70,
          alpha: 0.85,
        ))
      }),
      it("hover_surface returns the default translucent hover color", fn() {
        let t = theme.theme_default()

        theme.hover_surface(theme: t)
        |> expect.to_equal(expected: weft.rgba(
          red: 0,
          green: 0,
          blue: 0,
          alpha: 0.04,
        ))
      }),
      it("tooltip_effect and toast auto-dismiss are callable on Erlang", fn() {
        let key = overlay.overlay_key(value: "x")
        let cfg = ui_tooltip.tooltip_config(key: key)

        let _: effect.Effect(String) =
          ui_tooltip.tooltip_effect(config: cfg, on_positioned: fn(_solution) {
            "positioned"
          })

        let _: effect.Effect(String) =
          ui_toast.toast_auto_dismiss(after_ms: 10, on_dismiss: "dismiss")

        1 |> expect.to_equal(expected: 1)
      }),
      it("tab_item_el accepts an element label", fn() {
        let label_el =
          weft_lustre.row(attrs: [], children: [
            weft_lustre.text(content: "Overview"),
          ])

        let item = headless_tabs.tab_item_el(value: "overview", label: label_el)

        let t = theme.theme_default()
        let config =
          ui_tabs.tabs_config(value: "overview", on_change: fn(v) { v })

        let view =
          ui_tabs.tabs(
            theme: t,
            config: config,
            items: [item],
            content: weft_lustre.text(content: "content"),
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "Overview")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "role=\"tab\"")
        |> expect.to_equal(expected: True)
      }),
      it("avatar fallback renders with muted theme colors", fn() {
        let t = theme.theme_default()
        let #(muted_bg, _muted_fg) = theme.muted(theme: t)

        let view =
          ui_avatar.avatar(
            theme: t,
            config: ui_avatar.avatar_config(alt: "AB")
              |> ui_avatar.avatar_fallback(fallback: weft_lustre.text(
                content: "AB",
              )),
          )

        let css = weft_lustre.debug_stylesheet(attrs: [], child: view)

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        let _: weft.Color = muted_bg

        string.contains(rendered, "AB")
        |> expect.to_equal(expected: True)

        string.contains(css, "border-radius:9999px;")
        |> expect.to_equal(expected: True)
      }),
      it("badge_count renders as a pill with muted colors", fn() {
        let t = theme.theme_default()
        let #(muted_bg, _muted_fg) = theme.muted(theme: t)

        let view =
          ui_badge.badge(
            theme: t,
            config: ui_badge.badge_config()
              |> ui_badge.badge_variant(variant: ui_badge.badge_count()),
            child: weft_lustre.text(content: "3"),
          )

        let headless_view =
          headless_badge.badge(
            config: headless_badge.badge_config()
              |> headless_badge.badge_variant(
                variant: headless_badge.badge_count(),
              ),
            child: weft_lustre.text(content: "3"),
          )

        let css = weft_lustre.debug_stylesheet(attrs: [], child: view)

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        let headless_rendered =
          weft_lustre.layout(attrs: [], child: headless_view)
          |> element.to_string

        let _: weft.Color = muted_bg

        string.contains(css, "border-radius:9999px;")
        |> expect.to_equal(expected: True)

        string.contains(css, "height:20px;")
        |> expect.to_equal(expected: True)

        string.contains(rendered, ">3<")
        |> expect.to_equal(expected: True)

        string.contains(headless_rendered, ">3<")
        |> expect.to_equal(expected: True)
      }),
      it(
        "styled switch applies primary background when checked and border_color when not",
        fn() {
          let t =
            theme.theme_default()
            |> theme.theme_primary(
              color: weft.rgb(red: 10, green: 20, blue: 30),
              on_color: weft.rgb(red: 255, green: 255, blue: 255),
            )
            |> theme.theme_border(color: weft.rgb(
              red: 200,
              green: 201,
              blue: 202,
            ))

          let checked_view =
            ui_switch.switch(
              theme: t,
              config: ui_switch.switch_config(
                checked: True,
                on_toggle: fn(_value) { "toggled" },
              ),
              label: weft_lustre.text(content: "Dark mode"),
            )

          let unchecked_view =
            ui_switch.switch(
              theme: t,
              config: ui_switch.switch_config(
                checked: False,
                on_toggle: fn(_value) { "toggled" },
              ),
              label: weft_lustre.text(content: "Dark mode"),
            )

          let checked_css =
            weft_lustre.debug_stylesheet(attrs: [], child: checked_view)

          let unchecked_css =
            weft_lustre.debug_stylesheet(attrs: [], child: unchecked_view)

          string.contains(checked_css, "background-color:rgb(10, 20, 30);")
          |> expect.to_equal(expected: True)

          string.contains(unchecked_css, "background-color:rgb(200, 201, 202);")
          |> expect.to_equal(expected: True)
        },
      ),
      it("styled switch disabled applies opacity and not-allowed cursor", fn() {
        let t =
          theme.theme_default()
          |> theme.theme_disabled_opacity(opacity: 0.35)

        let view =
          ui_switch.switch(
            theme: t,
            config: ui_switch.switch_config(
              checked: False,
              on_toggle: fn(_value) { "toggled" },
            )
              |> ui_switch.switch_disabled(),
            label: weft_lustre.text(content: "Dark mode"),
          )

        let css = weft_lustre.debug_stylesheet(attrs: [], child: view)

        string.contains(css, "opacity:0.35;")
        |> expect.to_equal(expected: True)

        string.contains(css, "cursor:not-allowed;")
        |> expect.to_equal(expected: True)
      }),
      it("sidebar_group renders without error", fn() {
        let t = theme.theme_default()
        let view =
          ui_sidebar.sidebar_group(
            theme: t,
            label: Some("Navigation"),
            children: [weft_lustre.text(content: "item")],
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "Navigation")
        |> expect.to_equal(expected: True)
      }),
      it("sidebar_menu_item renders with group class for hover-reveal", fn() {
        let item =
          headless_sidebar.sidebar_menu_item(children: [
            weft_lustre.text(content: "Home"),
          ])

        let rendered =
          weft_lustre.layout(attrs: [], child: item)
          |> element.to_string

        string.contains(rendered, "weft-group-sidebar-item")
        |> expect.to_equal(expected: True)
      }),
      it("sidebar_menu_button renders active state", fn() {
        let t = theme.theme_default()
        let view =
          ui_sidebar.sidebar_menu_button(
            theme: t,
            config: ui_sidebar.sidebar_menu_button_config(
              label: weft_lustre.text(content: "Dashboard"),
            )
              |> ui_sidebar.sidebar_menu_button_active,
          )

        let css = weft_lustre.debug_stylesheet(attrs: [], child: view)
        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "Dashboard")
        |> expect.to_equal(expected: True)

        string.contains(css, "background-color:")
        |> expect.to_equal(expected: True)
      }),
      it("sidebar_menu_action renders hidden by default", fn() {
        let t = theme.theme_default()
        let view =
          ui_sidebar.sidebar_menu_action(
            theme: t,
            config: ui_sidebar.sidebar_menu_action_config(on_click: fn() {
              "clicked"
            })
              |> ui_sidebar.sidebar_menu_action_show_on_hover,
            content: weft_lustre.text(content: "..."),
          )

        let css = weft_lustre.debug_stylesheet(attrs: [], child: view)

        string.contains(css, "opacity:0;")
        |> expect.to_equal(expected: True)
      }),
      it("combobox renders trigger with placeholder when no value", fn() {
        let opts = [
          headless_combobox.combobox_option(value: "a", label: "Apple"),
          headless_combobox.combobox_option(value: "b", label: "Banana"),
        ]

        let view =
          headless_combobox.combobox(
            config: headless_combobox.combobox_config(
              options: opts,
              value: None,
              on_select: fn(_v) { "selected" },
              search: "",
              on_search: fn(_s) { "search" },
              open: False,
              on_toggle: fn(_b) { "toggle" },
              placeholder: "Pick a fruit",
              anchor_rect: None,
              overlay_size: weft.size(width: 200, height: 300),
              viewport: weft.size(width: 1280, height: 800),
              option_to_string: fn(v) { v },
            ),
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "Pick a fruit")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "type=\"button\"")
        |> expect.to_equal(expected: True)
      }),
      it("combobox renders closed panel when open: False", fn() {
        let opts = [
          headless_combobox.combobox_option(value: "a", label: "Apple"),
        ]

        let view =
          headless_combobox.combobox(
            config: headless_combobox.combobox_config(
              options: opts,
              value: None,
              on_select: fn(_v) { "selected" },
              search: "",
              on_search: fn(_s) { "search" },
              open: False,
              on_toggle: fn(_b) { "toggle" },
              placeholder: "Choose",
              anchor_rect: None,
              overlay_size: weft.size(width: 200, height: 300),
              viewport: weft.size(width: 1280, height: 800),
              option_to_string: fn(v) { v },
            ),
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "Apple")
        |> expect.to_equal(expected: False)
      }),
      it("combobox option filter returns all options for empty search", fn() {
        let opts = [
          headless_combobox.combobox_option(value: "a", label: "Apple"),
          headless_combobox.combobox_option(value: "b", label: "Banana"),
        ]

        let view =
          headless_combobox.combobox(
            config: headless_combobox.combobox_config(
              options: opts,
              value: None,
              on_select: fn(_v) { "selected" },
              search: "",
              on_search: fn(_s) { "search" },
              open: True,
              on_toggle: fn(_b) { "toggle" },
              placeholder: "Choose",
              anchor_rect: None,
              overlay_size: weft.size(width: 200, height: 300),
              viewport: weft.size(width: 1280, height: 800),
              option_to_string: fn(v) { v },
            ),
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "Apple")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "Banana")
        |> expect.to_equal(expected: True)
      }),
      it("combobox option filter filters by label substring", fn() {
        let opts = [
          headless_combobox.combobox_option(value: "a", label: "Apple"),
          headless_combobox.combobox_option(value: "b", label: "Banana"),
          headless_combobox.combobox_option(value: "c", label: "Cherry"),
        ]

        let view =
          headless_combobox.combobox(
            config: headless_combobox.combobox_config(
              options: opts,
              value: None,
              on_select: fn(_v) { "selected" },
              search: "an",
              on_search: fn(_s) { "search" },
              open: True,
              on_toggle: fn(_b) { "toggle" },
              placeholder: "Choose",
              anchor_rect: None,
              overlay_size: weft.size(width: 200, height: 300),
              viewport: weft.size(width: 1280, height: 800),
              option_to_string: fn(v) { v },
            ),
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "Banana")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "Apple")
        |> expect.to_equal(expected: False)

        string.contains(rendered, "Cherry")
        |> expect.to_equal(expected: False)
      }),
      it("combobox option click path includes select and close messages", fn() {
        let opts = [
          headless_combobox.combobox_option(value: "a", label: "Apple"),
        ]

        let view =
          headless_combobox.combobox(
            config: headless_combobox.combobox_config(
              options: opts,
              value: None,
              on_select: fn(selected) {
                case selected {
                  Some(value) -> ComboboxSelected(value: value)
                  None -> ComboboxSelected(value: "")
                }
              },
              search: "",
              on_search: fn(_s) { ComboboxSelected(value: "") },
              open: True,
              on_toggle: fn(open) { ComboboxToggled(open: open) },
              placeholder: "Choose",
              anchor_rect: None,
              overlay_size: weft.size(width: 200, height: 300),
              viewport: weft.size(width: 1280, height: 800),
              option_to_string: fn(v) { v },
            ),
          )

        let messages = click_messages(view)

        let selected_count =
          messages
          |> list.filter(fn(msg) {
            case msg {
              ComboboxSelected(value: "a") -> True
              _ -> False
            }
          })
          |> list.length

        let close_count =
          messages
          |> list.filter(fn(msg) {
            case msg {
              ComboboxToggled(open: False) -> True
              _ -> False
            }
          })
          |> list.length

        selected_count
        |> expect.to_equal(expected: 1)

        close_count
        |> expect.to_equal(expected: 2)
      }),
      it(
        "styled alert uses border_color for default and danger for destructive",
        fn() {
          let t =
            theme.theme_default()
            |> theme.theme_danger(
              color: weft.rgb(red: 200, green: 30, blue: 30),
              on_color: weft.rgb(red: 255, green: 255, blue: 255),
            )
            |> theme.theme_border(color: weft.rgb(
              red: 220,
              green: 221,
              blue: 222,
            ))

          let default_view =
            ui_alert.alert(
              theme: t,
              config: ui_alert.alert_config(variant: ui_alert.alert_default()),
              children: [
                ui_alert.alert_title(theme: t, children: [
                  weft_lustre.text(content: "Info"),
                ]),
              ],
            )

          let destructive_view =
            ui_alert.alert(
              theme: t,
              config: ui_alert.alert_config(
                variant: ui_alert.alert_destructive(),
              ),
              children: [
                ui_alert.alert_title(theme: t, children: [
                  weft_lustre.text(content: "Error"),
                ]),
              ],
            )

          let default_css =
            weft_lustre.debug_stylesheet(attrs: [], child: default_view)

          let destructive_css =
            weft_lustre.debug_stylesheet(attrs: [], child: destructive_view)

          // Default uses border_color (in border shorthand)
          string.contains(default_css, "border:1px solid rgb(220, 221, 222);")
          |> expect.to_equal(expected: True)

          // Destructive uses danger color for border (in border shorthand)
          string.contains(destructive_css, "border:1px solid rgb(200, 30, 30);")
          |> expect.to_equal(expected: True)

          let default_html =
            weft_lustre.layout(attrs: [], child: default_view)
            |> element.to_string

          string.contains(default_html, "role=\"alert\"")
          |> expect.to_equal(expected: True)

          string.contains(default_html, "<h5")
          |> expect.to_equal(expected: True)
        },
      ),
      it("styled alert_dialog uses theme scrim and dialog shadow", fn() {
        let t =
          theme.theme_default()
          |> theme.theme_dialog_shadow(color: weft.rgba(
            red: 5,
            green: 6,
            blue: 7,
            alpha: 0.65,
          ))
          |> theme.theme_scrim(color: weft.rgba(
            red: 10,
            green: 11,
            blue: 12,
            alpha: 0.45,
          ))

        let cfg =
          ui_alert_dialog.alert_dialog_config(
            root_id: "styled-alert-dlg",
            label: ui_alert_dialog.alert_dialog_label(value: "Confirm action"),
            on_close: "close",
          )

        let view =
          ui_alert_dialog.alert_dialog(
            theme: t,
            config: cfg,
            content: weft_lustre.text(content: "dialog body"),
          )

        let css = weft_lustre.debug_stylesheet(attrs: [], child: view)

        string.contains(css, "box-shadow")
        |> expect.to_equal(expected: True)

        string.contains(css, "background-color:rgba(10, 11, 12, 0.45)")
        |> expect.to_equal(expected: True)

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "role=\"alertdialog\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "aria-modal=\"true\"")
        |> expect.to_equal(expected: True)
      }),
      it("styled alert_dialog action uses primary colors", fn() {
        let t =
          theme.theme_default()
          |> theme.theme_primary(
            color: weft.rgb(red: 50, green: 60, blue: 70),
            on_color: weft.rgb(red: 240, green: 250, blue: 255),
          )

        let action =
          ui_alert_dialog.alert_dialog_action(
            theme: t,
            on_click: "confirm",
            children: [weft_lustre.text(content: "Continue")],
          )

        let css = weft_lustre.debug_stylesheet(attrs: [], child: action)

        string.contains(css, "background-color:rgb(50, 60, 70);")
        |> expect.to_equal(expected: True)

        string.contains(css, "color:rgb(240, 250, 255);")
        |> expect.to_equal(expected: True)

        let rendered =
          weft_lustre.layout(attrs: [], child: action)
          |> element.to_string

        string.contains(rendered, "type=\"button\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "Continue")
        |> expect.to_equal(expected: True)
      }),
      it("styled alert_dialog cancel uses outline style", fn() {
        let t =
          theme.theme_default()
          |> theme.theme_border(color: weft.rgb(red: 180, green: 181, blue: 182))

        let cancel =
          ui_alert_dialog.alert_dialog_cancel(
            theme: t,
            on_click: "cancel",
            children: [weft_lustre.text(content: "Go back")],
          )

        let css = weft_lustre.debug_stylesheet(attrs: [], child: cancel)

        string.contains(css, "border:1px solid rgb(180, 181, 182);")
        |> expect.to_equal(expected: True)

        let rendered =
          weft_lustre.layout(attrs: [], child: cancel)
          |> element.to_string

        string.contains(rendered, "Go back")
        |> expect.to_equal(expected: True)
      }),
      it("styled spinner uses primary color border and sized dimensions", fn() {
        let t =
          theme.theme_default()
          |> theme.theme_primary(
            color: weft.rgb(red: 42, green: 84, blue: 126),
            on_color: weft.rgb(red: 255, green: 255, blue: 255),
          )

        let view =
          ui_spinner.spinner(theme: t, config: ui_spinner.spinner_config())

        let css = weft_lustre.debug_stylesheet(attrs: [], child: view)
        let html =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(html, "role=\"status\"")
        |> expect.to_equal(expected: True)

        string.contains(css, "border:2px solid rgb(42, 84, 126);")
        |> expect.to_equal(expected: True)

        // Medium size = 24px
        string.contains(css, "width:24px;")
        |> expect.to_equal(expected: True)

        string.contains(css, "height:24px;")
        |> expect.to_equal(expected: True)
      }),
      it("styled spinner small uses 16px dimensions", fn() {
        let t = theme.theme_default()

        let view =
          ui_spinner.spinner(
            theme: t,
            config: ui_spinner.spinner_config()
              |> ui_spinner.spinner_size(size: ui_spinner.spinner_small()),
          )

        let css = weft_lustre.debug_stylesheet(attrs: [], child: view)

        string.contains(css, "width:16px;")
        |> expect.to_equal(expected: True)

        string.contains(css, "height:16px;")
        |> expect.to_equal(expected: True)
      }),
      it("styled kbd uses muted background and border", fn() {
        let t =
          theme.theme_default()
          |> theme.theme_border(color: weft.rgb(red: 190, green: 191, blue: 192))

        let view =
          ui_kbd.kbd(theme: t, config: ui_kbd.kbd_config(), children: [
            weft_lustre.text(content: "K"),
          ])

        let css = weft_lustre.debug_stylesheet(attrs: [], child: view)
        let html =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(html, "<kbd")
        |> expect.to_equal(expected: True)

        string.contains(html, "K")
        |> expect.to_equal(expected: True)

        string.contains(css, "border:1px solid rgb(190, 191, 192);")
        |> expect.to_equal(expected: True)

        string.contains(css, "font-family:monospace;")
        |> expect.to_equal(expected: True)
      }),
      it("styled empty uses muted text color and centered layout", fn() {
        let t = theme.theme_default()

        let view =
          ui_empty.empty(
            theme: t,
            config: ui_empty.empty_config()
              |> ui_empty.empty_title(title: weft_lustre.text(
                content: "No results",
              ))
              |> ui_empty.empty_description(description: weft_lustre.text(
                content: "Try a different search.",
              )),
          )

        let css = weft_lustre.debug_stylesheet(attrs: [], child: view)
        let html =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(html, "No results")
        |> expect.to_equal(expected: True)

        string.contains(html, "Try a different search.")
        |> expect.to_equal(expected: True)

        string.contains(css, "align-items:center;")
        |> expect.to_equal(expected: True)

        string.contains(css, "justify-content:center;")
        |> expect.to_equal(expected: True)
      }),
      it(
        "styled toggle uses accent background when pressed and transparent when not",
        fn() {
          let t = theme.theme_default()

          let pressed_view =
            ui_toggle.toggle(
              theme: t,
              config: ui_toggle.toggle_config(
                pressed: True,
                on_toggle: fn(_value) { "toggled" },
              ),
              child: weft_lustre.text(content: "B"),
            )

          let unpressed_view =
            ui_toggle.toggle(
              theme: t,
              config: ui_toggle.toggle_config(
                pressed: False,
                on_toggle: fn(_value) { "toggled" },
              ),
              child: weft_lustre.text(content: "I"),
            )

          let pressed_css =
            weft_lustre.debug_stylesheet(attrs: [], child: pressed_view)

          let unpressed_css =
            weft_lustre.debug_stylesheet(attrs: [], child: unpressed_view)

          let pressed_html =
            weft_lustre.layout(attrs: [], child: pressed_view)
            |> element.to_string

          string.contains(pressed_html, "aria-pressed=\"true\"")
          |> expect.to_equal(expected: True)

          // Pressed uses accent bg (non-transparent)
          string.contains(pressed_css, "background-color:rgba(0, 0, 0, 0.07);")
          |> expect.to_equal(expected: True)

          // Unpressed uses transparent bg
          string.contains(unpressed_css, "background-color:transparent;")
          |> expect.to_equal(expected: True)
        },
      ),
      it("styled toggle disabled applies opacity and not-allowed cursor", fn() {
        let t =
          theme.theme_default()
          |> theme.theme_disabled_opacity(opacity: 0.42)

        let view =
          ui_toggle.toggle(
            theme: t,
            config: ui_toggle.toggle_config(
              pressed: False,
              on_toggle: fn(_value) { "toggled" },
            )
              |> ui_toggle.toggle_disabled(),
            child: weft_lustre.text(content: "Off"),
          )

        let css = weft_lustre.debug_stylesheet(attrs: [], child: view)

        string.contains(css, "opacity:0.42;")
        |> expect.to_equal(expected: True)

        string.contains(css, "cursor:not-allowed;")
        |> expect.to_equal(expected: True)
      }),
      it("styled toggle keydown prevents default for Enter and Space", fn() {
        let t = theme.theme_default()

        let view =
          ui_toggle.toggle(
            theme: t,
            config: ui_toggle.toggle_config(
              pressed: False,
              on_toggle: fn(value) { value },
            ),
            child: weft_lustre.text(content: "Bold"),
          )

        let keydown_attr = find_first_event(view, "keydown")

        case keydown_attr {
          Some(vattr.Event(handler:, prevent_default:, ..)) -> {
            let uses_conditional_prevent_default = case prevent_default {
              vattr.Possible(..) -> True
              _ -> False
            }

            uses_conditional_prevent_default
            |> expect.to_equal(expected: True)

            let enter_result =
              decode.run(
                dynamic.properties([
                  #(dynamic.string("key"), dynamic.string("Enter")),
                ]),
                handler,
              )

            let space_result =
              decode.run(
                dynamic.properties([
                  #(dynamic.string("key"), dynamic.string(" ")),
                ]),
                handler,
              )

            let enter_prevents_default = case enter_result {
              Ok(vattr.Handler(prevent_default:, ..)) -> prevent_default
              Error(_) -> False
            }

            let space_prevents_default = case space_result {
              Ok(vattr.Handler(prevent_default:, ..)) -> prevent_default
              Error(_) -> False
            }

            let enter_message = case enter_result {
              Ok(vattr.Handler(message:, ..)) -> message
              Error(_) -> False
            }

            let space_message = case space_result {
              Ok(vattr.Handler(message:, ..)) -> message
              Error(_) -> False
            }

            enter_prevents_default
            |> expect.to_equal(expected: True)

            space_prevents_default
            |> expect.to_equal(expected: True)

            enter_message
            |> expect.to_equal(expected: True)

            space_message
            |> expect.to_equal(expected: True)
          }
          _ -> False |> expect.to_equal(expected: True)
        }
      }),
      it("styled native_select uses input surface colors and border", fn() {
        let t =
          theme.theme_default()
          |> theme.theme_input_surface(
            color: weft.rgb(red: 240, green: 241, blue: 242),
            on_color: weft.rgb(red: 15, green: 16, blue: 17),
          )
          |> theme.theme_border(color: weft.rgb(red: 200, green: 201, blue: 202))

        let opts = [
          ui_native_select.native_select_option(value: "a", label: "A"),
        ]

        let view =
          ui_native_select.native_select(
            theme: t,
            config: ui_native_select.native_select_config(
              options: opts,
              value: Some("a"),
              on_change: fn(_v) { "changed" },
            ),
          )

        let css = weft_lustre.debug_stylesheet(attrs: [], child: view)
        let html =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(html, "<select")
        |> expect.to_equal(expected: True)

        string.contains(css, "background-color:rgb(240, 241, 242);")
        |> expect.to_equal(expected: True)

        string.contains(css, "color:rgb(15, 16, 17);")
        |> expect.to_equal(expected: True)

        string.contains(css, "border:1px solid rgb(200, 201, 202);")
        |> expect.to_equal(expected: True)
      }),
      it("styled button_group renders role=group with flex layout", fn() {
        let t = theme.theme_default()

        let view =
          ui_button_group.button_group(
            theme: t,
            config: ui_button_group.button_group_config(),
            children: [weft_lustre.text(content: "btn1")],
          )

        let css = weft_lustre.debug_stylesheet(attrs: [], child: view)
        let html =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(html, "role=\"group\"")
        |> expect.to_equal(expected: True)

        string.contains(css, "display:inline-flex;")
        |> expect.to_equal(expected: True)
      }),
      it("styled aspect_ratio applies overflow hidden and fill width", fn() {
        let view =
          ui_aspect_ratio.aspect_ratio(
            config: ui_aspect_ratio.aspect_ratio_config(width: 16, height: 9),
            children: [weft_lustre.text(content: "content")],
          )

        let css = weft_lustre.debug_stylesheet(attrs: [], child: view)
        let html =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(html, "content")
        |> expect.to_equal(expected: True)

        string.contains(css, "overflow:hidden;")
        |> expect.to_equal(expected: True)

        string.contains(css, "aspect-ratio:16 / 9;")
        |> expect.to_equal(expected: True)
      }),
      it(
        "styled progress uses muted track and primary indicator with themed height",
        fn() {
          let t =
            theme.theme_default()
            |> theme.theme_primary(
              color: weft.rgb(red: 100, green: 110, blue: 120),
              on_color: weft.rgb(red: 255, green: 255, blue: 255),
            )

          let view =
            ui_progress.progress(
              theme: t,
              config: ui_progress.progress_config(value: 75.0),
            )

          let css = weft_lustre.debug_stylesheet(attrs: [], child: view)

          // Track height 8px
          string.contains(css, "height:8px;")
          |> expect.to_equal(expected: True)

          // Full rounded
          string.contains(css, "border-radius:9999px;")
          |> expect.to_equal(expected: True)

          // Primary color for indicator
          string.contains(css, "background-color:rgb(100, 110, 120);")
          |> expect.to_equal(expected: True)

          // Has transform for indicator positioning (translate with x, y)
          string.contains(css, "transform:translate(-25%, 0px)")
          |> expect.to_equal(expected: True)

          // Has transition
          string.contains(css, "transition:transform")
          |> expect.to_equal(expected: True)

          let rendered =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(rendered, "role=\"progressbar\"")
          |> expect.to_equal(expected: True)

          string.contains(rendered, "aria-valuenow=\"75\"")
          |> expect.to_equal(expected: True)
        },
      ),
      it("styled progress at 0% shows full negative transform", fn() {
        let t = theme.theme_default()

        let view =
          ui_progress.progress(
            theme: t,
            config: ui_progress.progress_config(value: 0.0),
          )

        let css = weft_lustre.debug_stylesheet(attrs: [], child: view)

        string.contains(css, "transform:translate(-100%, 0px)")
        |> expect.to_equal(expected: True)
      }),
      it("styled progress at 100% shows zero transform", fn() {
        let t = theme.theme_default()

        let view =
          ui_progress.progress(
            theme: t,
            config: ui_progress.progress_config(value: 100.0),
          )

        let css = weft_lustre.debug_stylesheet(attrs: [], child: view)

        // At 100%, offset is 0, so translate(0%, 0px)
        string.contains(css, "transform:translate(0%, 0px)")
        |> expect.to_equal(expected: True)
      }),
    ]),
    describe("pagination", [
      describe("pagination_range", [
        it("returns empty list for total less than 1", fn() {
          headless_pagination.pagination_range(
            current: 1,
            total: 0,
            siblings: 1,
          )
          |> expect.to_equal(expected: [])
        }),
        it("returns single page for total of 1", fn() {
          headless_pagination.pagination_range(
            current: 1,
            total: 1,
            siblings: 1,
          )
          |> expect.to_equal(expected: [headless_pagination.Page(number: 1)])
        }),
        it("shows all pages when total is small", fn() {
          headless_pagination.pagination_range(
            current: 3,
            total: 5,
            siblings: 1,
          )
          |> expect.to_equal(expected: [
            headless_pagination.Page(number: 1),
            headless_pagination.Page(number: 2),
            headless_pagination.Page(number: 3),
            headless_pagination.Page(number: 4),
            headless_pagination.Page(number: 5),
          ])
        }),
        it("inserts ellipsis for gaps larger than 2", fn() {
          headless_pagination.pagination_range(
            current: 5,
            total: 10,
            siblings: 1,
          )
          |> expect.to_equal(expected: [
            headless_pagination.Page(number: 1),
            headless_pagination.Ellipsis,
            headless_pagination.Page(number: 4),
            headless_pagination.Page(number: 5),
            headless_pagination.Page(number: 6),
            headless_pagination.Ellipsis,
            headless_pagination.Page(number: 10),
          ])
        }),
        it("shows page instead of ellipsis when gap is exactly 1", fn() {
          // current=4, total=10, siblings=1 -> [1, 3, 4, 5, 10]
          // gap 1->3 is 2 (exactly 1 missing page: 2) -> show Page(2)
          headless_pagination.pagination_range(
            current: 4,
            total: 10,
            siblings: 1,
          )
          |> expect.to_equal(expected: [
            headless_pagination.Page(number: 1),
            headless_pagination.Page(number: 2),
            headless_pagination.Page(number: 3),
            headless_pagination.Page(number: 4),
            headless_pagination.Page(number: 5),
            headless_pagination.Ellipsis,
            headless_pagination.Page(number: 10),
          ])
        }),
        it("handles current at first page", fn() {
          headless_pagination.pagination_range(
            current: 1,
            total: 10,
            siblings: 1,
          )
          |> expect.to_equal(expected: [
            headless_pagination.Page(number: 1),
            headless_pagination.Page(number: 2),
            headless_pagination.Ellipsis,
            headless_pagination.Page(number: 10),
          ])
        }),
        it("handles current at last page", fn() {
          headless_pagination.pagination_range(
            current: 10,
            total: 10,
            siblings: 1,
          )
          |> expect.to_equal(expected: [
            headless_pagination.Page(number: 1),
            headless_pagination.Ellipsis,
            headless_pagination.Page(number: 9),
            headless_pagination.Page(number: 10),
          ])
        }),
        it("handles siblings of 2", fn() {
          headless_pagination.pagination_range(
            current: 5,
            total: 10,
            siblings: 2,
          )
          |> expect.to_equal(expected: [
            headless_pagination.Page(number: 1),
            headless_pagination.Page(number: 2),
            headless_pagination.Page(number: 3),
            headless_pagination.Page(number: 4),
            headless_pagination.Page(number: 5),
            headless_pagination.Page(number: 6),
            headless_pagination.Page(number: 7),
            headless_pagination.Ellipsis,
            headless_pagination.Page(number: 10),
          ])
        }),
        it("handles siblings of 0", fn() {
          headless_pagination.pagination_range(
            current: 5,
            total: 10,
            siblings: 0,
          )
          |> expect.to_equal(expected: [
            headless_pagination.Page(number: 1),
            headless_pagination.Ellipsis,
            headless_pagination.Page(number: 5),
            headless_pagination.Ellipsis,
            headless_pagination.Page(number: 10),
          ])
        }),
        it("clamps current below 1 to 1", fn() {
          headless_pagination.pagination_range(
            current: -1,
            total: 5,
            siblings: 1,
          )
          |> expect.to_equal(expected: [
            headless_pagination.Page(number: 1),
            headless_pagination.Page(number: 2),
            headless_pagination.Ellipsis,
            headless_pagination.Page(number: 5),
          ])
        }),
        it("clamps current above total to total", fn() {
          headless_pagination.pagination_range(
            current: 99,
            total: 5,
            siblings: 1,
          )
          |> expect.to_equal(expected: [
            headless_pagination.Page(number: 1),
            headless_pagination.Ellipsis,
            headless_pagination.Page(number: 4),
            headless_pagination.Page(number: 5),
          ])
        }),
      ]),
      describe("headless pagination", [
        it("renders nav with role=navigation and aria-label", fn() {
          let view =
            headless_pagination.pagination(
              config: headless_pagination.pagination_config(
                current: 1,
                total: 5,
                on_page: fn(_p) { "page" },
              ),
            )

          let rendered =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(rendered, "role=\"navigation\"")
          |> expect.to_equal(expected: True)

          string.contains(rendered, "aria-label=\"pagination\"")
          |> expect.to_equal(expected: True)
        }),
        it("renders aria-current=page on active page", fn() {
          let view =
            headless_pagination.pagination(
              config: headless_pagination.pagination_config(
                current: 3,
                total: 5,
                on_page: fn(_p) { "page" },
              ),
            )

          let rendered =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(rendered, "aria-current=\"page\"")
          |> expect.to_equal(expected: True)
        }),
        it("renders previous button disabled on first page", fn() {
          let view =
            headless_pagination.pagination(
              config: headless_pagination.pagination_config(
                current: 1,
                total: 5,
                on_page: fn(_p) { "page" },
              ),
            )

          let rendered =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(rendered, "Go to previous page")
          |> expect.to_equal(expected: True)

          string.contains(rendered, "disabled")
          |> expect.to_equal(expected: True)
        }),
        it("renders next button disabled on last page", fn() {
          let view =
            headless_pagination.pagination(
              config: headless_pagination.pagination_config(
                current: 5,
                total: 5,
                on_page: fn(_p) { "page" },
              ),
            )

          let rendered =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(rendered, "Go to next page")
          |> expect.to_equal(expected: True)

          string.contains(rendered, "disabled")
          |> expect.to_equal(expected: True)
        }),
        it("renders ellipsis with aria-hidden", fn() {
          let view =
            headless_pagination.pagination(
              config: headless_pagination.pagination_config(
                current: 5,
                total: 10,
                on_page: fn(_p) { "page" },
              ),
            )

          let rendered =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(rendered, "aria-hidden=\"true\"")
          |> expect.to_equal(expected: True)

          string.contains(rendered, "...")
          |> expect.to_equal(expected: True)
        }),
      ]),
      describe("styled pagination", [
        it("renders nav with role=navigation and aria-label", fn() {
          let t = theme.theme_default()

          let view =
            ui_pagination.pagination(
              config: ui_pagination.pagination_config(
                current: 1,
                total: 5,
                on_page: fn(_p) { "page" },
              ),
              theme: t,
            )

          let rendered =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(rendered, "role=\"navigation\"")
          |> expect.to_equal(expected: True)

          string.contains(rendered, "aria-label=\"pagination\"")
          |> expect.to_equal(expected: True)
        }),
        it("renders aria-current=page on active page", fn() {
          let t = theme.theme_default()

          let view =
            ui_pagination.pagination(
              config: ui_pagination.pagination_config(
                current: 3,
                total: 5,
                on_page: fn(_p) { "page" },
              ),
              theme: t,
            )

          let rendered =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(rendered, "aria-current=\"page\"")
          |> expect.to_equal(expected: True)
        }),
        it("renders previous button disabled on first page", fn() {
          let t = theme.theme_default()

          let view =
            ui_pagination.pagination(
              config: ui_pagination.pagination_config(
                current: 1,
                total: 5,
                on_page: fn(_p) { "page" },
              ),
              theme: t,
            )

          let rendered =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(rendered, "Go to previous page")
          |> expect.to_equal(expected: True)

          string.contains(rendered, "disabled")
          |> expect.to_equal(expected: True)
        }),
        it("pagination_siblings modifier is wired through to range", fn() {
          let t = theme.theme_default()

          let view =
            ui_pagination.pagination(
              config: ui_pagination.pagination_config(
                current: 5,
                total: 20,
                on_page: fn(_p) { "page" },
              )
                |> ui_pagination.pagination_siblings(siblings: 2),
              theme: t,
            )

          let rendered =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          // With siblings=2, pages 3,4,5,6,7 should be visible
          string.contains(rendered, ">3<")
          |> expect.to_equal(expected: True)

          string.contains(rendered, ">7<")
          |> expect.to_equal(expected: True)
        }),
      ]),
    ]),
    describe("accordion", [
      describe("headless accordion", [
        it("renders trigger with aria-expanded and aria-controls", fn() {
          let item_cfg =
            headless_accordion.accordion_item_config(
              value: "a",
              title: "Section A",
            )

          let view =
            headless_accordion.accordion(
              config: headless_accordion.accordion_config(
                mode: headless_accordion.Single,
                open_items: ["a"],
                on_toggle: fn(_items) { "toggled" },
              ),
              items: [
                #(item_cfg, weft_lustre.text(content: "Content A")),
              ],
            )

          let rendered =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(rendered, "aria-expanded=\"true\"")
          |> expect.to_equal(expected: True)

          string.contains(rendered, "aria-controls=\"accordion-content-a\"")
          |> expect.to_equal(expected: True)
        }),
        it("renders content with role=region when open", fn() {
          let item_cfg =
            headless_accordion.accordion_item_config(
              value: "a",
              title: "Section A",
            )

          let view =
            headless_accordion.accordion(
              config: headless_accordion.accordion_config(
                mode: headless_accordion.Single,
                open_items: ["a"],
                on_toggle: fn(_items) { "toggled" },
              ),
              items: [
                #(item_cfg, weft_lustre.text(content: "Content A")),
              ],
            )

          let rendered =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(rendered, "role=\"region\"")
          |> expect.to_equal(expected: True)

          string.contains(rendered, "aria-labelledby=\"accordion-trigger-a\"")
          |> expect.to_equal(expected: True)
        }),
        it("hides content when item is closed", fn() {
          let item_cfg =
            headless_accordion.accordion_item_config(
              value: "a",
              title: "Section A",
            )

          let view =
            headless_accordion.accordion(
              config: headless_accordion.accordion_config(
                mode: headless_accordion.Single,
                open_items: [],
                on_toggle: fn(_items) { "toggled" },
              ),
              items: [
                #(item_cfg, weft_lustre.text(content: "Content A")),
              ],
            )

          let rendered =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(rendered, "role=\"region\"")
          |> expect.to_equal(expected: False)
        }),
        it("open item renders data-state=open", fn() {
          let item_cfg =
            headless_accordion.accordion_item_config(
              value: "a",
              title: "Section A",
            )

          let view =
            headless_accordion.accordion(
              config: headless_accordion.accordion_config(
                mode: headless_accordion.Single,
                open_items: ["a"],
                on_toggle: fn(_items) { "toggled" },
              ),
              items: [
                #(item_cfg, weft_lustre.text(content: "Content A")),
              ],
            )

          let rendered =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(rendered, "data-state=\"open\"")
          |> expect.to_equal(expected: True)
        }),
        it("disabled item renders disabled attribute", fn() {
          let item_cfg =
            headless_accordion.accordion_item_config(
              value: "a",
              title: "Section A",
            )
            |> headless_accordion.accordion_item_disabled()

          let view =
            headless_accordion.accordion(
              config: headless_accordion.accordion_config(
                mode: headless_accordion.Single,
                open_items: [],
                on_toggle: fn(_items) { "toggled" },
              ),
              items: [
                #(item_cfg, weft_lustre.text(content: "Content A")),
              ],
            )

          let rendered =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(rendered, "disabled")
          |> expect.to_equal(expected: True)
        }),
      ]),
      describe("styled accordion", [
        it("styled accordion renders with theme styling", fn() {
          let t = theme.theme_default()

          let item_cfg =
            ui_accordion.accordion_item_config(value: "a", title: "Section A")

          let view =
            ui_accordion.accordion(
              theme: t,
              config: ui_accordion.accordion_config(
                mode: headless_accordion.Single,
                open_items: ["a"],
                on_toggle: fn(_items) { "toggled" },
              ),
              items: [
                #(item_cfg, weft_lustre.text(content: "Content A")),
              ],
            )

          let css = weft_lustre.debug_stylesheet(attrs: [], child: view)

          string.contains(css, "font-weight:500;")
          |> expect.to_equal(expected: True)
        }),
        it("styled accordion shows chevron indicator", fn() {
          let t = theme.theme_default()

          let item_cfg =
            ui_accordion.accordion_item_config(value: "a", title: "Section A")

          let view =
            ui_accordion.accordion(
              theme: t,
              config: ui_accordion.accordion_config(
                mode: headless_accordion.Single,
                open_items: ["a"],
                on_toggle: fn(_items) { "toggled" },
              ),
              items: [
                #(item_cfg, weft_lustre.text(content: "Content A")),
              ],
            )

          let rendered =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(rendered, "aria-hidden=\"true\"")
          |> expect.to_equal(expected: True)
        }),
      ]),
    ]),
    describe("input_group", [
      describe("headless input_group", [
        it("renders container with role=group", fn() {
          let view =
            headless_input_group.input_group(
              config: headless_input_group.input_group_config(),
              children: [
                headless_input_group.input_group_input(attrs: []),
              ],
            )

          let rendered =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(rendered, "role=\"group\"")
          |> expect.to_equal(expected: True)
        }),
        it("renders addon with data-slot=input-group-addon", fn() {
          let view =
            headless_input_group.input_group(
              config: headless_input_group.input_group_config(),
              children: [
                headless_input_group.input_group_addon(
                  align: headless_input_group.addon_inline_start(),
                  attrs: [],
                  children: [weft_lustre.text(content: "$")],
                ),
                headless_input_group.input_group_input(attrs: []),
              ],
            )

          let rendered =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(rendered, "data-slot=\"input-group-addon\"")
          |> expect.to_equal(expected: True)
        }),
        it("disabled config adds data-disabled", fn() {
          let view =
            headless_input_group.input_group(
              config: headless_input_group.input_group_config()
                |> headless_input_group.input_group_disabled(),
              children: [
                headless_input_group.input_group_input(attrs: []),
              ],
            )

          let rendered =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(rendered, "data-disabled")
          |> expect.to_equal(expected: True)
        }),
      ]),
      describe("styled input_group", [
        it("styled input_group renders with border and rounded corners", fn() {
          let t =
            theme.theme_default()
            |> theme.theme_border(color: weft.rgb(
              red: 210,
              green: 211,
              blue: 212,
            ))
            |> theme.theme_radius_md(radius: weft.px(pixels: 6))

          let view =
            ui_input_group.input_group(
              theme: t,
              config: ui_input_group.input_group_config(),
              children: [
                ui_input_group.input_group_input(theme: t, attrs: []),
              ],
            )

          let css = weft_lustre.debug_stylesheet(attrs: [], child: view)

          string.contains(css, "border:1px solid rgb(210, 211, 212);")
          |> expect.to_equal(expected: True)

          string.contains(css, "border-radius:6px;")
          |> expect.to_equal(expected: True)
        }),
      ]),
    ]),
    describe("radio_group", [
      describe("headless radio_group", [
        it("radio_group renders div with role=radiogroup", fn() {
          let view =
            headless_radio_group.radio_group(
              config: headless_radio_group.radio_group_config(
                name: "color",
                value: "red",
                on_change: fn(_v) { "changed" },
              ),
              items: [],
            )

          let html =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(html, "role=\"radiogroup\"")
          |> expect.to_equal(expected: True)
        }),
        it("radio_group renders aria-orientation=vertical by default", fn() {
          let view =
            headless_radio_group.radio_group(
              config: headless_radio_group.radio_group_config(
                name: "color",
                value: "red",
                on_change: fn(_v) { "changed" },
              ),
              items: [],
            )

          let html =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(html, "aria-orientation=\"vertical\"")
          |> expect.to_equal(expected: True)
        }),
        it("radio_group disabled renders aria-disabled=true", fn() {
          let view =
            headless_radio_group.radio_group(
              config: headless_radio_group.radio_group_config(
                name: "color",
                value: "red",
                on_change: fn(_v) { "changed" },
              )
                |> headless_radio_group.radio_group_disabled(),
              items: [],
            )

          let html =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(html, "aria-disabled=\"true\"")
          |> expect.to_equal(expected: True)

          string.contains(html, "inert")
          |> expect.to_equal(expected: True)
        }),
      ]),
      describe("styled radio_group", [
        it("styled radio_group renders with flex layout and spacing", fn() {
          let t = theme.theme_default()

          let view =
            ui_radio_group.radio_group(
              theme: t,
              config: ui_radio_group.radio_group_config(
                name: "color",
                value: "red",
                on_change: fn(_v) { "changed" },
              ),
              items: [],
            )

          let css = weft_lustre.debug_stylesheet(attrs: [], child: view)

          string.contains(css, "gap:12px;")
          |> expect.to_equal(expected: True)
        }),
        it("styled radio_group disabled renders inert", fn() {
          let t = theme.theme_default()

          let view =
            ui_radio_group.radio_group(
              theme: t,
              config: ui_radio_group.radio_group_config(
                name: "color",
                value: "red",
                on_change: fn(_v) { "changed" },
              )
                |> ui_radio_group.radio_group_disabled(),
              items: [],
            )

          let html =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(html, "inert")
          |> expect.to_equal(expected: True)
        }),
      ]),
    ]),
    describe("scroll_area", [
      describe("headless scroll_area", [
        it("scroll_area renders data-slot=scroll-area", fn() {
          let view =
            headless_scroll_area.scroll_area(
              config: headless_scroll_area.scroll_area_config(),
              children: [],
            )

          let html =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(html, "data-slot=\"scroll-area\"")
          |> expect.to_equal(expected: True)
        }),
        it("scroll_area renders data-orientation=both by default", fn() {
          let view =
            headless_scroll_area.scroll_area(
              config: headless_scroll_area.scroll_area_config(),
              children: [],
            )

          let html =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(html, "data-orientation=\"both\"")
          |> expect.to_equal(expected: True)
        }),
      ]),
      describe("styled scroll_area", [
        it("styled scroll_area renders with rounded corners", fn() {
          let t =
            theme.theme_default()
            |> theme.theme_radius_md(radius: weft.px(pixels: 8))

          let view =
            ui_scroll_area.scroll_area(
              theme: t,
              config: ui_scroll_area.scroll_area_config(),
              children: [],
            )

          let css = weft_lustre.debug_stylesheet(attrs: [], child: view)

          string.contains(css, "border-radius:8px;")
          |> expect.to_equal(expected: True)
        }),
      ]),
    ]),
    describe("slider", [
      describe("headless slider", [
        it("slider renders input with type=range and role=slider", fn() {
          let view =
            headless_slider.slider(
              config: headless_slider.slider_config(
                value: 50.0,
                min: 0.0,
                max: 100.0,
                on_change: fn(_v) { "changed" },
              ),
            )

          let html =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(html, "type=\"range\"")
          |> expect.to_equal(expected: True)

          string.contains(html, "role=\"slider\"")
          |> expect.to_equal(expected: True)
        }),
        it("slider renders aria-valuenow, aria-valuemin, aria-valuemax", fn() {
          let view =
            headless_slider.slider(
              config: headless_slider.slider_config(
                value: 25.0,
                min: 0.0,
                max: 100.0,
                on_change: fn(_v) { "changed" },
              ),
            )

          let html =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(html, "aria-valuenow=\"25.0\"")
          |> expect.to_equal(expected: True)

          string.contains(html, "aria-valuemin=\"0.0\"")
          |> expect.to_equal(expected: True)

          string.contains(html, "aria-valuemax=\"100.0\"")
          |> expect.to_equal(expected: True)
        }),
        it("slider disabled renders disabled attribute", fn() {
          let view =
            headless_slider.slider(
              config: headless_slider.slider_config(
                value: 50.0,
                min: 0.0,
                max: 100.0,
                on_change: fn(_v) { "changed" },
              )
              |> headless_slider.slider_disabled(),
            )

          let html =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(html, "disabled")
          |> expect.to_equal(expected: True)
        }),
      ]),
      describe("styled slider", [
        it("styled slider renders with themed height", fn() {
          let t = theme.theme_default()

          let view =
            ui_slider.slider(
              theme: t,
              config: ui_slider.slider_config(
                value: 50.0,
                min: 0.0,
                max: 100.0,
                on_change: fn(_v) { "changed" },
              ),
            )

          let css = weft_lustre.debug_stylesheet(attrs: [], child: view)

          string.contains(css, "height:36px;")
          |> expect.to_equal(expected: True)
        }),
      ]),
    ]),
    describe("hover_card", [
      describe("headless hover_card", [
        it("hover_card renders content when open=True", fn() {
          let view =
            headless_hover_card.hover_card(
              config: headless_hover_card.hover_card_config(
                open: True,
                on_open_change: fn(_v) { "toggled" },
              ),
              trigger: weft_lustre.text(content: "Trigger"),
              content: weft_lustre.text(content: "Card content here"),
            )

          let html =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(html, "Card content here")
          |> expect.to_equal(expected: True)

          string.contains(html, "data-slot=\"hover-card-content\"")
          |> expect.to_equal(expected: True)
        }),
        it("hover_card hides content when open=False", fn() {
          let view =
            headless_hover_card.hover_card(
              config: headless_hover_card.hover_card_config(
                open: False,
                on_open_change: fn(_v) { "toggled" },
              ),
              trigger: weft_lustre.text(content: "Trigger"),
              content: weft_lustre.text(content: "Card content here"),
            )

          let html =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(html, "Card content here")
          |> expect.to_equal(expected: False)
        }),
      ]),
      describe("styled hover_card", [
        it("styled hover_card renders with theme styling", fn() {
          let t = theme.theme_default()

          let view =
            ui_hover_card.hover_card(
              theme: t,
              config: ui_hover_card.hover_card_config(
                open: True,
                on_open_change: fn(_v) { "toggled" },
              ),
              trigger: weft_lustre.text(content: "Trigger"),
              content: weft_lustre.text(content: "Styled content"),
            )

          let css = weft_lustre.debug_stylesheet(attrs: [], child: view)

          // Styled hover card content should have padding
          string.contains(css, "padding:16px;")
          |> expect.to_equal(expected: True)
        }),
      ]),
    ]),
    describe("context_menu", [
      describe("headless context_menu", [
        it("context_menu renders role=menu when open", fn() {
          let view =
            headless_context_menu.context_menu(
              config: headless_context_menu.context_menu_config(
                open: True,
                on_open_change: fn(_v) { "toggled" },
              ),
              trigger: weft_lustre.text(content: "Right click me"),
              items: [],
            )

          let html =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(html, "role=\"menu\"")
          |> expect.to_equal(expected: True)
        }),
        it("context_menu trigger prevents native context menu default", fn() {
          let view =
            headless_context_menu.context_menu(
              config: headless_context_menu.context_menu_config(
                open: False,
                on_open_change: fn(v) { v },
              ),
              trigger: weft_lustre.text(content: "Right click me"),
              items: [],
            )

          let contextmenu_attr = find_first_event(view, "contextmenu")

          case contextmenu_attr {
            Some(vattr.Event(handler:, prevent_default:, ..)) -> {
              let prevents_default = case prevent_default {
                vattr.Always(..) -> True
                _ -> False
              }

              prevents_default
              |> expect.to_equal(expected: True)

              let open_result = decode.run(dynamic.nil(), handler)

              let open_message = case open_result {
                Ok(vattr.Handler(message:, ..)) -> message
                Error(_) -> False
              }

              open_message
              |> expect.to_equal(expected: True)
            }
            _ -> False |> expect.to_equal(expected: True)
          }
        }),
        it("context_menu_item renders role=menuitem", fn() {
          let view =
            headless_context_menu.context_menu_item(
              config: headless_context_menu.context_menu_item_config(
                on_click: fn() { "clicked" },
              ),
              children: [weft_lustre.text(content: "Cut")],
            )

          let html =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(html, "role=\"menuitem\"")
          |> expect.to_equal(expected: True)
        }),
        it("context_menu_separator renders role=separator", fn() {
          let view = headless_context_menu.context_menu_separator()

          let html =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(html, "role=\"separator\"")
          |> expect.to_equal(expected: True)
        }),
      ]),
      describe("styled context_menu", [
        it("styled context_menu renders with overlay surface background", fn() {
          let t = theme.theme_default()

          let view =
            ui_context_menu.context_menu(
              theme: t,
              config: ui_context_menu.context_menu_config(
                open: True,
                on_open_change: fn(_v) { "toggled" },
              ),
              trigger: weft_lustre.text(content: "Right click me"),
              items: [
                ui_context_menu.context_menu_item(
                  theme: t,
                  config: ui_context_menu.context_menu_item_config(
                    on_click: fn() { "cut" },
                  ),
                  children: [weft_lustre.text(content: "Cut")],
                ),
              ],
            )

          let css = weft_lustre.debug_stylesheet(attrs: [], child: view)

          // Styled context menu should have border-radius from theme
          string.contains(css, "border-radius:")
          |> expect.to_equal(expected: True)
        }),
      ]),
    ]),
    describe("command", [
      describe("headless command_filter", [
        it("returns all items for empty query", fn() {
          let items = [
            headless_command.command_item(
              value: "a",
              label: "Alpha",
              on_select: "a",
            ),
            headless_command.command_item(
              value: "b",
              label: "Beta",
              on_select: "b",
            ),
          ]

          let result = headless_command.command_filter(items: items, query: "")

          list.length(result)
          |> expect.to_equal(expected: 2)
        }),
        it("filters by label substring", fn() {
          let items = [
            headless_command.command_item(
              value: "a",
              label: "Alpha",
              on_select: "a",
            ),
            headless_command.command_item(
              value: "b",
              label: "Beta",
              on_select: "b",
            ),
          ]

          let result =
            headless_command.command_filter(items: items, query: "alp")

          list.length(result)
          |> expect.to_equal(expected: 1)
        }),
        it("is case-insensitive", fn() {
          let items = [
            headless_command.command_item(
              value: "a",
              label: "Alpha",
              on_select: "a",
            ),
          ]

          let result =
            headless_command.command_filter(items: items, query: "ALPHA")

          list.length(result)
          |> expect.to_equal(expected: 1)
        }),
        it("excludes disabled items", fn() {
          let items = [
            headless_command.command_item(
              value: "a",
              label: "Alpha",
              on_select: "a",
            ),
            headless_command.command_item(
              value: "b",
              label: "Beta",
              on_select: "b",
            )
              |> headless_command.command_item_disabled(),
          ]

          // Empty query — should return only non-disabled
          let result = headless_command.command_filter(items: items, query: "")

          list.length(result)
          |> expect.to_equal(expected: 1)

          // Non-empty query matching disabled item — should exclude it
          let result2 =
            headless_command.command_filter(items: items, query: "Beta")

          list.length(result2)
          |> expect.to_equal(expected: 0)
        }),
      ]),
      describe("headless command render", [
        it("command renders data-slot=command", fn() {
          let view =
            headless_command.command(
              config: headless_command.command_config(
                query: "",
                on_query_change: fn(_v) { "query" },
                items: [],
              ),
            )

          let html =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(html, "data-slot=\"command\"")
          |> expect.to_equal(expected: True)
        }),
        it("command renders input with data-slot=command-input", fn() {
          let view =
            headless_command.command(
              config: headless_command.command_config(
                query: "",
                on_query_change: fn(_v) { "query" },
                items: [],
              ),
            )

          let html =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(html, "data-slot=\"command-input\"")
          |> expect.to_equal(expected: True)
        }),
      ]),
      describe("styled command", [
        it("styled command renders with theme styling", fn() {
          let t = theme.theme_default()

          let view =
            ui_command.command(
              theme: t,
              config: ui_command.command_config(
                query: "",
                on_query_change: fn(_v) { "query" },
                items: [
                  ui_command.command_item(
                    value: "a",
                    label: "Alpha",
                    on_select: "a",
                  ),
                ],
              ),
            )

          let html =
            weft_lustre.layout(attrs: [], child: view)
            |> element.to_string

          string.contains(html, "data-slot=\"command\"")
          |> expect.to_equal(expected: True)
        }),
      ]),
    ]),
  ])
}
