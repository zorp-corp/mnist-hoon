|%
::
+$  twoc  [bloq=@ data=@]
::
++  msb
  |=  a=tc
  ?:  (lth (xeb data.a) bloq.a)
    0
  1
::
++  add
  |=  [a=twoc b=twoc]
  ?>  =(bloq.a bloq.b)
  =/  res  (^add data.a data.b)
  ?.  (gth (xeb res) bloq.a)
      res 
  =/  rez=twoc  
  :-  bloq.a
  (rep 0 (snip (rip [0 1] res)))
  ?:  !(overflow a b rez)
    rez
  ~|('signed int overflow' !!)
::
++  add-2
  |=  [a=twoc b=twoc]
  ?>  =(bloq.a bloq.b)
  =/  res  (^add data.a data.b)
  =/  len  (xeb res)
  ?.  (gth len bloq.a)
      res 
  =/  rez=twoc
  :-  bloq.a
  (dis (not 0 len (bex (dec len))) res)
  ?:  !(overflow a b rez)
    rez
  ~|('signed int overflow' !!)
::
++  overflow
  |=  [a=twoc b=twoc c=twoc]
  ?|  &(=(0 (msb c)) =(1 (msb a)) =(1 (msb b)))
      &(=(1 (msb c)) =(0 (msb a)) =(0 (msb a)))
  ==
::
++  mul
:: https://stackoverflow.com/questions/20793701/how-to-do-two-complement-multiplication-and-division-of-integers
  |=  [a=twoc b=twoc]
  ^-  twoc
  ?>  =(bloq.a bloq.b)
  =/  ae  (rep [0 bloq.a] ~[data.a (extend a)])
  =/  be  (rep [0 bloq.b] ~[data.b (extend b)])
  =/  c  (cut 0 [0 (^mul 2 bloq.a)] (^mul ae be))
  ?:  (lte (xeb c) bloq.a)
    [bloq.a c]
    ?:  !=((dec (bex bloq.a)) (cut 0 [bloq.a bloq.a] c))
      ~|('signed int overflow' !!)
    [bloq.a (cut 0 [0 bloq.a] c)]
::
++  extend
  |=  a=twoc
  ^-  @
  ?:  =((msb a) 0)
    0
  (dec (bex bloq.a))
--