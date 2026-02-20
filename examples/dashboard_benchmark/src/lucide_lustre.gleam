import lustre/attribute.{type Attribute, attribute}
import lustre/element/svg

pub fn grip_vertical(attributes: List(Attribute(a))) {
  svg.svg(
    [
      attribute("stroke-linejoin", "round"),
      attribute("stroke-linecap", "round"),
      attribute("stroke-width", "2"),
      attribute("stroke", "currentColor"),
      attribute("fill", "none"),
      attribute("viewBox", "0 0 24 24"),
      attribute("height", "24"),
      attribute("width", "24"),
      ..attributes
    ],
    [
      svg.circle([
        attribute("r", "1"),
        attribute("cy", "12"),
        attribute("cx", "9"),
      ]),
      svg.circle([
        attribute("r", "1"),
        attribute("cy", "5"),
        attribute("cx", "9"),
      ]),
      svg.circle([
        attribute("r", "1"),
        attribute("cy", "19"),
        attribute("cx", "9"),
      ]),
      svg.circle([
        attribute("r", "1"),
        attribute("cy", "12"),
        attribute("cx", "15"),
      ]),
      svg.circle([
        attribute("r", "1"),
        attribute("cy", "5"),
        attribute("cx", "15"),
      ]),
      svg.circle([
        attribute("r", "1"),
        attribute("cy", "19"),
        attribute("cx", "15"),
      ]),
    ],
  )
}

pub fn circle_check_big(attributes: List(Attribute(a))) {
  svg.svg(
    [
      attribute("stroke-linejoin", "round"),
      attribute("stroke-linecap", "round"),
      attribute("stroke-width", "2"),
      attribute("stroke", "currentColor"),
      attribute("fill", "none"),
      attribute("viewBox", "0 0 24 24"),
      attribute("height", "24"),
      attribute("width", "24"),
      ..attributes
    ],
    [
      svg.path([attribute("d", "M21.801 10A10 10 0 1 1 17 3.335")]),
      svg.path([attribute("d", "m9 11 3 3L22 4")]),
    ],
  )
}

pub fn loader(attributes: List(Attribute(a))) {
  svg.svg(
    [
      attribute("stroke-linejoin", "round"),
      attribute("stroke-linecap", "round"),
      attribute("stroke-width", "2"),
      attribute("stroke", "currentColor"),
      attribute("fill", "none"),
      attribute("viewBox", "0 0 24 24"),
      attribute("height", "24"),
      attribute("width", "24"),
      ..attributes
    ],
    [
      svg.path([attribute("d", "M12 2v4")]),
      svg.path([attribute("d", "m16.2 7.8 2.9-2.9")]),
      svg.path([attribute("d", "M18 12h4")]),
      svg.path([attribute("d", "m16.2 16.2 2.9 2.9")]),
      svg.path([attribute("d", "M12 18v4")]),
      svg.path([attribute("d", "m4.9 19.1 2.9-2.9")]),
      svg.path([attribute("d", "M2 12h4")]),
      svg.path([attribute("d", "m4.9 4.9 2.9 2.9")]),
    ],
  )
}

pub fn chevron_down(attributes: List(Attribute(a))) {
  svg.svg(
    [
      attribute("stroke-linejoin", "round"),
      attribute("stroke-linecap", "round"),
      attribute("stroke-width", "2"),
      attribute("stroke", "currentColor"),
      attribute("fill", "none"),
      attribute("viewBox", "0 0 24 24"),
      attribute("height", "24"),
      attribute("width", "24"),
      ..attributes
    ],
    [svg.path([attribute("d", "m6 9 6 6 6-6")])],
  )
}

