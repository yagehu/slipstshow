#import "../src/lib.typ": *

#show: slipstshow.with()

= Presentation

#lorem(50):
#pause

#lorem(120)

#lorem(100)
#pause


#lorem(120)

#pause

#slips(
  anchor: <slips>,
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
