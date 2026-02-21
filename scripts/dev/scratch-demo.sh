#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PACKAGE_NAME="weft_lustre_ui_scratch"
SCRATCH_DIR="${ROOT_DIR}/scratch"

HOST="127.0.0.1"
PORT="4173"
SERVE=1
BUILD=1
OPEN_BROWSER=0

usage() {
  cat <<'EOF'
Usage:
  scripts/dev/scratch-demo.sh [options] [path]

Options:
  --serve              Start local HTTP server after generation (default)
  --no-serve           Do not start local HTTP server
  --skip-build          Skip gleam build step (use for manual file edits)
  --port <number>      Override port for demo server (default: 4173)
  --host <host>        Override host for demo server (default: 127.0.0.1)
  --open               Open browser after server starts
  --help               Show this message

Positional:
  path                 Scratch app directory (default: <repo>/scratch)
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --serve)
      SERVE=1
      ;;
    --no-serve)
      SERVE=0
      ;;
    --skip-build)
      BUILD=0
      ;;
    --open)
      OPEN_BROWSER=1
      ;;
    --port)
      if [ "$#" -lt 2 ]; then
        echo "error: --port requires a value" >&2
        exit 1
      fi
      PORT="$2"
      shift
      ;;
    --host)
      if [ "$#" -lt 2 ]; then
        echo "error: --host requires a value" >&2
        exit 1
      fi
      HOST="$2"
      shift
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      if [ "${1#-}" != "$1" ]; then
        echo "error: unknown option: $1" >&2
        usage
        exit 1
      fi
      SCRATCH_DIR="$1"
      ;;
  esac
  shift
done

SCRATCH_SRC="$SCRATCH_DIR/src"
SCRATCH_BLOCKS="$SCRATCH_SRC/blocks"

mkdir -p "$SCRATCH_SRC" "$SCRATCH_BLOCKS"

cat > "$SCRATCH_DIR/gleam.toml" <<EOF
name = "$PACKAGE_NAME"
version = "0.1.0"
description = "Scratch app for weft_lustre_ui manual composition checks."
licences = ["Apache-2.0"]
gleam = ">= 1.14.0"

[dependencies]
gleam_stdlib = ">= 0.69.0"
lustre = ">= 5.0.0 and < 6.0.0"
weft = { path = "$ROOT_DIR/../weft" }
weft_lustre = { path = "$ROOT_DIR/../weft_lustre" }
weft_lustre_ui = { path = "$ROOT_DIR" }

[dev-dependencies]
startest = ">= 0.8.0"
EOF

cat > "$SCRATCH_DIR/README.md" <<'EOF'
# weft_lustre_ui Scratch Blocks

This directory is intentionally untracked via repo-local config in `.git/info/exclude`.
Use it for manual, local visual checks before promoting examples into packages.

Committed benchmark parity app lives in `examples/dashboard_benchmark`.
Use `scripts/dev/check-visual.sh` for tracked desktop/mobile regression checks.

### Recommended use

- Keep one root block gallery in `src/main.gleam`.
- Keep reusable block modules in `src/blocks/`.
- Build quickly against local `weft_lustre_ui` API, then move promoted examples into:
  - `_refs/*_demo.gleam` for manual harnesses, or
  - regular app projects.

### Current starter content

- `blocks/hero.gleam`
- `blocks/dashboard.gleam`
- `blocks/forms.gleam`
- `blocks/overlay.gleam`
- `blocks/composable.gleam`
- `blocks/navigation.gleam`
- `blocks/listing.gleam`

Each block is a small composition of headless/styled primitives inspired by
ShadCN-style building blocks, focusing on:

- structural layout composition
- form wiring (labels + IDs + describedby)
- overlay anchoring and placement surface
- layer usage for toast/dialog patterns

### Manual checks to run in browser

