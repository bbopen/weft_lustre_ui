import gleam/option.{None, Some}
import gleam/string
import lustre/attribute
import lustre/effect
import lustre/element
import startest.{describe, it}
import startest/expect
import weft
import weft_lustre
import weft_lustre/overlay

import weft_lustre_ui/button as ui_button
import weft_lustre_ui/checkbox as ui_checkbox
import weft_lustre_ui/dialog as ui_dialog
import weft_lustre_ui/field as ui_field
import weft_lustre_ui/forms as ui_forms
import weft_lustre_ui/headless/button as headless_button
import weft_lustre_ui/headless/checkbox as headless_checkbox
import weft_lustre_ui/headless/dialog as headless_dialog
import weft_lustre_ui/headless/field as headless_field
import weft_lustre_ui/headless/forms as headless_forms
import weft_lustre_ui/headless/input as headless_input
import weft_lustre_ui/headless/link as headless_link
import weft_lustre_ui/headless/radio as headless_radio
import weft_lustre_ui/headless/toast as headless_toast
import weft_lustre_ui/headless/tooltip as headless_tooltip
import weft_lustre_ui/input as ui_input
import weft_lustre_ui/link as ui_link
import weft_lustre_ui/radio as ui_radio
import weft_lustre_ui/theme
import weft_lustre_ui/toast as ui_toast
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
    ]),
    describe("styled", [
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
    ]),
  ])
}
