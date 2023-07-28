|%
::
++  twoc
  |_  =bloq
  ::
  ++  len  (bex bloq)
  ++  msb
    |=  a=@
    ?:  (lth (xeb a) len)
      0
    1
  ::
  ++  add
    |=  [a=@ b=@]
    =/  res  (^add a b)
    ?.  (gth (xeb res) len)
      res 
    =/  rez=@
    (rep 0 (snip (rip [0 1] res)))
    ?:  !(overflow a b rez)
      rez
    ~|('signed int overflow' !!)
  ::
  ++  overflow
    |=  [a=@ b=@ c=@]
    ?|  &(=(0 (msb c)) =(1 (msb a)) =(1 (msb b)))
        &(=(1 (msb c)) =(0 (msb a)) =(0 (msb a)))
    ==
  ::
  ++  mul
  :: https://stackoverflow.com/questions/20793701/how-to-do-two-complement-multiplication-and-division-of-integers
    |=  [a=@ b=@]
    =/  ae  (rep bloq ~[a (extend a)])
    =/  be  (rep bloq ~[b (extend b)])
    =/  c  (cut 0 [0 (^mul 2 len)] (^mul ae be))
    ?:  (lte (xeb c) len)
      c
    ?:  !=((dec (bex len)) (cut 0 [len len] c))
      ~|('signed int overflow' !!)
    (cut 0 [0 len] c)
  ::
  ++  extend
    |=  a=@
    ^-  @
    ?:  =((msb a) 0)
      0
    (dec (bex len))
  ::
  --
--