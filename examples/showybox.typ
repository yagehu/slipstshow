#import "@preview/showybox:2.0.4": showybox
#import "@preview/slipstshow:0.1.0": *

#show: slipstshow.with()

= Presentation

#lorem(50)

#pause()

#html.frame(
  block(
    width: 10cm,
    showybox(
      title: "Definition",
      frame: (title-color: oklch(28%, 0.1, 142deg)),
      [Hello world!],
    )
  )
)

#pause()

#slips(
  subslip[
    should go to top #lorem(20) <0>
    #pause(up: <0>)
    #html.frame(
      block(
        width: 10cm,
        showybox(
          title: "Definition",
          frame: (title-color: oklch(28%, 0.1, 142deg)),
          [Hello world!],
        )
      )
    )
    #pause()
  ],
  subslip[
    #lorem(20) <1>
    #pause(up: <1>)

    #slips(
      subslip[
        == Sub-sub slip <2>
        #lorem(30)
        #pause(up: <2>)
      ]
    )
  ],
)
#step