pub fn ellipsis_vertical(attributes: List(Attribute(a))) {
  svg.svg(
    [
      attribute("stroke-linejoin", "round"),
      attribute("stroke-linecap", "round"),
      attribute("stroke-width", "2"),
      attribute("stroke", "currentColor"),
      attribute("fill", "none"),
      attribute("viewBox", "0 0 24 24"),
      attribute("height", "24"),
      attribute("width", "24"),
      ..attributes
    ],
    [
      svg.circle([
        attribute("r", "1"),
        attribute("cy", "12"),
        attribute("cx", "12"),
      ]),
      svg.circle([
        attribute("r", "1"),
        attribute("cy", "5"),
        attribute("cx", "12"),
      ]),
      svg.circle([
        attribute("r", "1"),
        attribute("cy", "19"),
        attribute("cx", "12"),
      ]),
    ],
  )
}

pub fn chevron_left(attributes: List(Attribute(a))) {
  svg.svg(
    [
      attribute("stroke-linejoin", "round"),
      attribute("stroke-linecap", "round"),
      attribute("stroke-width", "2"),
      attribute("stroke", "currentColor"),
      attribute("fill", "none"),
      attribute("viewBox", "0 0 24 24"),
      attribute("height", "24"),
      attribute("width", "24"),
      ..attributes
    ],
    [svg.path([attribute("d", "m15 18-6-6 6-6")])],
  )
}

pub fn chevron_right(attributes: List(Attribute(a))) {
  svg.svg(
    [
      attribute("stroke-linejoin", "round"),
      attribute("stroke-linecap", "round"),
      attribute("stroke-width", "2"),
      attribute("stroke", "currentColor"),
      attribute("fill", "none"),
      attribute("viewBox", "0 0 24 24"),
      attribute("height", "24"),
      attribute("width", "24"),
      ..attributes
    ],
    [svg.path([attribute("d", "m9 18 6-6-6-6")])],
  )
}

pub fn table(attributes: List(Attribute(a))) {
  svg.svg(
    [
      attribute("stroke-linejoin", "round"),
      attribute("stroke-linecap", "round"),
      attribute("stroke-width", "2"),
      attribute("stroke", "currentColor"),
      attribute("fill", "none"),
      attribute("viewBox", "0 0 24 24"),
      attribute("height", "24"),
      attribute("width", "24"),
      ..attributes
    ],
    [
      svg.path([attribute("d", "M12 3v18")]),
      svg.rect([
        attribute("rx", "2"),
        attribute("y", "3"),
        attribute("x", "3"),
        attribute("height", "18"),
        attribute("width", "18"),
      ]),
      svg.path([attribute("d", "M3 9h18")]),
      svg.path([attribute("d", "M3 15h18")]),
    ],
  )
}

pub fn plus(attributes: List(Attribute(a))) {
  svg.svg(
    [
      attribute("stroke-linejoin", "round"),
      attribute("stroke-linecap", "round"),
      attribute("stroke-width", "2"),
      attribute("stroke", "currentColor"),
      attribute("fill", "none"),
      attribute("viewBox", "0 0 24 24"),
      attribute("height", "24"),
      attribute("width", "24"),
      ..attributes
    ],
    [
      svg.path([attribute("d", "M5 12h14")]),
      svg.path([attribute("d", "M12 5v14")]),
    ],
  )
}

pub fn radar(attributes: List(Attribute(a))) {
  svg.svg(
    [
      attribute("stroke-linejoin", "round"),
      attribute("stroke-linecap", "round"),
      attribute("stroke-width", "2"),
      attribute("stroke", "currentColor"),
      attribute("fill", "none"),
      attribute("viewBox", "0 0 24 24"),
      attribute("height", "24"),
      attribute("width", "24"),
      ..attributes
    ],
    [
      svg.path([attribute("d", "M19.07 4.93A10 10 0 0 0 6.99 3.34")]),
      svg.path([attribute("d", "M4 6h.01")]),
      svg.path([attribute("d", "M2.29 9.62A10 10 0 1 0 21.31 8.35")]),
      svg.path([attribute("d", "M16.24 7.76A6 6 0 1 0 8.23 16.67")]),
      svg.path([attribute("d", "M12 18h.01")]),
      svg.path([attribute("d", "M17.99 11.66A6 6 0 0 1 15.77 16.67")]),
      svg.circle([
        attribute("r", "2"),
        attribute("cy", "12"),
        attribute("cx", "12"),
      ]),
      svg.path([attribute("d", "m13.41 10.59 5.66-5.66")]),
    ],
  )
}

