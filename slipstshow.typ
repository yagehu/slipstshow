#let _counter = counter("slipstshow")
#let _label_map = state("slipstshow-labels", (:))

#let pause(up: none) = if dictionary(std).at("html", default: none) == none {
  parbreak()
} else {
  metadata((
    type: "slipstshow-pause",
    value: (
      up: up,
    ),
  ))
}

#let step = if dictionary(std).at("html", default: none) == none {
  parbreak()
} else {
  metadata((
    type: "slipstshow-step",
    value: none,
  ))
}

#let _should_strip(it) = {
  (
    (type(it) == content and it.func() == parbreak)
      or (type(it) == content and it.func() == [ ].func())
  )
}

#let _strip(slip) = {
  let _ = while _should_strip(slip) {
    slip.remove(0)
  }
  let _ = while _should_strip(slip) {
    slip.pop()
  }

  slip
}

#let _fuse(slip, xs, attrs: (:)) = {
  for x in xs {
    if x.func() == parbreak {
      slip += x
    } else if x.func() == [ ].func() {
      slip += x
    } else if (
      x.func() == metadata
        and type(x.value) == dictionary
        and "type" in x.value
        and x.value.type == "slipstshow-step"
    ) {
      html.elem(
        "div",
        attrs: (class: "slip", data-slip: str(_counter.get().first())),
        slip,
      )
      slip = []
    } else if (
      x.func() == metadata
        and type(x.value) == dictionary
        and "type" in x.value
        and x.value.type == "slipstshow-pause"
    ) {
      context {
        let data-slip-up = if x.value.value.up == none { (:) } else {
          let anchor_key = str(x.value.value.up)
          let up-idx = _label_map.get().at(anchor_key, default: -1)

          (data-slip-up: str(up-idx))
        }

        html.elem(
          "div",
          attrs: (class: "slip", data-slip: str(_counter.get().first())) + data-slip-up,
          slip,
        )
      }
      slip = []
      _counter.step()
    } else if x.func() == math.equation {
      if x.block {
        if slip != [] {
          html.elem(
            "div",
            attrs: (class: "slip", data-slip: str(_counter.get().first())),
            slip,
          )
        }

        slip = []
        html.elem(
          "div",
          attrs: (
            class: "slip equation",
            data-slip: str(_counter.get().first()),
          ),
          x,
        )
      } else {
        // Not a block equation.
        slip += x
      }
    } else {
      slip += x
    }

    context if x.has("label") {
      let key = str(x.label)
      let cnt = _counter.get().first()

      _label_map.update(d => { d.insert(key, cnt); d })
    }
  }

  context if (
    (
      slip.has("children")
        and not slip.at("children").all(_should_strip)
    )
      or (
        not slip.has("children")
          and slip != []
          and not _should_strip(slip)
      )
  ) {
    html.elem(
      "div",
      attrs: (class: "slip", data-slip: str(_counter.get().first())) + attrs,
      slip,
    )
  }
}

#let subslip(body) = (fr) => {
  let attrs = (
    style: "
      flex: " + str(fr) + ";
      font-size: " + str(fr) + "em;
    ",
    data-scale: str(fr),
  )

  if target() == "html" {
    html.elem(
      "div",
      attrs: attrs,
      {
        _fuse([], body.children)
      }
    )
  } else {
    body
  }
}

#let slips(columns: auto, ..subslips) = context {
  let columns = if columns == auto {
    subslips.pos().map(it => 1fr)
  } else { columns }
  let frSum = columns.fold(0fr, (acc, fr) => acc + fr)

  if target() == "html" {
    _fuse(
      [],
      subslips
        .pos()
        .zip(columns)
        .map(pair => {
          let (fn, fr) = pair

          fn(fr / frSum)
        }),
      attrs: (style: "display: flex;"),
    )
  } else {
    subslips.pos().map(fn => fn(1)).join()
  }
}

#let slipstshow(base-font-size: 24pt, body) = context {
  _counter.update(0)

  if target() == "html" {
    show math.equation: it => {
      html.frame(it)
    }
    show math.equation.where(block: false): box

    html.html({
      html.meta(charset: "utf-8")
      html.meta(name: "viewport", content: "width=device-width, initial-scale=1")
      html.head({
        html.style(read("slipstshow.css"))
        html.style("
          :root {
            --base-font-size: " + str(base-font-size.to-absolute().pt()) + "pt;
          }
        ")
        html.script(read("slipstshow.js"), type: "module")
      })

      html.body(html.main(
        html.div(
          id: "view",
          {
            html.div(
              id: "world",
              {
                _fuse([], body.children)
              }
            )
          }
        )
      ))
    })
  } else {
    set page(
      paper: "presentation-16-9",
    )
    set text(size: base-font-size)

    body
  }
}
