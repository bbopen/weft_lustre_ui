import gleam/string
import lustre/element
import startest.{describe, it}
import startest/expect
import weft_lustre
import weft_lustre_ui/headless/navigation_menu as headless_navigation_menu
import weft_lustre_ui/navigation_menu as ui_navigation_menu
import weft_lustre_ui/theme

pub fn navigation_menu_tests() {
  describe("navigation_menu", [
    describe("headless config mutators", [
      it("viewport-enabled flag round-trips through config helpers", fn() {
        let config =
          headless_navigation_menu.navigation_menu_config()
          |> headless_navigation_menu.navigation_menu_viewport_enabled(
            enabled: False,
          )

        headless_navigation_menu.navigation_menu_config_viewport_enabled(
          config: config,
        )
        |> expect.to_equal(expected: False)
      }),
      it("trigger style helper remains available", fn() {
        { headless_navigation_menu.navigation_menu_trigger_style() != [] }
        |> expect.to_equal(expected: True)
      }),
    ]),
    describe("headless rendering", [
      it("renders root/list/item/trigger/content/link slots", fn() {
        let config = headless_navigation_menu.navigation_menu_config()

        let view =
          headless_navigation_menu.navigation_menu(config: config, children: [
            headless_navigation_menu.navigation_menu_list(attrs: [], children: [
              headless_navigation_menu.navigation_menu_item(
                attrs: [],
                children: [
                  headless_navigation_menu.navigation_menu_trigger(
                    attrs: [],
                    child: weft_lustre.text(content: "Docs"),
                  ),
                  headless_navigation_menu.navigation_menu_content(
                    attrs: [],
                    children: [
                      headless_navigation_menu.navigation_menu_link(
                        attrs: [],
                        child: weft_lustre.text(content: "Link"),
                      ),
                    ],
                  ),
                ],
              ),
            ]),
          ])

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "data-slot=\"navigation-menu\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "data-slot=\"navigation-menu-trigger\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "data-slot=\"navigation-menu-viewport\"")
        |> expect.to_equal(expected: True)
      }),
    ]),
    describe("styled config mutators", [
      it("viewport-enabled flag round-trips through config helpers", fn() {
        let t = theme.theme_default()
        let config =
          ui_navigation_menu.navigation_menu_config(theme: t)
          |> ui_navigation_menu.navigation_menu_viewport_enabled(
            theme: t,
            enabled: False,
          )

        ui_navigation_menu.navigation_menu_config_viewport_enabled(
          theme: t,
          config: config,
        )
        |> expect.to_equal(expected: False)
      }),
      it("trigger style helper remains available", fn() {
        let t = theme.theme_default()

        { ui_navigation_menu.navigation_menu_trigger_style(theme: t) != [] }
        |> expect.to_equal(expected: True)
      }),
    ]),
    describe("styled rendering", [
      it("renders root/list/item/trigger/content/link slots", fn() {
        let t = theme.theme_default()
        let config = ui_navigation_menu.navigation_menu_config(theme: t)

        let view =
          ui_navigation_menu.navigation_menu(
            theme: t,
            config: config,
            children: [
              ui_navigation_menu.navigation_menu_list(
                theme: t,
                attrs: [],
                children: [
                  ui_navigation_menu.navigation_menu_item(
                    theme: t,
                    attrs: [],
                    children: [
                      ui_navigation_menu.navigation_menu_trigger(
                        theme: t,
                        attrs: [],
                        child: weft_lustre.text(content: "Docs"),
                      ),
                      ui_navigation_menu.navigation_menu_content(
                        theme: t,
                        attrs: [],
                        children: [
                          ui_navigation_menu.navigation_menu_link(
                            theme: t,
                            attrs: [],
                            child: weft_lustre.text(content: "Link"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "data-slot=\"navigation-menu\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "data-slot=\"navigation-menu-trigger\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "data-slot=\"navigation-menu-viewport\"")
        |> expect.to_equal(expected: True)
      }),
    ]),
  ])
}