pub fn globe(attributes: List(Attribute(a))) {
  svg.svg(
    [
      attribute("stroke-linejoin", "round"),
      attribute("stroke-linecap", "round"),
      attribute("stroke-width", "2"),
      attribute("stroke", "currentColor"),
      attribute("fill", "none"),
      attribute("viewBox", "0 0 24 24"),
      attribute("height", "24"),
      attribute("width", "24"),
      ..attributes
    ],
    [
      svg.circle([
        attribute("r", "10"),
        attribute("cy", "12"),
        attribute("cx", "12"),
      ]),
      svg.path([
        attribute("d", "M12 2a14.5 14.5 0 0 0 0 20 14.5 14.5 0 0 0 0-20"),
      ]),
      svg.path([attribute("d", "M2 12h20")]),
    ],
  )
}

pub fn circle_plus(attributes: List(Attribute(a))) {
  svg.svg(
    [
      attribute("stroke-linejoin", "round"),
      attribute("stroke-linecap", "round"),
      attribute("stroke-width", "2"),
      attribute("stroke", "currentColor"),
      attribute("fill", "none"),
      attribute("viewBox", "0 0 24 24"),
      attribute("height", "24"),
      attribute("width", "24"),
      ..attributes
    ],
    [
      svg.circle([
        attribute("r", "10"),
        attribute("cy", "12"),
        attribute("cx", "12"),
      ]),
      svg.path([attribute("d", "M8 12h8")]),
      svg.path([attribute("d", "M12 8v8")]),
    ],
  )
}

pub fn mail(attributes: List(Attribute(a))) {
  svg.svg(
    [
      attribute("stroke-linejoin", "round"),
      attribute("stroke-linecap", "round"),
      attribute("stroke-width", "2"),
      attribute("stroke", "currentColor"),
      attribute("fill", "none"),
      attribute("viewBox", "0 0 24 24"),
      attribute("height", "24"),
      attribute("width", "24"),
      ..attributes
    ],
    [
      svg.path([attribute("d", "m22 7-8.991 5.727a2 2 0 0 1-2.009 0L2 7")]),
      svg.rect([
        attribute("rx", "2"),
        attribute("height", "16"),
        attribute("width", "20"),
        attribute("y", "4"),
        attribute("x", "2"),
      ]),
    ],
  )
}

pub fn file_text(attributes: List(Attribute(a))) {
  svg.svg(
    [
      attribute("stroke-linejoin", "round"),
      attribute("stroke-linecap", "round"),
      attribute("stroke-width", "2"),
      attribute("stroke", "currentColor"),
      attribute("fill", "none"),
      attribute("viewBox", "0 0 24 24"),
      attribute("height", "24"),
      attribute("width", "24"),
      ..attributes
    ],
    [
      svg.path([
        attribute(
          "d",
          "M6 22a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h8a2.4 2.4 0 0 1 1.704.706l3.588 3.588A2.4 2.4 0 0 1 20 8v12a2 2 0 0 1-2 2z",
        ),
      ]),
      svg.path([attribute("d", "M14 2v5a1 1 0 0 0 1 1h5")]),
      svg.path([attribute("d", "M10 9H8")]),
      svg.path([attribute("d", "M16 13H8")]),
      svg.path([attribute("d", "M16 17H8")]),
    ],
  )
}

pub fn folder(attributes: List(Attribute(a))) {
  svg.svg(
    [
      attribute("stroke-linejoin", "round"),
      attribute("stroke-linecap", "round"),
      attribute("stroke-width", "2"),
      attribute("stroke", "currentColor"),
      attribute("fill", "none"),
      attribute("viewBox", "0 0 24 24"),
      attribute("height", "24"),
      attribute("width", "24"),
      ..attributes
    ],
    [
      svg.path([
        attribute(
          "d",
          "M20 20a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.9a2 2 0 0 1-1.69-.9L9.6 3.9A2 2 0 0 0 7.93 3H4a2 2 0 0 0-2 2v13a2 2 0 0 0 2 2Z",
        ),
      ]),
    ],
  )
}