- no flashy layout collapse at narrow and wide breakpoints
- focus outlines visible on interactive elements
- tooltip/popover does not render off-screen at (0,0)
- modal overlay and toast behavior remains deterministic
- same-origin serving via local HTTP server means no CORS required for app loading
EOF

cat > "$SCRATCH_SRC/main.gleam" <<'EOF'
import gleam/option.{type Option, None, Some}
import lustre
import lustre/effect
import weft
import weft_lustre
import weft_lustre/modal
import weft_lustre/overlay
import weft_lustre_ui
import weft_lustre_ui/tooltip

import blocks/composable
import blocks/dashboard
import blocks/forms
import blocks/hero
import blocks/listing
import blocks/navigation
import blocks/overlay as overlay_block

type AppState {
  AppState(
    tooltip_open: Bool,
    tooltip_solution: Option(weft.OverlaySolution),
    modal_open: Bool,
    toast_visible: Bool,
  )
}

pub type Msg {
  HeroPrimary
  HeroSecondary
  OpenDialog
  CloseDialog
  OpenTooltip
  RepositionTooltip
  TooltipPositioned(weft.OverlaySolution)
  ViewAllProjects
  OpenToast
  DismissToast
  EmailInput(String)
  BioInput(String)
  TeamSelect(String)
  TermsToggle(Bool)
  DensitySelect(String)
}

const modal_root_id = "scratch-modal"

fn tooltip_key() -> overlay.OverlayKey {
  overlay.overlay_key(value: "scratch-overlay")
}

fn tooltip_config() -> tooltip.TooltipConfig(Msg) {
  tooltip.tooltip_config(key: tooltip_key())
  |> tooltip.tooltip_prefer_sides(sides: [
    weft.overlay_side_below(),
    weft.overlay_side_above(),
  ])
  |> tooltip.tooltip_alignments(alignments: [weft.overlay_align_center()])
  |> tooltip.tooltip_viewport_padding_px(pixels: 12)
  |> tooltip.tooltip_offset_px(pixels: 8)
}

fn build_page(
  theme theme: weft_lustre_ui.Theme,
  state state: AppState,
) -> weft_lustre.Element(Msg) {
  let tooltip_overlay =
    case state.tooltip_open, state.tooltip_solution {
      False, _ -> weft_lustre.none()
      True, Some(solution) ->
        tooltip.tooltip_overlay(
          theme: theme,
          config: tooltip_config(),
          attrs: [weft_lustre.styles([weft.padding(pixels: 8)])],
          solution: Some(solution),
          content: weft_lustre.text(content: "Measured tooltip"),
        )

      True, None ->
        weft_lustre.column(
          attrs: [],
          children: [
            weft_lustre.text(content: "Tooltip measuring…"),
            weft_lustre.text(content: "Positioned after first paint"),
          ],
        )
    }

  weft_lustre.column(
    attrs: [
      weft_lustre.styles([
        weft.spacing(pixels: 24),
        weft.padding(pixels: 24),
      ]),
    ],
    children: [
      hero.hero_block(
        theme: theme,
        on_primary: HeroPrimary,
        on_secondary: HeroSecondary,
      ),
      navigation.navigation_block(theme: theme),
      listing.listing_block(
        theme: theme,
        on_view: ViewAllProjects,
      ),
      dashboard.dashboard_block(
        theme: theme,
        on_open_toast: OpenToast,
      ),
      forms.form_block(
        theme: theme,
        on_email_input: EmailInput,
        on_bio_input: BioInput,
        on_team_select: TeamSelect,
        on_terms_toggle: TermsToggle,
        on_density_select: DensitySelect,
      ),
      overlay_block.overlay_block(
        theme: theme,
        on_open_tooltip: OpenTooltip,
      ),
      tooltip_overlay,
      composable.modal_and_toast_block(
        theme: theme,
        on_open_dialog: OpenDialog,
        on_close_dialog: CloseDialog,
        on_show_toast: OpenToast,
        on_toast_dismiss: DismissToast,
        on_reposition_tooltip: RepositionTooltip,
        modal_open: state.modal_open,
        toast_visible: state.toast_visible,
      ),
    ],
  )
}

