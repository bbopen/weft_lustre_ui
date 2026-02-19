//// Headless calendar surface for weft_lustre_ui.

import gleam/list
import weft
import weft_lustre

/// A calendar day cell.
pub opaque type CalendarDay {
  CalendarDay(label: String, selected: Bool)
}

/// Construct a calendar day.
pub fn calendar_day(label label: String) -> CalendarDay {
  CalendarDay(label: label, selected: False)
}

/// Mark a day as selected.
pub fn calendar_day_selected(day day: CalendarDay) -> CalendarDay {
  CalendarDay(..day, selected: True)
}

/// Calendar configuration.
pub opaque type CalendarConfig(msg) {
  CalendarConfig(
    attrs: List(weft_lustre.Attribute(msg)),
    week_days: List(String),
  )
}

/// Construct calendar configuration.
pub fn calendar_config() -> CalendarConfig(msg) {
  CalendarConfig(attrs: [], week_days: [
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun",
  ])
}

/// Override week day labels.
pub fn calendar_week_days(
  config config: CalendarConfig(msg),
  labels labels: List(String),
) -> CalendarConfig(msg) {
  CalendarConfig(..config, week_days: labels)
}

/// Append calendar attributes.
pub fn calendar_attrs(
  config config: CalendarConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> CalendarConfig(msg) {
  case config {
    CalendarConfig(attrs: existing, ..) ->
      CalendarConfig(..config, attrs: list.append(existing, attrs))
  }
}

fn day_cell(day: CalendarDay) -> weft_lustre.Element(msg) {
  case day {
    CalendarDay(label:, selected:) ->
      weft_lustre.el(
        attrs: [
          weft_lustre.styles([
            weft.width(length: weft.fixed(length: weft.pct(pct: 100.0))),
            weft.padding(pixels: 6),
            weft.rounded(radius: weft.px(pixels: 6)),
            weft.text_align(align: weft.text_align_center()),
            case selected {
              True ->
                weft.background(color: weft.rgb(red: 37, green: 99, blue: 235))
              False ->
                weft.background(color: weft.rgba(
                  red: 0,
                  green: 0,
                  blue: 0,
                  alpha: 0.0,
                ))
            },
            case selected {
              True ->
                weft.text_color(color: weft.rgb(red: 255, green: 255, blue: 255))
              False ->
                weft.text_color(color: weft.rgb(red: 17, green: 24, blue: 39))
            },
          ]),
        ],
        child: weft_lustre.text(content: label),
      )
  }
}

/// Render headless calendar grid.
pub fn calendar(
  config config: CalendarConfig(msg),
  days days: List(CalendarDay),
) -> weft_lustre.Element(msg) {
  case config {
    CalendarConfig(attrs: attrs, week_days: week_days) ->
      weft_lustre.column(
        attrs: [
          weft_lustre.styles([
            weft.width(length: weft.fixed(length: weft.pct(pct: 100.0))),
          ]),
          ..attrs
        ],
        children: [
          weft_lustre.grid(
            attrs: [
              weft_lustre.styles([
                weft.width(length: weft.fixed(length: weft.pct(pct: 100.0))),
                weft.grid_columns(tracks: [
                  weft.grid_repeat(count: 7, track: weft.grid_fr(fr: 1.0)),
                ]),
                weft.spacing(pixels: 6),
              ]),
            ],
            children: list.map(week_days, fn(d) { weft_lustre.text(content: d) }),
          ),
          weft_lustre.grid(
            attrs: [
              weft_lustre.styles([
                weft.width(length: weft.fixed(length: weft.pct(pct: 100.0))),
                weft.grid_columns(tracks: [
                  weft.grid_repeat(count: 7, track: weft.grid_fr(fr: 1.0)),
                ]),
                weft.spacing(pixels: 6),
              ]),
            ],
            children: list.map(days, day_cell),
          ),
        ],
      )
  }
}