pub fn users(attributes: List(Attribute(a))) {
  svg.svg(
    [
      attribute("stroke-linejoin", "round"),
      attribute("stroke-linecap", "round"),
      attribute("stroke-width", "2"),
      attribute("stroke", "currentColor"),
      attribute("fill", "none"),
      attribute("viewBox", "0 0 24 24"),
      attribute("height", "24"),
      attribute("width", "24"),
      ..attributes
    ],
    [
      svg.path([attribute("d", "M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2")]),
      svg.path([attribute("d", "M16 3.128a4 4 0 0 1 0 7.744")]),
      svg.path([attribute("d", "M22 21v-2a4 4 0 0 0-3-3.87")]),
      svg.circle([
        attribute("r", "4"),
        attribute("cy", "7"),
        attribute("cx", "9"),
      ]),
    ],
  )
}

pub fn database(attributes: List(Attribute(a))) {
  svg.svg(
    [
      attribute("stroke-linejoin", "round"),
      attribute("stroke-linecap", "round"),
      attribute("stroke-width", "2"),
      attribute("stroke", "currentColor"),
      attribute("fill", "none"),
      attribute("viewBox", "0 0 24 24"),
      attribute("height", "24"),
      attribute("width", "24"),
      ..attributes
    ],
    [
      svg.ellipse([
        attribute("ry", "3"),
        attribute("rx", "9"),
        attribute("cy", "5"),
        attribute("cx", "12"),
      ]),
      svg.path([attribute("d", "M3 5V19A9 3 0 0 0 21 19V5")]),
      svg.path([attribute("d", "M3 12A9 3 0 0 0 21 12")]),
    ],
  )
}

pub fn ellipsis(attributes: List(Attribute(a))) {
  svg.svg(
    [
      attribute("stroke-linejoin", "round"),
      attribute("stroke-linecap", "round"),
      attribute("stroke-width", "2"),
      attribute("stroke", "currentColor"),
      attribute("fill", "none"),
      attribute("viewBox", "0 0 24 24"),
      attribute("height", "24"),
      attribute("width", "24"),
      ..attributes
    ],
    [
      svg.circle([
        attribute("r", "1"),
        attribute("cy", "12"),
        attribute("cx", "12"),
      ]),
      svg.circle([
        attribute("r", "1"),
        attribute("cy", "12"),
        attribute("cx", "19"),
      ]),
      svg.circle([
        attribute("r", "1"),
        attribute("cy", "12"),
        attribute("cx", "5"),
      ]),
    ],
  )
}

pub fn settings(attributes: List(Attribute(a))) {
  svg.svg(
    [
      attribute("stroke-linejoin", "round"),
      attribute("stroke-linecap", "round"),
      attribute("stroke-width", "2"),
      attribute("stroke", "currentColor"),
      attribute("fill", "none"),
      attribute("viewBox", "0 0 24 24"),
      attribute("height", "24"),
      attribute("width", "24"),
      ..attributes
    ],
    [
      svg.path([
        attribute(
          "d",
          "M9.671 4.136a2.34 2.34 0 0 1 4.659 0 2.34 2.34 0 0 0 3.319 1.915 2.34 2.34 0 0 1 2.33 4.033 2.34 2.34 0 0 0 0 3.831 2.34 2.34 0 0 1-2.33 4.033 2.34 2.34 0 0 0-3.319 1.915 2.34 2.34 0 0 1-4.659 0 2.34 2.34 0 0 0-3.32-1.915 2.34 2.34 0 0 1-2.33-4.033 2.34 2.34 0 0 0 0-3.831A2.34 2.34 0 0 1 6.35 6.051a2.34 2.34 0 0 0 3.319-1.915",
        ),
      ]),
      svg.circle([
        attribute("r", "3"),
        attribute("cy", "12"),
        attribute("cx", "12"),
      ]),
    ],
  )
}

