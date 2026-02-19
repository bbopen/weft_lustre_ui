//// Styled calendar component for weft_lustre_ui.

import weft
import weft_lustre
import weft_lustre_ui/headless/calendar as headless_calendar
import weft_lustre_ui/theme

/// Styled calendar day alias.
pub type CalendarDay =
  headless_calendar.CalendarDay

/// Styled calendar configuration alias.
pub type CalendarConfig(msg) =
  headless_calendar.CalendarConfig(msg)

/// Construct calendar day.
pub fn calendar_day(label label: String) -> CalendarDay {
  headless_calendar.calendar_day(label: label)
}

/// Mark day selected.
pub fn calendar_day_selected(day day: CalendarDay) -> CalendarDay {
  headless_calendar.calendar_day_selected(day: day)
}

/// Construct calendar configuration.
pub fn calendar_config() -> CalendarConfig(msg) {
  headless_calendar.calendar_config()
}

/// Set week day labels.
pub fn calendar_week_days(
  config config: CalendarConfig(msg),
  labels labels: List(String),
) -> CalendarConfig(msg) {
  headless_calendar.calendar_week_days(config: config, labels: labels)
}

/// Append attributes.
pub fn calendar_attrs(
  config config: CalendarConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> CalendarConfig(msg) {
  headless_calendar.calendar_attrs(config: config, attrs: attrs)
}

fn styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  [
    weft.spacing(pixels: 10),
    weft.padding(pixels: 12),
    weft.rounded(radius: theme.radius_md(theme)),
    weft.border(
      width: weft.px(pixels: 1),
      style: weft.border_style_solid(),
      color: theme.border_color(theme),
    ),
    weft.font_family(families: theme.font_families(theme)),
  ]
}

/// Render styled calendar.
pub fn calendar(
  theme theme: theme.Theme,
  config config: CalendarConfig(msg),
  days days: List(CalendarDay),
) -> weft_lustre.Element(msg) {
  headless_calendar.calendar(
    config: headless_calendar.calendar_attrs(config: config, attrs: [
      weft_lustre.styles(styles(theme: theme)),
    ]),
    days: days,
  )
}
