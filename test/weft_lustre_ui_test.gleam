import gleam/option.{Some}
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
import weft_lustre_ui/dialog as ui_dialog
import weft_lustre_ui/headless/field as headless_field
import weft_lustre_ui/headless/input as headless_input
import weft_lustre_ui/link as ui_link
import weft_lustre_ui/theme
import weft_lustre_ui/toast as ui_toast
import weft_lustre_ui/tooltip as ui_tooltip

pub fn main() {
  startest.run(startest.default_config())
}

pub fn weft_lustre_ui_tests() {
  describe("weft_lustre_ui", [
    describe("headless", [
      it(
        "field wires label, describedby, invalid, required, and alert role",
        fn() {
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

          string.contains(rendered, "id=\"email\"")
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

          string.contains(rendered, "aria-required=\"true\"")
          |> expect.to_equal(expected: True)

          string.contains(rendered, "id=\"email--help\"")
          |> expect.to_equal(expected: True)

          string.contains(rendered, "id=\"email--error\"")
          |> expect.to_equal(expected: True)

          string.contains(rendered, "role=\"alert\"")
          |> expect.to_equal(expected: True)
        },
      ),
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
      it("select marks the matching option selected for SSR", fn() {
        let options = [
          headless_input.select_option(value: "a", label: "A"),
          headless_input.select_option(value: "b", label: "B"),
        ]

        let view =
          headless_input.select(config: headless_input.select_config(
            value: "b",
            on_change: fn(_value) { "change" },
            options: options,
          ))

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "value=\"b\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "selected")
        |> expect.to_equal(expected: True)
      }),
    ]),
    describe("styled", [
      it("button uses theme primary tokens", fn() {
        let t =
          theme.theme_default()
          |> theme.theme_primary(
            color: weft.rgb(red: 1, green: 2, blue: 3),
            on_color: weft.rgb(red: 4, green: 5, blue: 6),
          )

        let view =
          ui_button.button(
            theme: t,
            config: ui_button.button_config(on_press: "press"),
            label: weft_lustre.text(content: "OK"),
          )

        let css = weft_lustre.debug_stylesheet(attrs: [], child: view)

        string.contains(css, "background-color:rgb(1, 2, 3);")
        |> expect.to_equal(expected: True)

        string.contains(css, "color:rgb(4, 5, 6);")
        |> expect.to_equal(expected: True)
      }),
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
      it("dialog uses theme scrim color and has correct ARIA semantics", fn() {
        let t =
          theme.theme_default()
          |> theme.theme_scrim(color: weft.rgba(
            red: 1,
            green: 2,
            blue: 3,
            alpha: 0.4,
          ))

        let cfg =
          ui_dialog.dialog_config(
            root_id: "d",
            label: ui_dialog.dialog_label(value: "Dialog"),
            on_close: "close",
          )

        let raw =
          ui_dialog.dialog(
            theme: t,
            config: cfg,
            content: weft_lustre.text(content: "Hi"),
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: raw)
          |> element.to_string

        string.contains(rendered, "role=\"dialog\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "aria-modal=\"true\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "data-weft-modal-root=\"true\"")
        |> expect.to_equal(expected: True)

        let css = weft_lustre.debug_stylesheet(attrs: [], child: raw)

        string.contains(css, "background-color:rgba(1, 2, 3, 0.4);")
        |> expect.to_equal(expected: True)
      }),
      it("tooltip uses theme overlay surface tokens", fn() {
        let t =
          theme.theme_default()
          |> theme.theme_overlay_surface(
            color: weft.rgb(red: 11, green: 12, blue: 13),
            on_color: weft.rgb(red: 14, green: 15, blue: 16),
          )

        let key = overlay.overlay_key(value: "tip")
        let cfg = ui_tooltip.tooltip_config(key: key)

        let problem =
          weft.overlay_problem(
            anchor: weft.rect(x: 10, y: 10, width: 10, height: 10),
            overlay: weft.size(width: 20, height: 10),
            viewport: weft.rect(x: 0, y: 0, width: 200, height: 200),
          )

        let solution = weft.solve_overlay(problem: problem)

        let view =
          ui_tooltip.tooltip_overlay(
            theme: t,
            config: cfg,
            attrs: [],
            solution: Some(solution),
            content: weft_lustre.text(content: "tip"),
          )

        let css = weft_lustre.debug_stylesheet(attrs: [], child: view)

        string.contains(css, "background-color:rgb(11, 12, 13);")
        |> expect.to_equal(expected: True)

        string.contains(css, "color:rgb(14, 15, 16);")
        |> expect.to_equal(expected: True)
      }),
      it(
        "toast variants use theme tokens and auto-dismiss is callable on Erlang",
        fn() {
          let t =
            theme.theme_default()
            |> theme.theme_primary(
              color: weft.rgb(red: 10, green: 20, blue: 30),
              on_color: weft.rgb(red: 40, green: 50, blue: 60),
            )

          let cfg =
            ui_toast.toast_config(on_dismiss: "dismiss")
            |> ui_toast.toast_variant(variant: ui_toast.toast_variant_info())
            |> ui_toast.toast_attrs(attrs: [
              weft_lustre.html_attribute(attribute.id("toast1")),
            ])

          let view =
            ui_toast.toast(
              theme: t,
              config: cfg,
              content: weft_lustre.text(content: "t"),
            )

          let css = weft_lustre.debug_stylesheet(attrs: [], child: view)

          string.contains(css, "background-color:rgb(10, 20, 30);")
          |> expect.to_equal(expected: True)

          string.contains(css, "color:rgb(40, 50, 60);")
          |> expect.to_equal(expected: True)

          let _: effect.Effect(String) =
            ui_toast.toast_auto_dismiss(after_ms: 10, on_dismiss: "dismiss")

          1 |> expect.to_equal(expected: 1)
        },
      ),
      it("tooltip_effect is callable on Erlang (no-op effect)", fn() {
        let key = overlay.overlay_key(value: "x")
        let cfg = ui_tooltip.tooltip_config(key: key)

        let _: effect.Effect(String) =
          ui_tooltip.tooltip_effect(config: cfg, on_positioned: fn(_solution) {
            "positioned"
          })

        1 |> expect.to_equal(expected: 1)
      }),
    ]),
  ])
}