pub fn main() {
  let app =
    lustre.application(
      init: fn(_flags: Nil) {
        #(
          AppState(
            tooltip_open: False,
            tooltip_solution: None,
            modal_open: False,
            toast_visible: False,
          ),
          effect.none(),
        )
      },
      update: fn(state: AppState, msg: Msg) {
        case msg {
          HeroPrimary -> #(state, effect.none())
          HeroSecondary -> #(state, effect.none())
          OpenDialog ->
            #(
              AppState(..state, modal_open: True),
              modal.modal_focus_trap(root_id: modal_root_id, on_escape: CloseDialog),
            )

          CloseDialog ->
            #(AppState(..state, modal_open: False), effect.none())

          OpenToast ->
            #(AppState(..state, toast_visible: True), effect.none())

          DismissToast ->
            #(AppState(..state, toast_visible: False), effect.none())

          OpenTooltip -> {
            let eff =
              tooltip.tooltip_effect(
                config: tooltip_config(),
                on_positioned: TooltipPositioned,
              )

            #(
              AppState(
                ..state,
                tooltip_open: True,
                tooltip_solution: None,
              ),
              eff,
            )
          }

          ViewAllProjects -> #(state, effect.none())

          RepositionTooltip ->
            case state.tooltip_open {
              True -> #(
                AppState(..state, tooltip_solution: None),
                tooltip.tooltip_effect(
                  config: tooltip_config(),
                  on_positioned: TooltipPositioned,
                ),
              )
              False -> #(state, effect.none())
            }

          TooltipPositioned(solution) ->
            #(AppState(..state, tooltip_solution: Some(solution)), effect.none())

          EmailInput(_) -> #(state, effect.none())
          BioInput(_) -> #(state, effect.none())
          TeamSelect(_) -> #(state, effect.none())
          TermsToggle(_) -> #(state, effect.none())
          DensitySelect(_) -> #(state, effect.none())
        }
      },
      view: fn(state: AppState) {
        weft_lustre.layout(
          attrs: [],
          child: build_page(
            theme: weft_lustre_ui.theme_default(),
            state: state,
          ),
        )
      },
    )

  lustre.start(app, "#app", Nil)
}
EOF

cat > "$SCRATCH_BLOCKS/hero.gleam" <<'EOF'
import weft
import weft_lustre
import weft_lustre_ui
import weft_lustre_ui/badge
import weft_lustre_ui/button
import weft_lustre_ui/card

pub fn hero_block(
  theme theme: weft_lustre_ui.Theme,
  on_primary on_primary: msg,
  on_secondary on_secondary: msg,
) -> weft_lustre.Element(msg) {
  let primary =
    button.button(
      theme: theme,
      config: button.button_config(on_press: on_primary),
      label: weft_lustre.text(content: "Create workspace"),
    )

  let secondary =
    button.button(
      theme: theme,
      config:
        button.button_config(on_press: on_secondary)
        |> button.button_variant(variant: button.secondary()),
      label: weft_lustre.text(content: "View guide"),
    )

  card.card(
    theme: theme,
    attrs: [],
    children: [
      card.card_header(
        theme: theme,
        attrs: [],
        children: [
          weft_lustre.column(
            attrs: [weft_lustre.styles([weft.spacing(pixels: 4)])],
            children: [
              weft_lustre.text(content: "weft_lustre_ui"),
              badge.badge(
                theme: theme,
                config:
                  badge.badge_config()
                  |> badge.badge_variant(variant: badge.badge_secondary()),
                child: weft_lustre.text(content: "ShadCN-inspired"),
              ),
            ],
          ),
          secondary,
        ],
      ),
      card.card_content(
        theme: theme,
        attrs: [weft_lustre.styles([weft.spacing(pixels: 12)])],
        children: [
          weft_lustre.text(content: "Composable layout and components for pro-grade UIs."),
          primary,
        ],
      ),
    ],
  )
}
EOF

