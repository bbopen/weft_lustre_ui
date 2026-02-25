import gleam/string
import lustre/element
import startest.{describe, it}
import startest/expect
import weft_lustre
import weft_lustre_ui/field as ui_field
import weft_lustre_ui/form as ui_form
import weft_lustre_ui/forms as ui_forms
import weft_lustre_ui/headless/field as headless_field
import weft_lustre_ui/headless/form as headless_form
import weft_lustre_ui/headless/forms as headless_forms
import weft_lustre_ui/headless/input as headless_input
import weft_lustre_ui/input as ui_input
import weft_lustre_ui/theme

pub fn form_tests() {
  describe("form", [
    describe("headless form facade", [
      it("headless/form forwards to headless/forms for form root", fn() {
        let rendered_forms =
          headless_forms.form(config: headless_forms.form_config(), children: [
            weft_lustre.text(content: "a"),
          ])
          |> weft_lustre.layout(attrs: [])
          |> element.to_string

        let rendered_form =
          headless_form.form(config: headless_form.form_config(), children: [
            weft_lustre.text(content: "a"),
          ])
          |> weft_lustre.layout(attrs: [])
          |> element.to_string

        rendered_form
        |> expect.to_equal(expected: rendered_forms)
      }),
    ]),
    describe("styled form facade", [
      it("form facade forwards to canonical forms helpers", fn() {
        let t = theme.theme_default()
        let field_config = ui_field.field_config(id: "name")
        let input_config =
          ui_input.text_input_config(value: "Ada", on_input: fn(_value) {
            "changed"
          })

        let rendered_forms =
          ui_forms.field_text_input(
            theme: t,
            field_config: field_config,
            input_config: input_config,
          )
          |> weft_lustre.layout(attrs: [])
          |> element.to_string

        let rendered_form =
          ui_form.field_text_input(
            theme: t,
            field_config: field_config,
            input_config: input_config,
          )
          |> weft_lustre.layout(attrs: [])
          |> element.to_string

        rendered_form
        |> expect.to_equal(expected: rendered_forms)
      }),
      it("styled form root renders semantic form container", fn() {
        let t = theme.theme_default()
        let rendered =
          ui_form.form(
            theme: t,
            config: ui_form.form_config(theme: t),
            children: [weft_lustre.text(content: "body")],
          )
          |> weft_lustre.layout(attrs: [])
          |> element.to_string

        string.contains(rendered, "<form")
        |> expect.to_equal(expected: True)
      }),
      it("headless form helper wiring remains available", fn() {
        let rendered =
          headless_form.field_textarea(
            field_config: headless_field.field_config(id: "bio"),
            textarea_config: headless_input.textarea_config(
              value: "Hello",
              on_input: fn(_value) { "changed" },
            ),
          )
          |> weft_lustre.layout(attrs: [])
          |> element.to_string

        string.contains(rendered, "<textarea")
        |> expect.to_equal(expected: True)
      }),
    ]),
  ])
}
