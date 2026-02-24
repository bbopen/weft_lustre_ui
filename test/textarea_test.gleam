import gleam/string
import lustre/element
import startest.{describe, it}
import startest/expect
import weft_lustre
import weft_lustre_ui/headless/input as headless_input
import weft_lustre_ui/headless/textarea as headless_textarea
import weft_lustre_ui/input as ui_input
import weft_lustre_ui/textarea as ui_textarea
import weft_lustre_ui/theme

pub fn textarea_tests() {
  describe("textarea", [
    describe("headless textarea facade", [
      it("headless/textarea forwards to headless/input", fn() {
        let cfg_input =
          headless_input.textarea_config(value: "Hello", on_input: fn(_value) {
            "changed"
          })

        let cfg_facade =
          headless_textarea.textarea_config(
            value: "Hello",
            on_input: fn(_value) { "changed" },
          )

        let rendered_input =
          headless_input.textarea(config: cfg_input)
          |> weft_lustre.layout(attrs: [])
          |> element.to_string

        let rendered_facade =
          headless_textarea.textarea(config: cfg_facade)
          |> weft_lustre.layout(attrs: [])
          |> element.to_string

        rendered_facade
        |> expect.to_equal(expected: rendered_input)
      }),
    ]),
    describe("styled textarea facade", [
      it("styled/textarea forwards to styled/input and keeps attrs", fn() {
        let t = theme.theme_default()

        let cfg_facade =
          ui_textarea.textarea_config(
            theme: t,
            value: "Hello",
            on_input: fn(_value) { "changed" },
          )
          |> ui_textarea.textarea_rows(theme: t, rows: 5)

        let cfg_input =
          ui_input.textarea_config(value: "Hello", on_input: fn(_value) {
            "changed"
          })
          |> ui_input.textarea_rows(rows: 5)

        let rendered_facade =
          ui_textarea.textarea(theme: t, config: cfg_facade)
          |> weft_lustre.layout(attrs: [])
          |> element.to_string

        let rendered_input =
          ui_input.textarea(theme: t, config: cfg_input)
          |> weft_lustre.layout(attrs: [])
          |> element.to_string

        rendered_facade
        |> expect.to_equal(expected: rendered_input)

        string.contains(rendered_facade, "rows=\"5\"")
        |> expect.to_equal(expected: True)
      }),
    ]),
  ])
}
