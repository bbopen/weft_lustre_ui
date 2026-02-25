//// Headless carousel primitives for shadcn compatibility.
////
//// Provides semantic carousel structure and controls without external JS
//// dependencies. Scroll behavior is application-managed.

import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute
import lustre/event
import weft
import weft_lustre

type Orientation {
  Horizontal
  Vertical
}

/// Carousel orientation token.
pub opaque type CarouselOrientation {
  CarouselOrientation(value: Orientation)
}

/// Horizontal carousel orientation.
pub fn carousel_horizontal() -> CarouselOrientation {
  CarouselOrientation(value: Horizontal)
}

/// Vertical carousel orientation.
pub fn carousel_vertical() -> CarouselOrientation {
  CarouselOrientation(value: Vertical)
}

/// Carousel root configuration.
pub opaque type CarouselConfig(msg) {
  CarouselConfig(
    orientation: CarouselOrientation,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default carousel configuration.
pub fn carousel_config() -> CarouselConfig(msg) {
  CarouselConfig(orientation: carousel_horizontal(), attrs: [])
}

/// Set carousel orientation.
pub fn carousel_orientation(
  config config: CarouselConfig(msg),
  orientation orientation: CarouselOrientation,
) -> CarouselConfig(msg) {
  CarouselConfig(..config, orientation: orientation)
}

/// Append carousel root attributes.
pub fn carousel_attrs(
  config config: CarouselConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> CarouselConfig(msg) {
  case config {
    CarouselConfig(attrs: existing, ..) ->
      CarouselConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Carousel content configuration.
pub opaque type CarouselContentConfig(msg) {
  CarouselContentConfig(
    orientation: CarouselOrientation,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default carousel content configuration.
pub fn carousel_content_config() -> CarouselContentConfig(msg) {
  CarouselContentConfig(orientation: carousel_horizontal(), attrs: [])
}

/// Set carousel content orientation.
pub fn carousel_content_orientation(
  config config: CarouselContentConfig(msg),
  orientation orientation: CarouselOrientation,
) -> CarouselContentConfig(msg) {
  CarouselContentConfig(..config, orientation: orientation)
}

/// Append carousel content attributes.
pub fn carousel_content_attrs(
  config config: CarouselContentConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> CarouselContentConfig(msg) {
  case config {
    CarouselContentConfig(attrs: existing, ..) ->
      CarouselContentConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Carousel item configuration.
pub opaque type CarouselItemConfig(msg) {
  CarouselItemConfig(
    orientation: CarouselOrientation,
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default carousel item configuration.
pub fn carousel_item_config() -> CarouselItemConfig(msg) {
  CarouselItemConfig(orientation: carousel_horizontal(), attrs: [])
}

/// Set carousel item orientation.
pub fn carousel_item_orientation(
  config config: CarouselItemConfig(msg),
  orientation orientation: CarouselOrientation,
) -> CarouselItemConfig(msg) {
  CarouselItemConfig(..config, orientation: orientation)
}

/// Append carousel item attributes.
pub fn carousel_item_attrs(
  config config: CarouselItemConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> CarouselItemConfig(msg) {
  case config {
    CarouselItemConfig(attrs: existing, ..) ->
      CarouselItemConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Carousel control configuration.
pub opaque type CarouselControlConfig(msg) {
  CarouselControlConfig(
    disabled: Bool,
    on_press: Option(msg),
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default carousel control configuration.
pub fn carousel_control_config() -> CarouselControlConfig(msg) {
  CarouselControlConfig(disabled: False, on_press: None, attrs: [])
}

/// Mark a carousel control disabled.
pub fn carousel_control_disabled(
  config config: CarouselControlConfig(msg),
) -> CarouselControlConfig(msg) {
  CarouselControlConfig(..config, disabled: True)
}

/// Set carousel control click message.
pub fn carousel_control_on_press(
  config config: CarouselControlConfig(msg),
  on_press on_press: msg,
) -> CarouselControlConfig(msg) {
  CarouselControlConfig(..config, on_press: Some(on_press))
}

/// Append carousel control attributes.
pub fn carousel_control_attrs(
  config config: CarouselControlConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> CarouselControlConfig(msg) {
  case config {
    CarouselControlConfig(attrs: existing, ..) ->
      CarouselControlConfig(..config, attrs: list.append(existing, attrs))
  }
}

/// Internal: check orientation is vertical.
@internal
pub fn carousel_orientation_is_vertical(
  orientation orientation: CarouselOrientation,
) -> Bool {
  case orientation {
    CarouselOrientation(value: Horizontal) -> False
    CarouselOrientation(value: Vertical) -> True
  }
}

/// Internal: read root orientation.
@internal
pub fn carousel_config_orientation(
  config config: CarouselConfig(msg),
) -> CarouselOrientation {
  case config {
    CarouselConfig(orientation:, ..) -> orientation
  }
}

/// Internal: read content orientation.
@internal
pub fn carousel_content_config_orientation(
  config config: CarouselContentConfig(msg),
) -> CarouselOrientation {
  case config {
    CarouselContentConfig(orientation:, ..) -> orientation
  }
}

/// Internal: read item orientation.
@internal
pub fn carousel_item_config_orientation(
  config config: CarouselItemConfig(msg),
) -> CarouselOrientation {
  case config {
    CarouselItemConfig(orientation:, ..) -> orientation
  }
}

fn orientation_value(orientation: CarouselOrientation) -> String {
  case orientation {
    CarouselOrientation(value: Horizontal) -> "horizontal"
    CarouselOrientation(value: Vertical) -> "vertical"
  }
}

/// Render the carousel root.
pub fn carousel(
  config config: CarouselConfig(msg),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  case config {
    CarouselConfig(orientation: orientation, attrs: attrs) ->
      weft_lustre.element_tag(
        tag: "div",
        base_weft_attrs: [weft.el_layout()],
        attrs: list.append(
          [
            weft_lustre.html_attribute(attribute.role("region")),
            weft_lustre.html_attribute(attribute.attribute(
              "aria-roledescription",
              "carousel",
            )),
            weft_lustre.html_attribute(attribute.attribute(
              "data-slot",
              "carousel",
            )),
            weft_lustre.html_attribute(attribute.attribute(
              "data-orientation",
              orientation_value(orientation),
            )),
          ],
          attrs,
        ),
        children: children,
      )
  }
}

/// Render carousel content.
pub fn carousel_content(
  config config: CarouselContentConfig(msg),
  children children: List(weft_lustre.Element(msg)),
) -> weft_lustre.Element(msg) {
  case config {
    CarouselContentConfig(orientation: orientation, attrs: attrs) ->
      weft_lustre.element_tag(
        tag: "div",
        base_weft_attrs: [weft.el_layout()],
        attrs: list.append(
          [
            weft_lustre.html_attribute(attribute.attribute(
              "data-slot",
              "carousel-content",
            )),
            weft_lustre.html_attribute(attribute.attribute(
              "data-orientation",
              orientation_value(orientation),
            )),
          ],
          attrs,
        ),
        children: children,
      )
  }
}

/// Render a carousel item.
pub fn carousel_item(
  config config: CarouselItemConfig(msg),
  child child: weft_lustre.Element(msg),
) -> weft_lustre.Element(msg) {
  case config {
    CarouselItemConfig(orientation: orientation, attrs: attrs) ->
      weft_lustre.element_tag(
        tag: "div",
        base_weft_attrs: [weft.el_layout()],
        attrs: list.append(
          [
            weft_lustre.html_attribute(attribute.role("group")),
            weft_lustre.html_attribute(attribute.attribute(
              "aria-roledescription",
              "slide",
            )),
            weft_lustre.html_attribute(attribute.attribute(
              "data-slot",
              "carousel-item",
            )),
            weft_lustre.html_attribute(attribute.attribute(
              "data-orientation",
              orientation_value(orientation),
            )),
          ],
          attrs,
        ),
        children: [child],
      )
  }
}

fn control(
  slot slot: String,
  config config: CarouselControlConfig(msg),
  label label: String,
) -> weft_lustre.Element(msg) {
  case config {
    CarouselControlConfig(disabled: disabled, on_press: on_press, attrs: attrs) -> {
      let click_attrs = case disabled, on_press {
        True, _ -> []
        False, Some(message) -> [
          weft_lustre.html_attribute(event.on_click(message)),
        ]
        False, None -> []
      }

      weft_lustre.element_tag(
        tag: "button",
        base_weft_attrs: [weft.el_layout()],
        attrs: list.flatten([
          [weft_lustre.html_attribute(attribute.type_("button"))],
          [weft_lustre.html_attribute(attribute.attribute("data-slot", slot))],
          [weft_lustre.html_attribute(attribute.attribute("aria-label", label))],
          case disabled {
            True -> [weft_lustre.html_attribute(attribute.disabled(True))]
            False -> []
          },
          click_attrs,
          attrs,
        ]),
        children: [weft_lustre.text(content: label)],
      )
    }
  }
}

/// Render a previous-slide button.
pub fn carousel_previous(
  config config: CarouselControlConfig(msg),
) -> weft_lustre.Element(msg) {
  control(slot: "carousel-previous", config: config, label: "Previous slide")
}

/// Render a next-slide button.
pub fn carousel_next(
  config config: CarouselControlConfig(msg),
) -> weft_lustre.Element(msg) {
  control(slot: "carousel-next", config: config, label: "Next slide")
}
