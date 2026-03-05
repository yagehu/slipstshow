#let font-size = 18pt

#let _counter = counter("slipstshow")

#let pause = if dictionary(std).at("html", default: none) == none {
  parbreak()
} else {
  metadata("slipstshow-pause")
}

#let up(label, offset: 0) = metadata((slipstshow-action: (up: label, offset: offset)))


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

#let _fuse(xs) = context {
  let currSlip = []

  for x in xs {
    if x.func() == parbreak {
      if currSlip != [] {
        context html.elem(
          "div",
          attrs: (class: "slip", data-slip: str(_counter.get().first())),
          currSlip
        )
      }

      currSlip = []
    } else if x.func() == metadata and x.value == "slipstshow-pause" {
      _counter.step()

      if currSlip != [] {
        context html.elem(
          "div",
          attrs: (class: "slip", data-slip: str(_counter.get().first())),
          currSlip
        )
      }

      currSlip = []
    } else if x.func() == math.equation {
      if x.block {
        if currSlip != [] {
          context html.elem(
            "div",
            attrs: (class: "slip", data-slip: str(_counter.get().first())),
            currSlip
          )

          currSlip = []
        }

        context html.elem(
          "div",
          attrs: (
            class: "slip equation",
            data-slip: str(_counter.get().first()),
          ),
          x
        )
      } else {
        // Not a block equation.
        currSlip += x
      }
    } else {
      currSlip += x
    }
  }

  if currSlip != [] {
    context html.elem(
      "div",
      attrs: (class: "slip", data-slip: str(_counter.get().first())),
      currSlip
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
    html.div(
      style: "
        display: flex;
      ",
      {
        subslips
          .pos()
          .zip(columns)
          .map(pair => {
            let (fn, fr) = pair

            fn(fr / frSum)
          })
          .join()
      }
    )
  }
}

#let slipstshow(body) = context {
  _counter.update(0)

  if target() == "html" {
    show math.equation: it => context {
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