cat > "$SCRATCH_BLOCKS/dashboard.gleam" <<'EOF'
import weft
import weft_lustre
import weft_lustre_ui
import weft_lustre_ui/badge
import weft_lustre_ui/button
import weft_lustre_ui/card

fn stat_card(
  theme theme: weft_lustre_ui.Theme,
  label label: String,
  value value: String,
) -> weft_lustre.Element(msg) {
  card.card(
    theme: theme,
    attrs: [],
    children: [
      card.card_header(
        theme: theme,
        attrs: [],
        children: [
          weft_lustre.text(content: label),
          badge.badge(
            theme: theme,
            config: badge.badge_config(),
            child: weft_lustre.text(content: value),
          ),
        ],
      ),
    ],
  )
}

pub fn dashboard_block(
  theme theme: weft_lustre_ui.Theme,
  on_open_toast on_open_toast: msg,
) -> weft_lustre.Element(msg) {
  let body =
    weft_lustre.row(
      attrs: [],
      children: [
        stat_card(theme: theme, label: "Active users", value: "12,342"),
        stat_card(theme: theme, label: "Latency", value: "132ms"),
        stat_card(theme: theme, label: "Errors", value: "0.2%"),
      ],
    )

  let actions =
    weft_lustre.row(
      attrs: [weft_lustre.styles([weft.spacing(pixels: 12)])],
      children: [
        button.button(
          theme: theme,
          config: button.button_config(on_press: on_open_toast),
          label: weft_lustre.text(content: "Create insight toast"),
        ),
      ],
    )

  card.card(
    theme: theme,
    attrs: [],
    children: [
      card.card_header(
        theme: theme,
        attrs: [],
        children: [weft_lustre.text(content: "Metrics")],
      ),
      card.card_content(
        theme: theme,
        attrs: [weft_lustre.styles([weft.spacing(pixels: 16)])],
        children: [body, actions],
      ),
    ],
  )
}
EOF

cat > "$SCRATCH_BLOCKS/forms.gleam" <<'EOF'
import weft
import weft_lustre
import weft_lustre_ui
import weft_lustre_ui/card
import weft_lustre_ui/checkbox
import weft_lustre_ui/field
import weft_lustre_ui/forms
import weft_lustre_ui/input
import weft_lustre_ui/radio

