import gleam/string
import lustre/element
import startest.{describe, it}
import startest/expect
import weft_lustre
import weft_lustre_ui/headless/resizable as headless_resizable
import weft_lustre_ui/resizable as ui_resizable
import weft_lustre_ui/theme

pub fn resizable_tests() {
  describe("resizable", [
    describe("headless behavior", [
      it("vertical panel group drives horizontal handle orientation", fn() {
        let group_config =
          headless_resizable.resizable_panel_group_config()
          |> headless_resizable.resizable_panel_group_orientation(
            orientation: headless_resizable.resizable_vertical(),
          )

        let handle_config =
          headless_resizable.resizable_handle_config()
          |> headless_resizable.resizable_handle_orientation_from_group(
            group_config: group_config,
          )

        let rendered =
          headless_resizable.resizable_handle(config: handle_config)
          |> weft_lustre.layout(attrs: [])
          |> element.to_string

        string.contains(rendered, "aria-orientation=\"horizontal\"")
        |> expect.to_equal(expected: True)
      }),
      it("horizontal panel group renders horizontal aria-orientation", fn() {
        let rendered =
          headless_resizable.resizable_panel_group(
            config: headless_resizable.resizable_panel_group_config(),
            children: [],
          )
          |> weft_lustre.layout(attrs: [])
          |> element.to_string

        string.contains(rendered, "aria-orientation=\"horizontal\"")
        |> expect.to_equal(expected: True)
      }),
    ]),
    describe("headless rendering", [
      it("renders panel group/panel/handle slots", fn() {
        let group_config =
          headless_resizable.resizable_panel_group_config()
          |> headless_resizable.resizable_panel_group_orientation(
            orientation: headless_resizable.resizable_vertical(),
          )
        let handle_config =
          headless_resizable.resizable_handle_config()
          |> headless_resizable.resizable_handle_with_handle()

        let view =
          headless_resizable.resizable_panel_group(
            config: group_config,
            children: [
              headless_resizable.resizable_panel(attrs: [], children: [
                weft_lustre.text(content: "A"),
              ]),
              headless_resizable.resizable_handle(config: handle_config),
            ],
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "data-slot=\"resizable-panel-group\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "data-slot=\"resizable-grip\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "aria-orientation=\"vertical\"")
        |> expect.to_equal(expected: True)
      }),
    ]),
    describe("styled behavior", [
      it(
        "styled vertical panel group drives horizontal handle orientation",
        fn() {
          let t = theme.theme_default()
          let group_config =
            ui_resizable.resizable_panel_group_config(theme: t)
            |> ui_resizable.resizable_panel_group_orientation(
              theme: t,
              orientation: ui_resizable.resizable_vertical(theme: t),
            )

          let handle_config =
            ui_resizable.resizable_handle_config(theme: t)
            |> ui_resizable.resizable_handle_orientation_from_group(
              theme: t,
              group_config: group_config,
            )

          let rendered =
            ui_resizable.resizable_handle(theme: t, config: handle_config)
            |> weft_lustre.layout(attrs: [])
            |> element.to_string

          string.contains(rendered, "aria-orientation=\"horizontal\"")
          |> expect.to_equal(expected: True)
        },
      ),
    ]),
    describe("styled rendering", [
      it("renders panel group/panel/handle slots", fn() {
        let t = theme.theme_default()
        let group_config =
          ui_resizable.resizable_panel_group_config(theme: t)
          |> ui_resizable.resizable_panel_group_orientation(
            theme: t,
            orientation: ui_resizable.resizable_vertical(theme: t),
          )
        let handle_config = ui_resizable.resizable_handle_config(theme: t)

        let view =
          ui_resizable.resizable_panel_group(
            theme: t,
            config: group_config,
            children: [
              ui_resizable.resizable_panel(theme: t, attrs: [], children: [
                weft_lustre.text(content: "A"),
              ]),
              ui_resizable.resizable_handle(theme: t, config: handle_config),
            ],
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "data-slot=\"resizable-panel-group\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "data-slot=\"resizable-handle\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "aria-orientation=\"vertical\"")
        |> expect.to_equal(expected: True)
      }),
    ]),
  ])
}
