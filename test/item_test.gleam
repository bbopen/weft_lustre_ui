import gleam/string
import lustre/element
import startest.{describe, it}
import startest/expect
import weft_lustre
import weft_lustre_ui/headless/item as headless_item
import weft_lustre_ui/item as ui_item
import weft_lustre_ui/theme

pub fn item_tests() {
  describe("item", [
    describe("headless rendering", [
      it("headless config mutators render expected variant and size", fn() {
        let config =
          headless_item.item_config()
          |> headless_item.item_variant(
            variant: headless_item.item_variant_outline(),
          )
          |> headless_item.item_size(size: headless_item.item_size_sm())

        let rendered =
          headless_item.item(config: config, children: [])
          |> weft_lustre.layout(attrs: [])
          |> element.to_string

        string.contains(rendered, "data-variant=\"outline\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "data-size=\"sm\"")
        |> expect.to_equal(expected: True)
      }),
      it("headless media config mutator updates media data-variant", fn() {
        let config =
          headless_item.item_media_config()
          |> headless_item.item_media_variant(
            variant: headless_item.item_media_variant_icon(),
          )

        let rendered =
          headless_item.item_media(config: config, children: [])
          |> weft_lustre.layout(attrs: [])
          |> element.to_string

        string.contains(rendered, "data-variant=\"icon\"")
        |> expect.to_equal(expected: True)
      }),
    ]),
    describe("styled rendering", [
      it("styled item mutators render expected variant and size", fn() {
        let t = theme.theme_default()
        let config =
          ui_item.item_config(theme: t)
          |> ui_item.item_variant(
            theme: t,
            variant: ui_item.item_variant_outline(theme: t),
          )
          |> ui_item.item_size(theme: t, size: ui_item.item_size_sm(theme: t))

        let rendered =
          ui_item.item(theme: t, config: config, children: [])
          |> weft_lustre.layout(attrs: [])
          |> element.to_string

        string.contains(rendered, "data-variant=\"outline\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "data-size=\"sm\"")
        |> expect.to_equal(expected: True)
      }),
      it("renders item root and slots with expected data-slot markers", fn() {
        let t = theme.theme_default()
        let config = ui_item.item_config(theme: t)

        let view =
          ui_item.item(theme: t, config: config, children: [
            ui_item.item_content(theme: t, attrs: [], children: [
              ui_item.item_title(theme: t, attrs: [], children: [
                weft_lustre.text(content: "Title"),
              ]),
            ]),
          ])

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "data-slot=\"item\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "data-slot=\"item-content\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "data-slot=\"item-title\"")
        |> expect.to_equal(expected: True)
      }),
    ]),
  ])
}