pub fn form_block(
  theme theme: weft_lustre_ui.Theme,
  on_email_input on_email_input: fn(String) -> msg,
  on_bio_input on_bio_input: fn(String) -> msg,
  on_team_select on_team_select: fn(String) -> msg,
  on_terms_toggle on_terms_toggle: fn(Bool) -> msg,
  on_density_select on_density_select: fn(String) -> msg,
) -> weft_lustre.Element(msg) {
  let email_field =
    forms.field_text_input(
      theme: theme,
      field_config:
        field.field_config(id: "scratch-email")
        |> field.field_required()
        |> field.field_label_text(text: "Email"),
      input_config:
        input.text_input_config(value: "ada@example.com", on_input: on_email_input)
        |> input.text_input_type(input_type: input.input_type_email()),
    )

  let bio_field =
    forms.field_textarea(
      theme: theme,
      field_config:
        field.field_config(id: "scratch-bio")
        |> field.field_optional()
        |> field.field_label_text(text: "Bio"),
      textarea_config:
        input.textarea_config(value: "Product builder", on_input: on_bio_input),
    )

  let team_field =
    forms.field_select(
      theme: theme,
      field_config:
        field.field_config(id: "scratch-team")
        |> field.field_label_text(text: "Team"),
      select_config:
        input.select_config(
          value: "platform",
          on_change: on_team_select,
          options: [
            input.select_option(value: "platform", label: "Platform"),
            input.select_option(value: "design", label: "Design"),
            input.select_option(value: "engineering", label: "Engineering"),
          ],
        ),
    )

  let terms =
    checkbox.checkbox(
      theme: theme,
      config: checkbox.checkbox_config(checked: True, on_toggle: on_terms_toggle),
      label: weft_lustre.text(content: "Opt in to release notes"),
    )

  let density =
    weft_lustre.row(
      attrs: [weft_lustre.styles([weft.spacing(pixels: 12)])],
      children: [
        radio.radio(
          theme: theme,
          config:
            radio.radio_config(
              name: "density",
              value: "compact",
              checked: True,
              on_select: on_density_select,
            ),
          label: weft_lustre.text(content: "Compact"),
        ),
        radio.radio(
          theme: theme,
          config:
            radio.radio_config(
              name: "density",
              value: "comfortable",
              checked: False,
              on_select: on_density_select,
            ),
          label: weft_lustre.text(content: "Comfortable"),
        ),
      ],
    )

  card.card(
    theme: theme,
    attrs: [],
    children: [
      card.card_header(
        theme: theme,
        attrs: [],
        children: [weft_lustre.text(content: "Team profile")],
      ),
      card.card_content(
        theme: theme,
        attrs: [weft_lustre.styles([weft.spacing(pixels: 12)])],
        children: [
          email_field,
          bio_field,
          team_field,
          terms,
          density,
        ],
      ),
    ],
  )
}
EOF

cat > "$SCRATCH_BLOCKS/overlay.gleam" <<'EOF'
import gleam/option
import weft
import weft_lustre
import weft_lustre/overlay
import weft_lustre_ui
import weft_lustre_ui/button
import weft_lustre_ui/card
import weft_lustre_ui/tooltip

fn solved_overlay_position() -> weft.OverlaySolution {
  weft.solve_overlay(
    problem:
      weft.overlay_problem(
        anchor: weft.rect(x: 120, y: 220, width: 220, height: 42),
        overlay: weft.size(width: 250, height: 92),
        viewport: weft.rect(x: 0, y: 0, width: 1280, height: 720),
      )
      |> weft.overlay_prefer_sides(sides: [
        weft.overlay_side_below(),
        weft.overlay_side_above(),
      ])
      |> weft.overlay_alignments(aligns: [weft.overlay_align_center()])
      |> weft.overlay_offset(pixels: 8)
      |> weft.overlay_padding(pixels: 10),
  )
}

pub fn overlay_block(
  theme theme: weft_lustre_ui.Theme,
  on_open_tooltip on_open_tooltip: msg,
) -> weft_lustre.Element(msg) {
  let key = overlay.overlay_key(value: "scratch-overlay")
  let cfg =
    tooltip.tooltip_config(key: key)
    |> tooltip.tooltip_prefer_sides(
      sides: [weft.overlay_side_below(), weft.overlay_side_above()],
    )
    |> tooltip.tooltip_alignments(
      alignments: [weft.overlay_align_center(), weft.overlay_align_start()],
    )
    |> tooltip.tooltip_offset_px(pixels: 10)

  let anchor =
    weft_lustre.el(
      attrs: [
        weft_lustre.styles([weft.padding(pixels: 12)]),
        overlay.overlay_anchor(key: key),
      ],
      child:
        button.button(
          theme: theme,
          config: button.button_config(on_press: on_open_tooltip),
          label: weft_lustre.text(content: "Anchor"),
        ),
    )

  let solved_overlay =
    tooltip.tooltip_overlay(
      theme: theme,
      config: cfg,
      attrs: [weft_lustre.styles([weft.width(length: weft.fixed(length: weft.px(pixels: 260)))])],
      solution: option.Some(solved_overlay_position()),
      content: weft_lustre.text(content: "Anchored overlay with solved placement"),
    )

  let unpositioned_overlay =
    tooltip.tooltip_overlay(
      theme: theme,
      config: cfg,
      attrs: [weft_lustre.styles([weft.width(length: weft.fixed(length: weft.px(pixels: 260)))])],
      solution: option.None,
      content: weft_lustre.text(content: "Unpositioned overlay placeholder"),
    )

  card.card(
    theme: theme,
    attrs: [],
    children: [
      card.card_header(
        theme: theme,
        attrs: [],
        children: [weft_lustre.text(content: "Overlay composition")],
      ),
      card.card_content(
        theme: theme,
        attrs: [weft_lustre.styles([weft.spacing(pixels: 12)])],
        children: [
          weft_lustre.text(content: "Anchor + unpositioned + solved tooltip states:"),
          weft_lustre.row(
            attrs: [weft_lustre.styles([weft.spacing(pixels: 12)])],
            children: [anchor, solved_overlay, unpositioned_overlay],
          ),
        ],
      ),
    ],
  )
}
EOF

