//// Headless avatar primitives for weft_lustre_ui.
////
//// The avatar keeps semantics and fallback behavior in the headless layer.

import gleam/list
import gleam/option.{type Option, None, Some}
import weft
import weft_lustre

/// Headless avatar configuration.
pub opaque type AvatarConfig(msg) {
  AvatarConfig(
    alt: String,
    src: Option(String),
    fallback: Option(weft_lustre.Element(msg)),
    attrs: List(weft_lustre.Attribute(msg)),
  )
}

/// Construct a default avatar configuration.
pub fn avatar_config(alt alt: String) -> AvatarConfig(msg) {
  AvatarConfig(alt: alt, src: None, fallback: None, attrs: [])
}

/// Set an avatar image source.
pub fn avatar_src(
  config config: AvatarConfig(msg),
  src src: String,
) -> AvatarConfig(msg) {
  AvatarConfig(..config, src: Some(src))
}

/// Set fallback content shown when no image source is present.
pub fn avatar_fallback(
  config config: AvatarConfig(msg),
  fallback fallback: weft_lustre.Element(msg),
) -> AvatarConfig(msg) {
  AvatarConfig(..config, fallback: Some(fallback))
}

/// Append additional attributes to the avatar root.
pub fn avatar_attrs(
  config config: AvatarConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> AvatarConfig(msg) {
  case config {
    AvatarConfig(attrs: existing, ..) ->
      AvatarConfig(..config, attrs: list.append(existing, attrs))
  }
}

fn avatar_image(src: String, alt: String) -> weft_lustre.Element(msg) {
  weft_lustre.image(
    attrs: [
      weft_lustre.styles([
        weft.width(length: weft.fixed(length: weft.pct(pct: 100.0))),
        weft.height(length: weft.fixed(length: weft.pct(pct: 100.0))),
        weft.object_fit(fit: weft.object_fit_cover()),
      ]),
    ],
    src: src,
    alt: alt,
  )
}

/// Render a headless avatar.
pub fn avatar(config config: AvatarConfig(msg)) -> weft_lustre.Element(msg) {
  case config {
    AvatarConfig(alt: alt, src: src, fallback: fallback, attrs: attrs) -> {
      let child = case src, fallback {
        Some(image_src), _ -> avatar_image(image_src, alt)
        None, Some(fallback_content) -> fallback_content
        None, None -> weft_lustre.text(content: "")
      }

      weft_lustre.element_tag(
        tag: "span",
        base_weft_attrs: [weft.el_layout()],
        attrs: attrs,
        children: [child],
      )
    }
  }
}
