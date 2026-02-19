//// Headless chart primitives for weft_lustre_ui.
////
//// This module renders a deterministic SVG trend surface with two stacked
//// areas and hoverable tooltip hotspots for parity checks.

import gleam/float
import gleam/int
import gleam/list
import lustre/attribute
import lustre/element
import weft_lustre

const svg_namespace = "http://www.w3.org/2000/svg"

const xhtml_namespace = "http://www.w3.org/1999/xhtml"

const chart_height = 250.0

const baseline_y = 205.0

const axis_label_y = 242.0

/// A chart datum.
pub opaque type ChartDatum {
  ChartDatum(label: String, value_primary: Int, value_secondary: Int)
}

/// Construct a chart datum.
///
/// `value` maps to the primary series and secondary is derived deterministically.
pub fn chart_datum(label label: String, value value: Int) -> ChartDatum {
  let secondary = case value > 0 {
    True -> value * 7 / 10
    False -> 0
  }

  ChartDatum(label: label, value_primary: value, value_secondary: secondary)
}

/// Construct a chart datum with explicit primary and secondary series values.
pub fn chart_datum_series(
  label label: String,
  primary primary: Int,
  secondary secondary: Int,
) -> ChartDatum {
  ChartDatum(label: label, value_primary: primary, value_secondary: secondary)
}

/// Headless chart configuration.
pub opaque type ChartConfig(msg) {
  ChartConfig(attrs: List(weft_lustre.Attribute(msg)))
}

/// Construct chart configuration.
pub fn chart_config() -> ChartConfig(msg) {
  ChartConfig(attrs: [])
}

/// Append chart attributes.
pub fn chart_attrs(
  config config: ChartConfig(msg),
  attrs attrs: List(weft_lustre.Attribute(msg)),
) -> ChartConfig(msg) {
  case config {
    ChartConfig(attrs: existing) ->
      ChartConfig(attrs: list.append(existing, attrs))
  }
}

type PlotPoint {
  PlotPoint(
    index: Int,
    x: Float,
    y_primary: Float,
    y_secondary: Float,
    label: String,
    value_primary: Int,
    value_secondary: Int,
  )
}

fn clamp_value(value: Int) -> Int {
  case value < 0 {
    True -> 0
    False -> value
  }
}

fn max_total_value(data: List(ChartDatum)) -> Int {
  list.fold(data, 0, fn(max, datum) {
    case datum {
      ChartDatum(value_primary:, value_secondary:, ..) -> {
        let total = clamp_value(value_primary) + clamp_value(value_secondary)
        case total > max {
          True -> total
          False -> max
        }
      }
    }
  })
}

fn scalar(value: Float) -> String {
  float.to_string(value)
}

fn svg_attr(name: String, value: String) -> attribute.Attribute(msg) {
  attribute.attribute(name, value)
}

fn svg_element(
  tag: String,
  attrs: List(attribute.Attribute(msg)),
  children: List(element.Element(msg)),
) -> element.Element(msg) {
  element.namespaced(svg_namespace, tag, attrs, children)
}

fn xhtml_element(
  tag: String,
  attrs: List(attribute.Attribute(msg)),
  children: List(element.Element(msg)),
) -> element.Element(msg) {
  element.namespaced(xhtml_namespace, tag, attrs, children)
}