cat > "$SCRATCH_BLOCKS/composable.gleam" <<'EOF'
import weft_lustre
import weft
import weft_lustre_ui
import weft_lustre_ui/button
import weft_lustre_ui/card
import weft_lustre_ui/dialog as styled_dialog
import weft_lustre_ui/toast as styled_toast

pub fn modal_and_toast_block(
  theme theme: weft_lustre_ui.Theme,
  on_open_dialog on_open_dialog: msg,
  on_close_dialog on_close_dialog: msg,
  on_show_toast on_show_toast: msg,
  on_toast_dismiss on_toast_dismiss: msg,
  on_reposition_tooltip _on_reposition_tooltip: msg,
  modal_open modal_open: Bool,
  toast_visible toast_visible: Bool,
) -> weft_lustre.Element(msg) {
  let controls =
    weft_lustre.row(
      attrs: [weft_lustre.styles([weft.spacing(pixels: 12)])],
      children: [
        button.button(
          theme: theme,
          config: button.button_config(on_press: on_open_dialog),
          label: weft_lustre.text(content: "Open modal"),
        ),
        button.button(
          theme: theme,
          config: button.button_config(on_press: on_show_toast),
          label: weft_lustre.text(content: "Show toast"),
        ),
      ],
    )

  let modal =
    case modal_open {
      False -> weft_lustre.none()
      True ->
        styled_dialog.dialog(
          theme: theme,
          config:
            styled_dialog.dialog_config(
              root_id: "scratch-modal",
              label: styled_dialog.dialog_label(value: "Scratch modal"),
              on_close: on_close_dialog,
            ),
          content: weft_lustre.column(
            attrs: [],
            children: [
              weft_lustre.text(content: "Modal content shell"),
              button.button(
                theme: theme,
                config: button.button_config(on_press: on_close_dialog),
                label: weft_lustre.text(content: "Close"),
              ),
            ],
          ),
        )
    }

  let toast_item =
    styled_toast.toast(
      theme: theme,
      config: styled_toast.toast_config(on_dismiss: on_toast_dismiss),
      content: weft_lustre.text(content: "Toast in fixed region"),
    )

  let toast_region =
    case toast_visible {
      False -> weft_lustre.none()
      True ->
        styled_toast.toast_region(
          theme: theme,
          corner: styled_toast.toast_corner_bottom_right(),
          children: [toast_item],
        )
    }

  card.card(
    theme: theme,
    attrs: [],
    children: [
      card.card_header(
        theme: theme,
        attrs: [],
        children: [weft_lustre.text(content: "Composed primitives")],
      ),
      card.card_content(
        theme: theme,
        attrs: [weft_lustre.styles([weft.spacing(pixels: 12)])],
        children: [controls, toast_region, modal],
      ),
    ],
  )
}
EOF