pub fn search(attributes: List(Attribute(a))) {
  svg.svg(
    [
      attribute("stroke-linejoin", "round"),
      attribute("stroke-linecap", "round"),
      attribute("stroke-width", "2"),
      attribute("stroke", "currentColor"),
      attribute("fill", "none"),
      attribute("viewBox", "0 0 24 24"),
      attribute("height", "24"),
      attribute("width", "24"),
      ..attributes
    ],
    [
      svg.path([attribute("d", "m21 21-4.34-4.34")]),
      svg.circle([
        attribute("r", "8"),
        attribute("cy", "11"),
        attribute("cx", "11"),
      ]),
    ],
  )
}

pub fn sun(attributes: List(Attribute(a))) {
  svg.svg(
    [
      attribute("stroke-linejoin", "round"),
      attribute("stroke-linecap", "round"),
      attribute("stroke-width", "2"),
      attribute("stroke", "currentColor"),
      attribute("fill", "none"),
      attribute("viewBox", "0 0 24 24"),
      attribute("height", "24"),
      attribute("width", "24"),
      ..attributes
    ],
    [
      svg.circle([
        attribute("r", "4"),
        attribute("cy", "12"),
        attribute("cx", "12"),
      ]),
      svg.path([attribute("d", "M12 2v2")]),
      svg.path([attribute("d", "M12 20v2")]),
      svg.path([attribute("d", "m4.93 4.93 1.41 1.41")]),
      svg.path([attribute("d", "m17.66 17.66 1.41 1.41")]),
      svg.path([attribute("d", "M2 12h2")]),
      svg.path([attribute("d", "M20 12h2")]),
      svg.path([attribute("d", "m6.34 17.66-1.41 1.41")]),
      svg.path([attribute("d", "m19.07 4.93-1.41 1.41")]),
    ],
  )
}

pub fn moon(attributes: List(Attribute(a))) {
  svg.svg(
    [
      attribute("stroke-linejoin", "round"),
      attribute("stroke-linecap", "round"),
      attribute("stroke-width", "2"),
      attribute("stroke", "currentColor"),
      attribute("fill", "none"),
      attribute("viewBox", "0 0 24 24"),
      attribute("height", "24"),
      attribute("width", "24"),
      ..attributes
    ],
    [
      svg.path([
        attribute(
          "d",
          "M20.985 12.486a9 9 0 1 1-9.473-9.472c.405-.022.617.46.402.803a6 6 0 0 0 8.268 8.268c.344-.215.825-.004.803.401",
        ),
      ]),
    ],
  )
}

pub fn chart_bar(attributes: List(Attribute(a))) {
  svg.svg(
    [
      attribute("stroke-linejoin", "round"),
      attribute("stroke-linecap", "round"),
      attribute("stroke-width", "2"),
      attribute("stroke", "currentColor"),
      attribute("fill", "none"),
      attribute("viewBox", "0 0 24 24"),
      attribute("height", "24"),
      attribute("width", "24"),
      ..attributes
    ],
    [
      svg.path([attribute("d", "M3 3v16a2 2 0 0 0 2 2h16")]),
      svg.path([attribute("d", "M7 16h8")]),
      svg.path([attribute("d", "M7 11h12")]),
      svg.path([attribute("d", "M7 6h3")]),
    ],
  )
}

pub fn circle_question_mark(attributes: List(Attribute(a))) {
  svg.svg(
    [
      attribute("stroke-linejoin", "round"),
      attribute("stroke-linecap", "round"),
      attribute("stroke-width", "2"),
      attribute("stroke", "currentColor"),
      attribute("fill", "none"),
      attribute("viewBox", "0 0 24 24"),
      attribute("height", "24"),
      attribute("width", "24"),
      ..attributes
    ],
    [
      svg.circle([
        attribute("r", "10"),
        attribute("cy", "12"),
        attribute("cx", "12"),
      ]),
      svg.path([attribute("d", "M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3")]),
      svg.path([attribute("d", "M12 17h.01")]),
    ],
  )
}
