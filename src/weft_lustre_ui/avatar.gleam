//// Styled avatar component for weft_lustre_ui.

import weft
import weft_lustre
import weft_lustre_ui/headless/avatar as headless_avatar
import weft_lustre_ui/theme

/// Avatar visual size.
pub opaque type AvatarSize {
  AvatarSize(pixels: Int)
}

/// Small avatar size.
pub fn avatar_sm() -> AvatarSize {
  AvatarSize(pixels: 28)
}

/// Medium avatar size.
pub fn avatar_md() -> AvatarSize {
  AvatarSize(pixels: 36)
}

/// Large avatar size.
pub fn avatar_lg() -> AvatarSize {
  AvatarSize(pixels: 48)
}

/// Styled avatar configuration.
pub opaque type AvatarConfig(msg) {
  AvatarConfig(headless: headless_avatar.AvatarConfig(msg), size: AvatarSize)
}

/// Create a styled avatar configuration.
pub fn avatar_config(alt alt: String) -> AvatarConfig(msg) {
  AvatarConfig(
    headless: headless_avatar.avatar_config(alt: alt),
    size: avatar_md(),
  )
}

/// Set avatar source.
pub fn avatar_src(
  config config: AvatarConfig(msg),
  src src: String,
) -> AvatarConfig(msg) {
  case config {
    AvatarConfig(headless: headless, size: size) ->
      AvatarConfig(
        headless: headless_avatar.avatar_src(headless, src: src),
        size: size,
      )
  }
}

/// Set avatar fallback content.
pub fn avatar_fallback(
  config config: AvatarConfig(msg),
  fallback fallback: weft_lustre.Element(msg),
) -> AvatarConfig(msg) {
  case config {
    AvatarConfig(headless: headless, size: size) ->
      AvatarConfig(
        headless: headless_avatar.avatar_fallback(headless, fallback: fallback),
        size: size,
      )
  }
}

/// Set avatar size.
pub fn avatar_size(
  config config: AvatarConfig(msg),
  size size: AvatarSize,
) -> AvatarConfig(msg) {
  AvatarConfig(..config, size: size)
}

/// Append additional root attributes.
pub fn avatar_attrs(
  config config: AvatarConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> AvatarConfig(msg) {
  case config {
    AvatarConfig(headless: headless, size: size) ->
      AvatarConfig(
        headless: headless_avatar.avatar_attrs(headless, attrs: attrs),
        size: size,
      )
  }
}

fn size_px(size: AvatarSize) -> Int {
  case size {
    AvatarSize(pixels:) -> pixels
  }
}

fn base_styles(
  theme theme: theme.Theme,
  size size: AvatarSize,
) -> List(weft.Attribute) {
  let #(muted_bg, muted_fg) = theme.muted(theme)
  let px = size_px(size)

  [
    weft.display(value: weft.display_inline_flex()),
    weft.width(length: weft.fixed(length: weft.px(pixels: px))),
    weft.height(length: weft.fixed(length: weft.px(pixels: px))),
    weft.align_items(value: weft.align_items_center()),
    weft.justify_content(value: weft.justify_center()),
    weft.rounded(radius: weft.px(pixels: 9999)),
    weft.overflow(overflow: weft.overflow_hidden()),
    weft.background(color: muted_bg),
    weft.text_color(color: muted_fg),
    weft.border(
      width: weft.px(pixels: 1),
      style: weft.border_style_solid(),
      color: theme.border_color(theme),
    ),
    weft.font_family(families: theme.font_families(theme)),
    weft.font_size(size: weft.rem(rem: 0.75)),
    weft.font_weight(weight: weft.font_weight_value(weight: 600)),
  ]
}

/// Render a styled avatar.
pub fn avatar(
  theme theme: theme.Theme,
  config config: AvatarConfig(msg),
) -> weft_lustre.Element(msg) {
  case config {
    AvatarConfig(headless: headless, size: size) -> {
      let decorated =
        headless_avatar.avatar_attrs(headless, attrs: [
          weft_lustre.styles(base_styles(theme: theme, size: size)),
        ])

      headless_avatar.avatar(config: decorated)
    }
  }
}
