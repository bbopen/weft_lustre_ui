import gleam/string
import lustre/element
import startest.{describe, it}
import startest/expect
import weft_lustre
import weft_lustre_ui/carousel as ui_carousel
import weft_lustre_ui/headless/carousel as headless_carousel
import weft_lustre_ui/theme

pub fn carousel_tests() {
  describe("carousel", [
    describe("headless behavior", [
      it("vertical orientation is reflected on root/content/item", fn() {
        let vertical = headless_carousel.carousel_vertical()

        let view =
          headless_carousel.carousel(
            config: headless_carousel.carousel_config()
              |> headless_carousel.carousel_orientation(orientation: vertical),
            children: [
              headless_carousel.carousel_content(
                config: headless_carousel.carousel_content_config()
                  |> headless_carousel.carousel_content_orientation(
                    orientation: vertical,
                  ),
                children: [
                  headless_carousel.carousel_item(
                    config: headless_carousel.carousel_item_config()
                      |> headless_carousel.carousel_item_orientation(
                        orientation: vertical,
                      ),
                    child: weft_lustre.text(content: "Slide 1"),
                  ),
                ],
              ),
            ],
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "data-orientation=\"vertical\"")
        |> expect.to_equal(expected: True)
      }),
      it("disabled control renders disabled attribute", fn() {
        let rendered =
          headless_carousel.carousel_previous(
            config: headless_carousel.carousel_control_config()
            |> headless_carousel.carousel_control_disabled(),
          )
          |> weft_lustre.layout(attrs: [])
          |> element.to_string

        string.contains(rendered, "disabled=\"\"")
        |> expect.to_equal(expected: True)
      }),
    ]),
    describe("headless rendering", [
      it("renders carousel root/content/item/control slots", fn() {
        let root_config = headless_carousel.carousel_config()
        let content_config = headless_carousel.carousel_content_config()
        let item_config = headless_carousel.carousel_item_config()
        let control_config =
          headless_carousel.carousel_control_config()
          |> headless_carousel.carousel_control_disabled()

        let view =
          headless_carousel.carousel(config: root_config, children: [
            headless_carousel.carousel_content(
              config: content_config,
              children: [
                headless_carousel.carousel_item(
                  config: item_config,
                  child: weft_lustre.text(content: "Slide 1"),
                ),
              ],
            ),
            headless_carousel.carousel_previous(config: control_config),
            headless_carousel.carousel_next(config: control_config),
          ])

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "data-slot=\"carousel\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "data-slot=\"carousel-item\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "data-slot=\"carousel-content\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "data-slot=\"carousel-previous\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "data-slot=\"carousel-next\"")
        |> expect.to_equal(expected: True)
      }),
    ]),
    describe("styled behavior", [
      it("styled vertical orientation is reflected in rendered markup", fn() {
        let t = theme.theme_default()
        let vertical = ui_carousel.carousel_vertical(theme: t)

        let view =
          ui_carousel.carousel(
            theme: t,
            config: ui_carousel.carousel_config(theme: t)
              |> ui_carousel.carousel_orientation(
                theme: t,
                orientation: vertical,
              ),
            children: [
              ui_carousel.carousel_content(
                theme: t,
                config: ui_carousel.carousel_content_config(theme: t)
                  |> ui_carousel.carousel_content_orientation(
                    theme: t,
                    orientation: vertical,
                  ),
                children: [
                  ui_carousel.carousel_item(
                    theme: t,
                    config: ui_carousel.carousel_item_config(theme: t)
                      |> ui_carousel.carousel_item_orientation(
                        theme: t,
                        orientation: vertical,
                      ),
                    child: weft_lustre.text(content: "Slide 1"),
                  ),
                ],
              ),
            ],
          )

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "data-orientation=\"vertical\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "data-orientation=\"horizontal\"")
        |> expect.to_equal(expected: False)
      }),
    ]),
    describe("styled rendering", [
      it("renders carousel root/content/item/control slots", fn() {
        let t = theme.theme_default()
        let root_config = ui_carousel.carousel_config(theme: t)
        let content_config = ui_carousel.carousel_content_config(theme: t)
        let item_config = ui_carousel.carousel_item_config(theme: t)
        let control_config =
          ui_carousel.carousel_control_config(theme: t)
          |> ui_carousel.carousel_control_disabled(theme: t)

        let view =
          ui_carousel.carousel(theme: t, config: root_config, children: [
            ui_carousel.carousel_content(
              theme: t,
              config: content_config,
              children: [
                ui_carousel.carousel_item(
                  theme: t,
                  config: item_config,
                  child: weft_lustre.text(content: "Slide 1"),
                ),
              ],
            ),
            ui_carousel.carousel_previous(theme: t, config: control_config),
            ui_carousel.carousel_next(theme: t, config: control_config),
          ])

        let rendered =
          weft_lustre.layout(attrs: [], child: view)
          |> element.to_string

        string.contains(rendered, "data-slot=\"carousel\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "data-slot=\"carousel-item\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "data-slot=\"carousel-content\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "data-slot=\"carousel-previous\"")
        |> expect.to_equal(expected: True)

        string.contains(rendered, "data-slot=\"carousel-next\"")
        |> expect.to_equal(expected: True)
      }),
    ]),
  ])
}
