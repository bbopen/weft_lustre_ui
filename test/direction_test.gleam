import gleam/string
import lustre/element
import startest.{describe, it}
import startest/expect
import weft_lustre
import weft_lustre_ui/direction as ui_direction
import weft_lustre_ui/headless/direction as headless_direction
import weft_lustre_ui/theme

pub fn direction_tests() {
  describe("direction", [
    describe("headless direction", [
      it("direction_provider applies rtl dir attribute", fn() {
        let config =
          headless_direction.direction_provider_config(
            direction: headless_direction.direction_rtl(),
          )

        let rendered =
          headless_direction.direction_provider(config: config, children: [
            weft_lustre.text(content: "rtl"),
          ])
          |> weft_lustre.layout(attrs: [])
          |> element.to_string

        string.contains(rendered, "dir=\"rtl\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "dir=\"ltr\"")
        |> expect.to_equal(expected: False)
      }),
      it("direction_provider applies ltr dir attribute", fn() {
        let rendered =
          headless_direction.direction_provider(
            config: headless_direction.direction_provider_config(
              direction: headless_direction.direction_ltr(),
            ),
            children: [],
          )
          |> weft_lustre.layout(attrs: [])
          |> element.to_string

        string.contains(rendered, "dir=\"ltr\"")
        |> expect.to_equal(expected: True)
      }),
    ]),
    describe("styled direction", [
      it("styled provider applies rtl dir and helper agrees", fn() {
        let t = theme.theme_default()
        let config =
          ui_direction.direction_provider_config(
            theme: t,
            direction: ui_direction.direction_rtl(theme: t),
          )

        let direction = ui_direction.use_direction(theme: t, config: config)

        direction
        |> expect.to_equal(expected: ui_direction.direction_rtl(theme: t))

        let rendered =
          ui_direction.direction_provider(theme: t, config: config, children: [
            weft_lustre.text(content: "rtl"),
          ])
          |> weft_lustre.layout(attrs: [])
          |> element.to_string

        string.contains(rendered, "dir=\"rtl\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "dir=\"ltr\"")
        |> expect.to_equal(expected: False)
      }),
    ]),
  ])
}
