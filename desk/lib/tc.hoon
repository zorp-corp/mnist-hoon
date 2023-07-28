/+  lagoon
|%
::  Bitwise twos complement - slow!
::
++  tc  
  |%
::
  ++  atom-to-2c
  |=  a=@
  (rip [0 1] a)
::
  ++  one
  |=  len=@
  ^-  (list @)
  (snap (fill len 0) 0 1)
::
  ++  fill
  |=  [len=@ a=@]
  ^-  (list @)
  =/  i  0
  |-
  ?:  (gte i len)
    ~
  [a $(i +(i))] 
::
  ++  msb
  |=  a=(list @)
  (rear a) 
::
  ++  lsb
  |=  a=(list @)
  (rear (flop a))
:: 
  ++  soo          :: +soo: binary addition
  |=  [a=(list @) b=(list @)]
  ?>  =((lent a) (lent b))
  =/  i  0
  =/  carry  0
  |-
  ?:  =(i (lent a))
    ?:  !=(carry 0)  :: TODO check len to make sure there's no overflow.
      [1 ~]
    ~
  =/  r  carry
  =/  ai  (snag i a)
  =/  bi  (snag i b)
  =.  r  ?:(=(1 ai) +(r) r)
  =.  r  ?:(=(1 bi) +(r) r)
  =/  res
    ?:  =(1 (mod r 2))
      1
    0
  [res $(i +(i), carry ?:((lth r 2) 0 1))]
::
  ++  son         ::  +son: signed int addition
  |=  [a=(list @) b=(list @)]
  =/  res  (soo a b)
  ?.  (gth (lent res) (lent a))
    [(lent a) res]
  =/  rez  (snip res)
  ?:  &(=(0 (rear rez)) =(1 (rear a)) =(1 (rear b)))
    ~|('signed int overflow' !!)
  ?:  &(=(1 (rear rez)) =(0 (rear a)) =(0 (rear b)))
    ~|('signed int overflow' !!)
  [(lent a) rez]
::
  ++  sas      ::  +sas: signed int subtraction ::TODO
  ~
::
  ++  com    :: +com: 2s complement
  |=  a=(list @)
  =/  res
    %+  soo
      (one (lent a))
    %+  turn
      a
    |=  c=@
    ?:(=(c 1) 0 1)
  ?:  (gth (lent res) (lent a))
    (snip res)
  res
  --
--