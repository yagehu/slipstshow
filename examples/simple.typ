#import "@preview/slipstshow:0.1.0": *

#show: slipstshow.with()

= Presentation

#pause()

#lorem(50)

#pause()

- #lorem(10)
- #lorem(10)
- #lorem(10)

#pause()

#lorem(120)

#pause()

#lorem(150)

#pause()

$ sum_(k=1)^n k = (n(n+1)) / 2 $

#pause()

#lorem(120)

#pause()

#slips(
  subslip[

    == The Research Problem <0>

    #pause(up: <0>)

    #lorem(20)

    An inline equation: $E = m c^2$.

    A block equation:

    $
      E = m c^2
    $

    #pause()

    #lorem(100)

    #pause()
  ],
  subslip[
    #metadata("dummy") <1>
    #lorem(60)
    #pause(up: <1>)
  ],
)
#step

haha #lorem(101)

#pause()

#lorem(200)