cat > "$SCRATCH_BLOCKS/navigation.gleam" <<'EOF'
import weft
import weft_lustre
import weft_lustre_ui
import weft_lustre_ui/badge
import weft_lustre_ui/card
import weft_lustre_ui/headless/separator as headless_separator
import weft_lustre_ui/link
import weft_lustre_ui/separator

fn nav_link(
  theme theme: weft_lustre_ui.Theme,
  label label: String,
  href href: String,
) -> weft_lustre.Element(msg) {
  link.link(
    theme: theme,
    config: link.link_config(href: href),
    label: weft_lustre.text(content: label),
  )
}

pub fn navigation_block(theme theme: weft_lustre_ui.Theme) -> weft_lustre.Element(msg) {
  let pills =
    weft_lustre.row(
      attrs: [weft_lustre.styles([weft.spacing(pixels: 8)])],
      children: [
        badge.badge(
          theme: theme,
          config: badge.badge_config() |> badge.badge_variant(
            variant: badge.badge_secondary(),
          ),
          child: weft_lustre.text(content: "v1.0"),
        ),
        badge.badge(
          theme: theme,
          config: badge.badge_config() |> badge.badge_variant(
            variant: badge.badge_outline(),
          ),
          child: weft_lustre.text(content: "shadcn-like"),
        ),
      ],
    )

  let nav =
    weft_lustre.row(
      attrs: [
        weft_lustre.styles([
          weft.spacing(pixels: 16),
          weft.align_items(value: weft.align_items_center()),
        ]),
      ],
      children: [
        nav_link(theme: theme, label: "Overview", href: "/overview"),
        nav_link(theme: theme, label: "Projects", href: "/projects"),
        nav_link(theme: theme, label: "Team", href: "/team"),
        nav_link(theme: theme, label: "Settings", href: "/settings"),
      ],
    )

  card.card(
    theme: theme,
    attrs: [],
    children: [
      card.card_header(
        theme: theme,
        attrs: [],
        children: [weft_lustre.text(content: "App shell")],
      ),
      card.card_content(
        theme: theme,
        attrs: [weft_lustre.styles([weft.spacing(pixels: 12)])],
        children: [
          weft_lustre.row(
            attrs: [weft_lustre.styles([weft.justify_content(value: weft.justify_space_between())])],
            children: [
              weft_lustre.column(
                attrs: [weft_lustre.styles([weft.spacing(pixels: 4)])],
                children: [
                  weft_lustre.text(content: "weft_lustre_ui"),
                  weft_lustre.text(content: "ShadCN-inspired component composition"),
                ],
              ),
              pills,
            ],
          ),
          separator.separator(
            theme: theme,
            config: headless_separator.separator_config()
            |> headless_separator.separator_orientation(
              orientation: headless_separator.separator_horizontal(),
            ),
          ),
          nav,
        ],
      ),
    ],
  )
}
EOF

cat > "$SCRATCH_BLOCKS/listing.gleam" <<'EOF'
import gleam/list
import weft
import weft_lustre
import weft_lustre_ui
import weft_lustre_ui/badge
import weft_lustre_ui/button
import weft_lustre_ui/card
import weft_lustre_ui/link

type ListingRow {
  ListingRow(
    title: String,
    owner: String,
    status: String,
    variant: badge.BadgeVariant,
    action_text: String,
    href: String,
  )
}

fn listing_row(
  theme theme: weft_lustre_ui.Theme,
  row row: ListingRow,
) -> weft_lustre.Element(msg) {
  let status_badge =
    badge.badge(
      theme: theme,
      config: badge.badge_config() |> badge.badge_variant(variant: row.variant),
      child: weft_lustre.text(content: row.status),
    )

  let link_target =
    link.link(
      theme: theme,
      config: link.link_config(href: row.href),
      label: weft_lustre.text(content: row.action_text),
    )

  weft_lustre.row(
    attrs: [weft_lustre.styles([weft.justify_content(value: weft.justify_space_between())])],
    children: [
      weft_lustre.column(
        attrs: [weft_lustre.styles([weft.spacing(pixels: 2)])],
        children: [
          weft_lustre.text(content: row.title),
          weft_lustre.text(content: row.owner),
        ],
      ),
      status_badge,
      link_target,
    ],
  )
}

