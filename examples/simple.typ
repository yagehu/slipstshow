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
    #pause

    == The Research Problem <0>

    #up(<0>)
    #pause

    #lorem(20)

    #up(<0>)

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

#pause

#lorem(100)

#pause
