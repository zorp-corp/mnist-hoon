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
  ::
  :: https://gist.github.com/mfuerstenau/ba870a29e16536fdbaba#file-zigzag-encoding-readme-L53
  ::  (i >>> 1) ^ (~(i & 1) + 1)
  ::
  ::  Test cases
  :: > (~(s-to-twoc twoc:twoc 2) --2)
  ::   2
  :: > (~(s-to-twoc twoc:twoc 2) --1)
  ::   1
  :: > (~(s-to-twoc twoc:twoc 2) --8)
  ::  /lib/twoc/hoon:<[19 5].[22 45]>
  :: > (~(s-to-twoc twoc:twoc 3) -14)
  ::  242
  ++  s-to-twoc
    |=  a=@s
    ?>  (lte `@`a (dec ~(out fe bloq)))
    %+  mix
      (rsh 0 a) 
    (~(sum fe bloq) (not 0 len (dis a 1)) 1)
  :: 
  ++  add
    |=  [a=@ b=@]
    =/  res  (^add a b)
    ?.  (gth (xeb res) len)
      res 
    =/  rez=@  (rep 0 (snip (rip [0 1] res)))
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