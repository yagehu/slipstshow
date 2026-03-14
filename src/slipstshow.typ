#let font-size = 24pt

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

#let _curr_slip = state("curr-slip", [])

#let _fuse(xs, attrs: (:)) = context {
  for x in xs {
    context if x.func() == parbreak {
      _curr_slip.update(d => d + x)
    } else if x.func() == [ ].func() {
      _curr_slip.update(d => d + x)
    } else if (
      x.func() == metadata
        and type(x.value) == dictionary
        and "type" in x.value
        and x.value.type == "slipstshow-step"
    ) {
      let c = _curr_slip.get()

      html.elem(
        "div",
        attrs: (class: "slip", data-slip: str(_counter.get().first())),
        c,
      )
      _curr_slip.update(d => [])
    } else if (
      x.func() == metadata
        and type(x.value) == dictionary
        and "type" in x.value
        and x.value.type == "slipstshow-pause"
    ) {
      let data-slip-up = if x.value.value.up == none { (:) } else {
        let anchor_key = str(x.value.value.up)
        let up-idx = _label_map.get().at(anchor_key, default: -1)

        (data-slip-up: str(up-idx))
      }
      let c = _curr_slip.get()

      html.elem(
        "div",
        attrs: (class: "slip", data-slip: str(_counter.get().first())) + data-slip-up,
        c,
      )
      _curr_slip.update(d => [])
      _counter.step()
    } else if x.func() == math.equation {
      if x.block {
        let c = _curr_slip.get()

        _curr_slip.update(d => [])

        if c != [] {
          html.elem(
            "div",
            attrs: (class: "slip", data-slip: str(_counter.get().first())),
            c,
          )
        }

        html.elem(
          "div",
          attrs: (
            class: "slip equation",
            data-slip: str(_counter.get().first()),
          ),
          x
        )
      } else {
        // Not a block equation.
        _curr_slip.update(d => d + x)
      }
    } else {
      _curr_slip.update(d => d + x)
    }

    if x.has("label") {
      let key = str(x.label)
      let cnt = _counter.get().first()

      _label_map.update(d => { d.insert(key, cnt); d })
    }
  }

  context if (
    (
      _curr_slip.get().has("children")
        and not _curr_slip.get().at("children").all(_should_strip)
    )
      or (
        not _curr_slip.get().has("children")
          and _curr_slip.get() != []
          and not _should_strip(_curr_slip.get())
      )
  ) {
    let c = _curr_slip.get()

    html.elem(
      "div",
      attrs: (class: "slip", data-slip: str(_counter.get().first())) + attrs,
      _curr_slip.get(),
    )
  }
}

#let _traverse(x, attrs: (:)) = context {
  let children = if type(x) == content and x.has("children") {
    x.children.map(_traverse)
  } else if (
    type(x) == content and x.func() == parbreak
      or x == none
  ) {
    [ ]
  } else {
    x
  }

  if (type(children) == content and children.func() == metadata and children.value == "slipstshow-pause") {
    _counter.step()
  }

  if (
    (type(children) == content and children.func() != [ ].func())
      and (type(children) == content and children.func() != array)
      and (type(children) == content and children.func() != metadata)
  ) {
    let el = if children.func() == math.equation {
      html.div(class: "equation", html.frame(block(children)))
    } else {
      block(children)
    }

    html.elem(
      "div",
      attrs: (class: "slip", data-slip: str(_counter.get().first())) + attrs,
      el
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

  _curr_slip.update(d => [])

  html.elem(
    "div",
    attrs: attrs,
    {
      _fuse(body.children)
    }
  )
}

#let slips(columns: auto, ..subslips) = context {
  let columns = if columns == auto {
    subslips.pos().map(it => 1fr)
  } else { columns }
  let frSum = columns.fold(0fr, (acc, fr) => acc + fr)

  if target() == "html" {
    _curr_slip.update(d => [])
    _fuse(
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
    subslips.join()
  }
}

#let slipstshow(body) = context {
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
        html.style(read("../build/slipstshow.css"))
        html.style("
          :root {
            --base-font-size: " + str(font-size.to-absolute().pt()) + "pt;
          }
        ")
        html.script(read("../build/slipstshow.js"), type: "module")
      })

      html.body(html.main(
        html.div(
          id: "view",
          {
            html.div(
              id: "world",
              {
                _fuse(body.children)
                // body.children.map(_traverse).join()
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
    set text(size: font-size)

    body
  }
}