fn line_path(points: List(#(Float, Float))) -> String {
  case points {
    [] -> ""
    [#(x, y), ..rest] ->
      list.fold(rest, "M " <> scalar(x) <> " " <> scalar(y), fn(path, point) {
        let #(px, py) = point
        path <> " L " <> scalar(px) <> " " <> scalar(py)
      })
  }
}

fn area_path(points: List(#(Float, Float))) -> String {
  case points {
    [] -> ""
    [#(start_x, _), ..] -> {
      let line = line_path(points)
      case list.last(points) {
        Ok(#(end_x, _)) ->
          line
          <> " L "
          <> scalar(end_x)
          <> " "
          <> scalar(baseline_y)
          <> " L "
          <> scalar(start_x)
          <> " "
          <> scalar(baseline_y)
          <> " Z"
        Error(_) -> line
      }
    }
  }
}

fn chart_plot_width(point_count: Int) -> Float {
  let width = case point_count <= 1 {
    True -> 100.0
    False -> int.to_float(point_count - 1) *. 8.0
  }

  case width <. 100.0 {
    True -> 100.0
    False -> width
  }
}

fn chart_step(point_count: Int, plot_width: Float) -> Float {
  case point_count <= 1 {
    True -> 0.0
    False -> plot_width /. int.to_float(point_count - 1)
  }
}

fn build_points(
  data: List(ChartDatum),
  safe_max: Int,
  plot_width: Float,
) -> List(PlotPoint) {
  let count = list.length(data)
  let step = chart_step(count, plot_width)

  list.index_map(data, with: fn(datum, index) {
    case datum {
      ChartDatum(label:, value_primary:, value_secondary:) -> {
        let primary = clamp_value(value_primary)
        let secondary = clamp_value(value_secondary)
        let stacked_total = primary + secondary
        let primary_ratio =
          int.to_float(stacked_total) /. int.to_float(safe_max)
        let secondary_ratio = int.to_float(secondary) /. int.to_float(safe_max)
        let x = int.to_float(index) *. step
        let y_primary = baseline_y -. primary_ratio *. 150.0
        let y_secondary = baseline_y -. secondary_ratio *. 150.0
        PlotPoint(
          index: index,
          x: x,
          y_primary: y_primary,
          y_secondary: y_secondary,
          label: label,
          value_primary: primary,
          value_secondary: secondary,
        )
      }
    }
  })
}

fn label_nodes(points: List(PlotPoint)) -> List(element.Element(msg)) {
  list.fold(points, [], fn(acc, point) {
    case point {
      PlotPoint(x:, label:, ..) ->
        case label == "" {
          True -> acc
          False -> [
            svg_element(
              "text",
              [
                svg_attr("x", scalar(x)),
                svg_attr("y", scalar(axis_label_y)),
                svg_attr("font-size", "10"),
                svg_attr("text-anchor", "middle"),
                svg_attr("fill", "var(--chart-label, #71717a)"),
              ],
              [element.text(label)],
            ),
            ..acc
          ]
        }
    }
  })
  |> list.reverse
}

fn clamp_float(value: Float, min: Float, max: Float) -> Float {
  case max <. min {
    True -> min
    False ->
      case value <. min {
        True -> min
        False ->
          case value >. max {
            True -> max
            False -> value
          }
      }
  }
}

fn tooltip_label(label: String) -> String {
  case label == "" {
    True -> "Visitors"
    False -> label
  }
}

fn default_tooltip_index(point_count: Int) -> Int {
  case point_count <= 0 {
    True -> 0
    False ->
      case point_count <= 7 {
        True -> -1
        False ->
          case point_count > 10 {
            True -> 10
            False -> point_count - 1
          }
      }
  }
}

fn hover_width(point_count: Int, plot_width: Float) -> Float {
  let step = chart_step(point_count, plot_width)

  case step <=. 0.0 {
    True -> 24.0
    False -> clamp_float(step, 14.0, 44.0)
  }
}

fn tooltip_nodes(
  points: List(PlotPoint),
  plot_width: Float,
  point_count: Int,
) -> List(element.Element(msg)) {
  let default_index = default_tooltip_index(point_count)
  let zone_width = hover_width(point_count, plot_width)
  let zone_half = zone_width /. 2.0

  list.map(points, fn(point) {
    case point {
      PlotPoint(
        index: index,
        x: x,
        y_primary: y_primary,
        label: label,
        value_primary: value_primary,
        value_secondary: value_secondary,
        ..,
      ) -> {
        let tooltip_width = 96.0
        let tooltip_height = 44.0
        let tx =
          clamp_float(
            x -. tooltip_width /. 2.0,
            4.0,
            plot_width -. tooltip_width -. 4.0,
          )
        let ty =
          clamp_float(
            y_primary -. 54.0,
            6.0,
            baseline_y -. tooltip_height -. 8.0,
          )

        let hotspot_class = case default_index >= 0 && index == default_index {
          True -> "chart-hotspot chart-hotspot-default"
          False -> "chart-hotspot"
        }
        let zone_x = clamp_float(x -. zone_half, 0.0, plot_width -. zone_width)

        svg_element("g", [svg_attr("class", hotspot_class)], [
          svg_element(
            "rect",
            [
              svg_attr("x", scalar(zone_x)),
              svg_attr("y", "0"),
              svg_attr("width", scalar(zone_width)),
              svg_attr("height", scalar(baseline_y)),
              svg_attr("fill", "transparent"),
              svg_attr("stroke", "transparent"),
              svg_attr("pointer-events", "all"),
            ],
            [],
          ),
          svg_element(
            "circle",
            [
              svg_attr("cx", scalar(x)),
              svg_attr("cy", scalar(y_primary)),
              svg_attr("r", "10"),
              svg_attr("fill", "transparent"),
              svg_attr("stroke", "transparent"),
              svg_attr("pointer-events", "all"),
            ],
            [],
          ),
          svg_element(
            "circle",
            [
              svg_attr("class", "chart-hover-dot"),
              svg_attr("cx", scalar(x)),
              svg_attr("cy", scalar(y_primary)),
              svg_attr("r", "3"),
              svg_attr("fill", "var(--chart-dot, #52525b)"),
            ],
            [],
          ),
          svg_element(
            "foreignObject",
            [
              svg_attr("class", "chart-tooltip-point"),
              svg_attr("x", scalar(tx)),
              svg_attr("y", scalar(ty)),
              svg_attr("width", scalar(tooltip_width)),
              svg_attr("height", scalar(tooltip_height)),
              svg_attr("pointer-events", "none"),
            ],
            [
              xhtml_element(
                "div",
                [
                  attribute.style("width", "100%"),
                  attribute.style("height", "100%"),
                  attribute.style("padding", "6px 8px"),
                  attribute.style(
                    "border",
                    "1px solid var(--chart-tooltip-border, #d4d4d8)",
                  ),
                  attribute.style("border-radius", "8px"),
                  attribute.style(
                    "background",
                    "var(--chart-tooltip-bg, #ffffff)",
                  ),
                  attribute.style("box-sizing", "border-box"),
                ],
                [
                  xhtml_element(
                    "div",
                    [
                      attribute.style("font-size", "10px"),
                      attribute.style("font-weight", "600"),
                      attribute.style(
                        "color",
                        "var(--chart-tooltip-fg, #09090b)",
                      ),
                      attribute.style("line-height", "1.2"),
                    ],
                    [element.text(tooltip_label(label))],
                  ),
                  xhtml_element(
                    "div",
                    [
                      attribute.style("margin-top", "4px"),
                      attribute.style("font-size", "9px"),
                      attribute.style(
                        "color",
                        "var(--chart-tooltip-muted, #3f3f46)",
                      ),
                      attribute.style("line-height", "1.2"),
                    ],
                    [element.text("Mobile " <> int.to_string(value_secondary))],
                  ),
                  xhtml_element(
                    "div",
                    [
                      attribute.style("margin-top", "2px"),
                      attribute.style("font-size", "9px"),
                      attribute.style(
                        "color",
                        "var(--chart-tooltip-muted, #3f3f46)",
                      ),
                      attribute.style("line-height", "1.2"),
                    ],
                    [element.text("Desktop " <> int.to_string(value_primary))],
                  ),
                ],
              ),
            ],
          ),
        ])
      }
    }
  })
}

fn chart_markup(
  points: List(PlotPoint),
  plot_width: Float,
  point_count: Int,
) -> element.Element(msg) {
  let primary_points =
    list.map(points, fn(point) {
      case point {
        PlotPoint(x:, y_primary:, ..) -> #(x, y_primary)
      }
    })
  let secondary_points =
    list.map(points, fn(point) {
      case point {
        PlotPoint(x:, y_secondary:, ..) -> #(x, y_secondary)
      }
    })

  let grid_path =
    "M 0 45 L "
    <> scalar(plot_width)
    <> " 45 M 0 85 L "
    <> scalar(plot_width)
    <> " 85 M 0 125 L "
    <> scalar(plot_width)
    <> " 125 M 0 165 L "
    <> scalar(plot_width)
    <> " 165 M 0 "
    <> scalar(baseline_y)
    <> " L "
    <> scalar(plot_width)
    <> " "
    <> scalar(baseline_y)
  let primary_line = line_path(primary_points)
  let primary_area = area_path(primary_points)
  let secondary_line = line_path(secondary_points)
  let secondary_area = area_path(secondary_points)

  let base_layers = [
    svg_element("style", [], [
      element.text(
        ".chart-hotspot .chart-hover-dot { display: none; }"
        <> ".chart-hotspot .chart-tooltip-point { display: none; }"
        <> ".chart-hotspot:hover .chart-hover-dot { display: block; }"
        <> ".chart-hotspot:hover .chart-tooltip-point { display: block; }"
        <> ".chart-hotspot-default .chart-hover-dot { display: block; }"
        <> ".chart-hotspot-default .chart-tooltip-point { display: block; }"
        <> ".chart-surface:hover .chart-hotspot-default .chart-hover-dot { display: none; }"
        <> ".chart-surface:hover .chart-hotspot-default .chart-tooltip-point { display: none; }",
      ),
    ]),
    svg_element(
      "path",
      [
        svg_attr("d", grid_path),
        svg_attr("stroke", "var(--chart-grid, #e4e4e7)"),
        svg_attr("fill", "none"),
        svg_attr("stroke-width", "1"),
      ],
      [],
    ),
    svg_element(
      "path",
      [
        svg_attr("d", secondary_area),
        svg_attr("fill", "var(--chart-mobile-fill, rgba(161,161,170,0.24))"),
      ],
      [],
    ),
    svg_element(
      "path",
      [
        svg_attr("d", secondary_line),
        svg_attr("stroke", "var(--chart-mobile-line, #a1a1aa)"),
        svg_attr("fill", "none"),
        svg_attr("stroke-width", "2"),
      ],
      [],
    ),
    svg_element(
      "path",
      [
        svg_attr("d", primary_area),
        svg_attr("fill", "var(--chart-desktop-fill, rgba(113,113,122,0.32))"),
      ],
      [],
    ),
    svg_element(
      "path",
      [
        svg_attr("d", primary_line),
        svg_attr("stroke", "var(--chart-desktop-line, #71717a)"),
        svg_attr("fill", "none"),
        svg_attr("stroke-width", "3"),
      ],
      [],
    ),
  ]

  let layers =
    base_layers
    |> list.append(label_nodes(points))
    |> list.append(tooltip_nodes(points, plot_width, point_count))

  let main_svg =
    svg_element(
      "svg",
      [
        svg_attr(
          "viewBox",
          "0 0 " <> scalar(plot_width) <> " " <> scalar(chart_height),
        ),
        svg_attr("width", "100%"),
        svg_attr("height", "100%"),
        svg_attr("preserveAspectRatio", "none"),
        svg_attr("role", "img"),
        svg_attr("aria-label", "Visitors trend"),
        svg_attr("class", "chart-surface"),
        attribute.style("display", "block"),
      ],
      layers,
    )

  let aux_svg =
    svg_element(
      "svg",
      [
        svg_attr("viewBox", "0 0 1 1"),
        svg_attr("width", "0"),
        svg_attr("height", "0"),
        svg_attr("aria-hidden", "true"),
      ],
      [],
    )

  element.element(
    "div",
    [
      attribute.attribute("data-slot", "chart"),
      attribute.style("position", "relative"),
      attribute.style("width", "100%"),
      attribute.style("height", "100%"),
    ],
    [main_svg, aux_svg],
  )
}

/// Render a headless SVG trend chart.
pub fn chart(
  config config: ChartConfig(msg),
  data data: List(ChartDatum),
) -> weft_lustre.Element(msg) {
  let point_count = list.length(data)
  let plot_width = chart_plot_width(point_count)
  let safe_max = case max_total_value(data) <= 0 {
    True -> 1
    False -> max_total_value(data)
  }
  let points = build_points(data, safe_max, plot_width)

  case config {
    ChartConfig(attrs: attrs) ->
      weft_lustre.el(
        attrs: attrs,
        child: weft_lustre.html(chart_markup(points, plot_width, point_count)),
      )
  }
}