pub fn listing_block(
  theme theme: weft_lustre_ui.Theme,
  on_view on_view: msg,
) -> weft_lustre.Element(msg) {
  let rows =
    [
      ListingRow(
        title: "Design system",
        owner: "Ada Lovelace • 2h",
        status: "Active",
        variant: badge.badge_secondary(),
        action_text: "View",
        href: "/projects/design-system",
      ),
      ListingRow(
        title: "Checkout flow",
        owner: "Lovelace Labs • 4h",
        status: "Blocked",
        variant: badge.badge_destructive(),
        action_text: "Review",
        href: "/projects/checkout-flow",
      ),
      ListingRow(
        title: "Reporting dashboard",
        owner: "Ops Team • 7m",
        status: "Review",
        variant: badge.badge_ghost(),
        action_text: "Open",
        href: "/projects/dashboard",
      ),
    ]

  let cta =
    button.button(
      theme: theme,
      config: button.button_config(on_press: on_view),
      label: weft_lustre.text(content: "Open full table"),
    )

  card.card(
    theme: theme,
    attrs: [],
    children: [
      card.card_header(
        theme: theme,
        attrs: [],
        children: [weft_lustre.text(content: "Recent Workloads")],
      ),
      card.card_content(
        theme: theme,
        attrs: [weft_lustre.styles([weft.spacing(pixels: 12)])],
        children: list.map(rows, listing_row(theme: theme, row: _)),
      ),
      card.card_footer(
        theme: theme,
        attrs: [weft_lustre.styles([weft.align_items(value: weft.align_items_center())])],
        children: [cta],
      ),
    ],
  )
}
EOF
 

cat > "$SCRATCH_DIR/index.html" <<EOF
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>weft_lustre_ui Scratch</title>
    <style>
      :root {
        font-family: Inter, system-ui, -apple-system, Segoe UI, sans-serif;
      }

      body {
        margin: 0;
      }

      #app {
        min-height: 100vh;
      }
    </style>
  </head>
  <body>
    <main id="app"></main>
    <script type="module">
      import { main } from "./build/dev/javascript/$PACKAGE_NAME/main.mjs";
      main();
    </script>
  </body>
</html>
EOF

cat > "$SCRATCH_DIR/.gitignore" <<'EOF'
# Keep generated artifacts out of scratch commits
/build
/.gleam/
/manifest.toml
EOF

if [ "$BUILD" -eq 1 ]; then
  echo "Building JavaScript bundle for scratch app..."
  (cd "$SCRATCH_DIR" && gleam build --target javascript)
fi

echo "Created scratch workspace at: $SCRATCH_DIR"
echo "Run with: bash scripts/dev/scratch-demo.sh [options] [path]"

if [ "$SERVE" -eq 0 ]; then
  echo
  echo "Serve disabled. Open:"
  echo "  http://${HOST}:${PORT}/index.html"
  echo "same-origin by default, so browser requests do not need CORS headers."
  exit 0
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required for serving. Install Python or rerun with --no-serve." >&2
  exit 1
fi

SERVER_URL="http://${HOST}:${PORT}/index.html"
echo "Starting local preview server at ${SERVER_URL}"
echo "same-origin behavior: index and JavaScript are loaded from the same host/path."

if [ "$OPEN_BROWSER" -eq 1 ]; then
  if command -v open >/dev/null 2>&1; then
    open "$SERVER_URL"
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$SERVER_URL"
  fi
fi

(cd "$SCRATCH_DIR" && exec python3 -m http.server "$PORT" --bind "$HOST")
