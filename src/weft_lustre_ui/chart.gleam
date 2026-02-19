//// Styled chart component for weft_lustre_ui.

import weft
import weft_lustre
import weft_lustre_ui/headless/chart as headless_chart
import weft_lustre_ui/theme

/// Styled chart datum alias.
pub type ChartDatum =
  headless_chart.ChartDatum

/// Styled chart configuration alias.
pub type ChartConfig(msg) =
  headless_chart.ChartConfig(msg)

/// Construct chart datum.
pub fn chart_datum(label label: String, value value: Int) -> ChartDatum {
  headless_chart.chart_datum(label: label, value: value)
}

/// Construct chart datum with explicit primary and secondary series values.
pub fn chart_datum_series(
  label label: String,
  primary primary: Int,
  secondary secondary: Int,
) -> ChartDatum {
  headless_chart.chart_datum_series(
    label: label,
    primary: primary,
    secondary: secondary,
  )
}

/// Construct chart configuration.
pub fn chart_config() -> ChartConfig(msg) {
  headless_chart.chart_config()
}

/// Append chart attributes.
pub fn chart_attrs(
  config config: ChartConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ChartConfig(msg) {
  headless_chart.chart_attrs(config: config, attrs: attrs)
}

fn styles(theme theme: theme.Theme) -> List(weft.Attribute) {
  [
    weft.font_family(families: theme.font_families(theme)),
    weft.font_size(size: weft.rem(rem: 0.8125)),
  ]
}

/// Render a styled chart.
pub fn chart(
  theme theme: theme.Theme,
  config config: ChartConfig(msg),
  data data: List(ChartDatum),
) -> weft_lustre.Element(msg) {
  headless_chart.chart(
    config: headless_chart.chart_attrs(config: config, attrs: [
      weft_lustre.styles(styles(theme: theme)),
    ]),
    data: data,
  )
}
