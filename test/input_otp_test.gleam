import gleam/string
import lustre/element
import startest.{describe, it}
import startest/expect
import weft_lustre
import weft_lustre_ui/headless/input_otp as headless_input_otp
import weft_lustre_ui/input_otp as ui_input_otp
import weft_lustre_ui/theme

pub fn input_otp_tests() {
  describe("input_otp", [
    describe("headless behavior", [
      it("length and disabled mutators affect rendered slots", fn() {
        let config =
          headless_input_otp.input_otp_config(
            value: "12",
            on_change: fn(_value) { "changed" },
          )
          |> headless_input_otp.input_otp_length(length: 4)
          |> headless_input_otp.input_otp_disabled()

        let rendered =
          headless_input_otp.input_otp(config: config)
          |> weft_lustre.layout(attrs: [])
          |> element.to_string

        string.contains(rendered, "data-disabled=\"true\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "data-index=\"3\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "data-index=\"4\"")
        |> expect.to_equal(expected: False)
      }),
    ]),
    describe("headless rendering", [
      it("renders group/slot/separator slot markers", fn() {
        let group =
          headless_input_otp.input_otp_group(attrs: [], children: [
            headless_input_otp.input_otp_slot(
              index: 0,
              value: "1",
              on_input: fn(_value) { "changed" },
              disabled: False,
              attrs: [],
            ),
            headless_input_otp.input_otp_separator(attrs: []),
          ])

        let rendered =
          weft_lustre.layout(attrs: [], child: group)
          |> element.to_string

        string.contains(rendered, "data-slot=\"input-otp-group\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "data-slot=\"input-otp-slot\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "data-slot=\"input-otp-separator\"")
        |> expect.to_equal(expected: True)
      }),
    ]),
    describe("styled behavior", [
      it("length and disabled mutators affect styled rendered slots", fn() {
        let t = theme.theme_default()
        let config =
          ui_input_otp.input_otp_config(
            theme: t,
            value: "12",
            on_change: fn(_value) { "changed" },
          )
          |> ui_input_otp.input_otp_length(theme: t, length: 4)
          |> ui_input_otp.input_otp_disabled(theme: t)

        let rendered =
          ui_input_otp.input_otp(theme: t, config: config)
          |> weft_lustre.layout(attrs: [])
          |> element.to_string

        string.contains(rendered, "data-disabled=\"true\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "data-index=\"3\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "data-index=\"4\"")
        |> expect.to_equal(expected: False)
      }),
    ]),
    describe("styled rendering", [
      it("renders group/slot/separator slot markers", fn() {
        let t = theme.theme_default()

        let group =
          ui_input_otp.input_otp_group(theme: t, attrs: [], children: [
            ui_input_otp.input_otp_slot(
              theme: t,
              index: 0,
              value: "1",
              on_input: fn(_value) { "changed" },
              disabled: False,
              attrs: [],
            ),
            ui_input_otp.input_otp_separator(theme: t, attrs: []),
          ])

        let rendered =
          weft_lustre.layout(attrs: [], child: group)
          |> element.to_string

        string.contains(rendered, "data-slot=\"input-otp-group\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "data-slot=\"input-otp-slot\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "data-slot=\"input-otp-separator\"")
        |> expect.to_equal(expected: True)
      }),
    ]),
  ])
}
