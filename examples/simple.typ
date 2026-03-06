#import "../src/lib.typ": *

#show: slipstshow.with()

= Presentation

#pause

#lorem(50)

#pause

- #lorem(10)
- #lorem(10)
- #lorem(10)

#pause

#lorem(120)

#pause

#lorem(150)

#pause

$ sum_(k=1)^n k = (n(n+1)) / 2 $

#pause

#lorem(120)

#pause

#slips(
  subslip[
    == The Research Problem

    #lorem(20)

    An inline equation: $E = m c^2$.

    A block equation:

    $
      E = m c^2
    $

    #pause

    #lorem(100)
  ],
  subslip[
    #pause

    #lorem(60)
  ],
)
