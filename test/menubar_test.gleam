import gleam/string
import lustre/attribute
import lustre/element
import startest.{describe, it}
import startest/expect
import weft_lustre
import weft_lustre_ui/headless/menubar as headless_menubar
import weft_lustre_ui/menubar as ui_menubar
import weft_lustre_ui/theme

fn open_change_label(open: Bool) -> String {
  case open {
    True -> "open"
    False -> "closed"
  }
}

pub fn menubar_tests() {
  describe("menubar", [
    describe("headless behavior", [
      it("menu config mutators render menu id/state and forwarded attrs", fn() {
        let menu_config =
          headless_menubar.menubar_menu_config(id: "file")
          |> headless_menubar.menubar_menu_open(open: True)
          |> headless_menubar.menubar_menu_on_open_change(
            on_open_change: open_change_label,
          )
          |> headless_menubar.menubar_menu_attrs(attrs: [
            weft_lustre.html_attribute(attribute.attribute("data-extra", "1")),
          ])

        let rendered =
          weft_lustre.layout(
            attrs: [],
            child: headless_menubar.menubar_menu(
              config: menu_config,
              trigger: weft_lustre.text(content: "Trigger"),
              content: weft_lustre.text(content: "Content"),
            ),
          )
          |> element.to_string

        string.contains(rendered, "data-menu-id=\"file\"")
        |> expect.to_equal(expected: True)
        string.contains(rendered, "data-state=\"open\"")
        |> expect.to_equal(expected: True)
        string.contains(rendered, "data-extra=\"1\"")
        |> expect.to_equal(expected: True)
      }),
      it(
        "item mutators render inset, destructive variant, and disabled state",
        fn() {
          let config =
            headless_menubar.menubar_item_config()
            |> headless_menubar.menubar_item_variant(
              variant: headless_menubar.menubar_item_variant_destructive(),
            )
            |> headless_menubar.menubar_item_inset()
            |> headless_menubar.menubar_item_disabled()

          let rendered =
            headless_menubar.menubar_item(
              config: config,
              child: weft_lustre.text(content: "Delete"),
            )
            |> weft_lustre.layout(attrs: [])
            |> element.to_string

          string.contains(rendered, "data-variant=\"destructive\"")
          |> expect.to_equal(expected: True)
          string.contains(rendered, "data-inset=\"true\"")
          |> expect.to_equal(expected: True)
          string.contains(rendered, "data-disabled=\"true\"")
          |> expect.to_equal(expected: True)
        },
      ),
    ]),
    describe("headless rendering", [
      it("renders menubar root and item slots", fn() {
        let root_config = headless_menubar.menubar_config()
        let item_config = headless_menubar.menubar_item_config()

        let view =
          headless_menubar.menubar(config: root_config, children: [
            headless_menubar.menubar_item(
              config: item_config,
              child: weft_lustre.text(content: "Item"),
            ),
          ])

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "role=\"menubar\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "data-slot=\"menubar-item\"")
        |> expect.to_equal(expected: True)
      }),
    ]),
    describe("styled behavior", [
      it("styled menu config mutators render menu id/state and attrs", fn() {
        let t = theme.theme_default()
        let menu_config =
          ui_menubar.menubar_menu_config(theme: t, id: "file")
          |> ui_menubar.menubar_menu_open(theme: t, open: True)
          |> ui_menubar.menubar_menu_on_open_change(
            theme: t,
            on_open_change: open_change_label,
          )
          |> ui_menubar.menubar_menu_attrs(theme: t, attrs: [
            weft_lustre.html_attribute(attribute.attribute("data-extra", "1")),
          ])

        let rendered =
          weft_lustre.layout(
            attrs: [],
            child: ui_menubar.menubar_menu(
              theme: t,
              config: menu_config,
              trigger: weft_lustre.text(content: "Trigger"),
              content: weft_lustre.text(content: "Content"),
            ),
          )
          |> element.to_string

        string.contains(rendered, "data-menu-id=\"file\"")
        |> expect.to_equal(expected: True)
        string.contains(rendered, "data-state=\"open\"")
        |> expect.to_equal(expected: True)
        string.contains(rendered, "data-extra=\"1\"")
        |> expect.to_equal(expected: True)
      }),
    ]),
    describe("styled rendering", [
      it("renders menubar root and item slots", fn() {
        let t = theme.theme_default()
        let root_config = ui_menubar.menubar_config(theme: t)
        let item_config = ui_menubar.menubar_item_config(theme: t)

        let view =
          ui_menubar.menubar(theme: t, config: root_config, children: [
            ui_menubar.menubar_item(
              theme: t,
              config: item_config,
              child: weft_lustre.text(content: "Item"),
            ),
          ])

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "role=\"menubar\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "data-slot=\"menubar-item\"")
        |> expect.to_equal(expected: True)
      }),
      it("renders menubar content in portal slot", fn() {
        let t = theme.theme_default()

        let rendered =
          weft_lustre.layout(
            attrs: [],
            child: ui_menubar.menubar_content(theme: t, attrs: [], children: [
              weft_lustre.text(content: "Content"),
            ]),
          )
          |> element.to_string

        string.contains(rendered, "data-slot=\"menubar-portal\"")
        |> expect.to_equal(expected: True)
        string.contains(rendered, "data-slot=\"menubar-content\"")
        |> expect.to_equal(expected: True)
      }),
    ]),
  ])
}
