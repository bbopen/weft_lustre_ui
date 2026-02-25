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
    describe("headless config mutators", [
      it("panel group orientation helpers round-trip", fn() {
        let vertical = headless_resizable.resizable_vertical()

        let group_config =
          headless_resizable.resizable_panel_group_config()
          |> headless_resizable.resizable_panel_group_orientation(
            orientation: vertical,
          )

        let orientation =
          headless_resizable.resizable_panel_group_config_orientation(
            config: group_config,
          )

        headless_resizable.resizable_orientation_is_vertical(
          orientation: orientation,
        )
        |> expect.to_equal(expected: True)
      }),
      it("handle config exposes grip-affordance state", fn() {
        let config =
          headless_resizable.resizable_handle_config()
          |> headless_resizable.resizable_handle_with_handle()

        headless_resizable.resizable_handle_config_with_handle(config: config)
        |> expect.to_equal(expected: True)
      }),
      it("handle orientation can be derived from panel group orientation", fn() {
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

        let orientation =
          headless_resizable.resizable_handle_config_orientation(
            config: handle_config,
          )

        headless_resizable.resizable_orientation_is_horizontal(
          orientation: orientation,
        )
        |> expect.to_equal(expected: True)
      }),
    ]),
    describe("headless rendering", [
      it("renders panel group/panel/handle slots", fn() {
        let group_config = headless_resizable.resizable_panel_group_config()
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
    describe("styled config mutators", [
      it("panel group orientation helpers round-trip", fn() {
        let t = theme.theme_default()
        let vertical = ui_resizable.resizable_vertical(theme: t)

        let group_config =
          ui_resizable.resizable_panel_group_config(theme: t)
          |> ui_resizable.resizable_panel_group_orientation(
            theme: t,
            orientation: vertical,
          )

        let orientation =
          ui_resizable.resizable_panel_group_config_orientation(
            theme: t,
            config: group_config,
          )

        ui_resizable.resizable_orientation_is_vertical(
          theme: t,
          orientation: orientation,
        )
        |> expect.to_equal(expected: True)
      }),
      it("handle config exposes grip-affordance state", fn() {
        let t = theme.theme_default()
        let config =
          ui_resizable.resizable_handle_config(theme: t)
          |> ui_resizable.resizable_handle_with_handle(theme: t)

        ui_resizable.resizable_handle_config_with_handle(
          theme: t,
          config: config,
        )
        |> expect.to_equal(expected: True)
      }),
      it("handle orientation can be derived from panel group orientation", fn() {
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

        let orientation =
          ui_resizable.resizable_handle_config_orientation(
            theme: t,
            config: handle_config,
          )

        ui_resizable.resizable_orientation_is_horizontal(
          theme: t,
          orientation: orientation,
        )
        |> expect.to_equal(expected: True)
      }),
    ]),
    describe("styled rendering", [
      it("renders panel group/panel/handle slots", fn() {
        let t = theme.theme_default()
        let group_config = ui_resizable.resizable_panel_group_config(theme: t)
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
