# weft_lustre_ui

A 51-component UI library for [Lustre](https://hexdocs.pm/lustre/), modeled after
[shadcn/ui](https://ui.shadcn.com/). Every component comes in two tiers: a headless
version (semantic HTML + ARIA, zero styling) and a styled version (theme-token-driven
visuals).

## Installation

weft_lustre_ui isn't on Hex yet. Use a git dependency:

```toml
[dependencies]
weft_lustre_ui = { git = "https://github.com/bbopen/weft_lustre_ui", branch = "main" }
```

You'll also need [weft](https://github.com/bbopen/weft) and
[weft_lustre](https://github.com/bbopen/weft_lustre) as dependencies.

## Quick start

```gleam
import weft_lustre_ui/button
import weft_lustre_ui/card
import weft_lustre_ui/theme
import weft_lustre

fn view(model: Model) -> weft_lustre.Element(Msg) {
  let t = theme.theme_default()

  card.card(theme: t, attrs: [], children: [
    card.card_header(theme: t, attrs: [], children: [
      card.card_title(theme: t, attrs: [], children: [
        weft_lustre.text("Welcome"),
      ]),
      card.card_description(theme: t, attrs: [], children: [
        weft_lustre.text("Get started here."),
      ]),
    ]),
    card.card_content(theme: t, attrs: [], children: [
      button.button(
        theme: t,
        config: button.button_config(theme: t, on_press: UserClickedStart),
        label: weft_lustre.text("Get started"),
      ),
    ]),
  ])
}
```

## Components

### Layout

accordion, aspect-ratio, card, collapsible, scroll-area, separator, skeleton

### Forms

button, checkbox, combobox, field, input, input-group, label, native-select,
radio, radio-group, select, slider, switch, toggle, toggle-group

### Feedback

alert, alert-dialog, badge, empty, progress, spinner

### Overlay

command, context-menu, dialog, drawer, dropdown-menu, hover-card, popover,
sheet, tooltip

### Navigation

breadcrumb, link, pagination, sidebar, tabs

### Data display

avatar, calendar, kbd, table

### Grouping

button-group

### Notifications

sonner, toast

## Architecture

Each component lives in two places:

- `weft_lustre_ui/headless/<component>` handles structure, ARIA attributes, and
  keyboard behavior. No colors, no spacing, no fonts. Use headless components when
  you want full control over appearance.

- `weft_lustre_ui/<component>` wraps the headless version and applies theme tokens
  for colors, spacing, radii, shadows, and typography. This is what most apps will use.

### Theming

Styled components take a `theme.Theme` value. Start with `theme.theme_default()` and
customize with builder functions:

```gleam
import weft
import weft_lustre_ui/theme

let my_theme =
  theme.theme_default()
  |> theme.theme_primary(
    color: weft.rgb(red: 37, green: 99, blue: 235),
    on_color: weft.rgb(red: 255, green: 255, blue: 255),
  )
  |> theme.theme_radius_md(radius: weft.px(pixels: 6))
```

The theme controls: primary/danger/surface color pairs, border colors, shadows,
focus ring, scrim, spacing, border radius, disabled opacity, and font adjustment.

## Dependencies

- [weft](https://github.com/bbopen/weft) -- typed layout primitives
- [weft_lustre](https://github.com/bbopen/weft_lustre) -- Lustre rendering for weft
- [lustre](https://hexdocs.pm/lustre/) -- the Gleam UI framework

For charts, see the companion package [weft_chart](https://github.com/bbopen/weft_chart).

## License

Apache-2.0
