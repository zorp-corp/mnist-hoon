/+  sa=saloon, *twoc
::                                                    ::
::::                    ++la                          ::  (2v) vector/matrix ops
|%
++  la
  ^|
  !:
  |_  r=$?(%n %u %d %z)   :: round nearest, round up, round down, round to zero
  ::
  ::  Metadata
  ::
  +$  ray  ::     $ray:  n-dimensional array
    $:  =meta     ::  descriptor
        data=@ux  ::  data, row-major order
    ==
  ::
  +$  meta  ::          $meta:  metadata for a $ray
    $:  shape=(list @)  ::  list of dimension lengths
        =bloq           ::  logarithm of bitwidth
        =kind           ::  name of data type
    ==
  ::
  +$  kind
    $?  %float
        %unsigned
        %signed
        %complex
    ==
  ::
  +$  baum  ::          $baum:  ndray with metadata
    $:  =meta  
        data=ndray
    ==
  ::
  +$  ndray  ::        $ndray:  n-dimensional array as a nested list
      $@  @        ::  single item
      (lest ndray)  ::  nonempty list of children, in row-major order
  ::
  ::  Utilities
  ::
  ++  print
    |=  a=ray
    ~>  %slog.1^(to-tank a)
    ~
  ++  slog  |=(a=ray (^slog (to-tank a) ~))
::
  ++  to-tank  ::  TODO nest dimensions
    |=  a=ray
    ^-  tank
    ::  1D vector case
    ?:  =(1 (lent shape.meta.a))
      =/  term  (get-term meta.a)
      :+  %rose  [" " "[" "]"]
      %+  turn  (ravel a)
      |=  i=@
      ^-  tank
      [%leaf (scow term i)]
    ?:  =(2 (lent shape.meta.a))
      =/  =baum  (de-ray a)
      =/  =term  (get-term meta.a)
      ?@  data.baum  leaf+(scow term data.baum)
      :+  %rose  [" " "[" "]"]
      %+  turn  ;;((lest (lest @)) data.baum)
      |=  b=(lest @)
      ^-  tank
      :+  %rose  [" " "[" "]"]
      %+  turn  b
      |=  c=@
      =?  c  =(kind.meta.a %signed)
        ::
        ::  convert to @s for pretty printing
        (~(twoc-to-s twoc bloq.meta.a) c)
      [%leaf (scow term c)]
    !!
  ::
  ++  get-term
    |=  =meta
    ?+    kind.meta  ~|(kind.meta !!)
        %unsigned
      %ud
      ::
        %signed
      %sd
      ::
        %float
      ?+    bloq.meta  ~|(bloq.meta !!)
        %7  %rq
        %6  %rd
        %5  %rs
        %4  %rh
      ==
    ==
  ::
  ++  get-item  ::  extract item at index .dex
    |=  [=ray dex=(list @)]
    ^-  @ux
    %^    cut
        bloq.meta.ray 
      [(get-bloq-offset -.ray dex) 1] 
    data.ray
  ::
  ++  set-item  ::  set item at index .dex to .val
    |=  [=ray dex=(list @) val=@]
    ^+  ray
    =/  len  (^sub (roll shape.meta.ray ^mul) 1)
    :-  -.ray
    %^    sew 
        bloq.meta.ray
      [(get-bloq-offset -.ray dex) 1 val] 
    data.ray
  ::
  ++  get-bloq-offset  ::  get bloq offset of n-dimensional index
    |=  [=meta dex=(list @)]
    ^-  @
    (get-item-number shape.meta dex)
  ::
  ++  get-item-number  ::  convert n-dimensional index to scalar index
    |=  [shape=(list @) dex=(list @)]
    ^-  @
    =.  dex  (flop dex)
    =/  sap  (flop shape)
    =/  cof  1
    =/  ret  0
    |-  ^+  ret
    ?~  sap  ret
    ?~  dex  !!
    ?>  (lth i.dex i.sap)
    %=  $
      sap  t.sap
      dex  t.dex
      cof  (^mul cof i.sap)
      ret  (^add ret (^mul i.dex cof))
    ==
  ::
  ::
  ++  get-dim  :: convert scalar index to n-dimensional index
    |=  [shape=(list @) ind=@]
    =/  sap  (flop shape)
    =/  i=@  0
    =|  dex=(list @)
    ^-  (list @)
    |-
    ?:  (gte i (lent sap))
      (flop dex)
    %=    $
      dex  `(list @)`(snoc dex (^mod ind (snag i sap)))
      ind  (^div ind (snag i sap))
      i    (^add i 1)
    ==
  ::
  ++  get-item-index
    |=  [shape=(list @) num=@]
    ^-  @
    =/  len  (roll shape ^mul)  :: TODO will shadow
    =-  (roll - ^add)
    ^-  (list @)
    %+  turn  shape
    |=  wid=@
    (^mod (^div len wid) num)
  ::
  ++  ravel
    |=  a=ray
    ^-  (list @)
    (snip (rip bloq.meta.a data.a))
  ::
  ::  +de-ray: ray to baum
  ++  de-ray
    |=  =ray
    ^-  baum
    |^
    :-  meta.ray
    ^-  ndray
    ::
    =,  meta.ray
    ?:  =(1 (lent shape))
      (snip (rip bloq data.ray))
    ::
    ::  collate rows
    ?:  =(2 (lent shape))
      =/  ncol  (snag 1 shape)
      ::
      ::  bits per row
      =/  row-size  (^mul ncol (bex bloq))
      =|  i=@
      =|  res=(list (list @))
      ::
      ::  pointer to current row
      =|  p-row=@
      |-
      ?:  =(i (snag 0 shape))
        res
      ::
      ::  grab data for the row
      ::  if all the values of a row are zero,
      ::  materialize a row of zeros.
      =/  d  (rip bloq (cut 0 [p-row row-size] data.ray))
      =/  dat=(list @)
        ?:  !=(0 d)
          d
        %+  turn
          (gulf 0 (dec ncol))
        |=(* 0)
      %=  $
        i      +(i)
        p-row  (^add p-row row-size) 
        res    (weld res ~[dat])
      ==
    ::  cut off end
    !!
  --
  ::
  ++  en-ray    :: baum to ray
  |=  =baum
  ^-  ray
  =/  a=ray  [meta.baum `@ux`0]
  =/  i  0
  =/  n  (roll shape.meta.a ^mul)
  |-
  ?:  =(i n)
    =.  data.a  (^add (lsh [bloq.meta.a n] 1) (swp bloq.meta.a data.a))
    a
  %=    $
      i  +(i)
      data.a
    %+  ^add 
      (get-item-baum baum (get-dim shape.meta.a i))
    %+  lsh 
      bloq.meta.a 
    data.a 
  ==
  ::
  ++  get-item-baum
  |=  [=baum dex=(list @)]
  ^-  @
  =/  a=ndray  data.baum
  =/  i  0
  |-
  ?@  a
    a
  %=    $
      i  +(i)
      a
    (snag (snag i dex) `(list ndray)`a)
  ==
  ::
  ++  fill
    |=  [=meta x=@]  
    ^-  ray
    =/  len  (roll shape.meta ^mul)
    :-  meta
    (con +:(zeros meta) (fil bloq.meta len x))
  ::
  ++  spac
    |=  =ray
    ^-  ^ray
    :-  meta.ray
    (con data:(zeros meta.ray) data.ray)
  ::
  ::  Builders
  ::
  ::
  ++  eye      ::  produces identity matrix of shape nxn.
    |=  [=bloq =kind n=@]
    ^-  ray
    ~_  leaf+"lagoon-fail"
    =<  +
    %^    spin
        (gulf 0 (dec n))
      ^-  ray  (zeros [~[n n] bloq kind])
    |=  [i=@ r=ray]
    [i (set-item r ~[i i] 1)]
 ::    Zeroes
 ++  zeros
    |=  =meta  ^-  ray
    ~_  leaf+"lagoon-fail"
    :-  meta
    (lsh [bloq.meta (roll shape.meta ^mul)] 1)
  ::    Ones
  ++  ones
    |=  =meta  ^-  ray
    ~_  leaf+"lagoon-fail"
    =/  one
      ?+    kind.meta  ~|(kind.meta !!)
          %unsigned  `@`1
          %signed    `@`1
          %float
        ?+  bloq.meta  !!
          %7  .~~~1
          %6  .~1
          %5  .1
          %4  .~~1
        ==
      ==
    (fill meta one)
  ::
  ++  iota
    |=  [=meta n=@ud]
    ^-  ray
    =.  shape.meta  ~[n]
    =.  kind.meta  %unsigned
    %-  spac
    :-  meta 
    (rap bloq.meta (gulf 1 n))
  ::
  ::  Operators
  ::
  ++  max
    |=  a=ray
    ^-  @ux
    =/  fun
      |:  [b=1 c=-:(ravel a)] 
      ?:  =(((fun-scalar bloq.meta.a kind.meta.a %gth) b c) 0)
        b  c 
    (reel (ravel a) fun)
  ::
  ++  argmax :: Only returns first match
    |=  a=ray
    ^-  @ud
    +:(find ~[(max a)] (ravel a))
  ::
  ++  min
    |=  a=ray
    ^-  @ux
    =/  fun
      |:  [b=1 c=-:(ravel a)] 
      ?:  =(((fun-scalar bloq.meta.a kind.meta.a %lth) b c) 0)
        b  c 
    (reel (ravel a) fun)
  ::
  ++  argmin :: Only returns first match
    |=  a=ray
    ^-  @ud
    +:(find ~[(min a)] (ravel a))
  ::
  ++  cumsum
    |=  a=ray  
    ^-  @ux
    (reel (ravel a) |=([b=@ c=@] ((fun-scalar bloq.meta.a kind.meta.a %add) b c)))
  ::
  ++  prod
    |=  a=ray
    ^-  @ux
    =/  fun  (fun-scalar bloq.meta.a kind.meta.a %mul)
    =/  ali  +:(ravel a)
    =/  p  -:(ravel a)
    |-  ^-  @ux
    ?~  ali  p
    $(ali +.ali, p (fun p -.ali))
  ::
  ++  reshape
    |=  [a=ray shape=(list @)]  ^-  ray
    =/  in-cnt  (reel shape.meta.a ^mul)
    =/  out-cnt  (reel shape ^mul)
    ?>  =(in-cnt out-cnt)
    =.  shape.meta.a  shape
    a
  ::
  ++  transpose
    |=  a=ray  ^-  ray
    ?>  =(2 (lent shape.meta.a))
    =/  i  0
    =/  j  0
    =/  shape=(list @)  ~[(snag 1 shape.meta.a) (snag 0 shape.meta.a)]
    =/  prod=ray  (zeros [shape bloq.meta.a kind.meta.a])
    |-
      ?:  =(i (snag 0 shape.meta.a))
        prod
      %=  $
        i  +(i)
        prod
      |-
        ?:  =(j (snag 1 shape.meta.a))
          prod
        %=  $
          j  +(j)
          prod  (set-item prod ~[j i] (get-item a ~[i j]))
        ==
    ==
  ::
  ++  matmul-2d
    |=  [a=ray b=ray]
    =/  ar  (ravel a)
    =/  br  (ravel b)
    =/  i  0
    =/  j  0
    =/  k  0
    =/  shape=(list @)  ~[(snag 0 shape.meta.a) (snag 1 shape.meta.b)]
    =/  prod=ray  (zeros [shape bloq.meta.a kind.meta.a])
    ::  
    ::  multiplication conditions
    ?>
    ?&  =(2 (lent shape.meta.b))
        =(2 (lent shape.meta.a))
        =((snag 1 shape.meta.a) (snag 0 shape.meta.b))
    ==
    |-
      ?:   =(i (snag 0 shape.meta.prod))
        prod
      %=    $
        i  +(i)
        prod
      |-
        ?:  =(j (snag 1 shape.meta.prod))
          prod
        =/  cume  0
        %=    $
            j  +(j)
            prod
          |-  
          ?:   =(k (snag 1 shape.meta.a))
            (set-item prod `(list @)`~[i j] cume)
          %=    $
              k  +(k)
              cume
            %+  (fun-scalar bloq.meta:a kind.meta:a %add)
              cume 
            %+  (fun-scalar bloq.meta:a kind.meta:a %mul)
              (snag (get-bloq-offset meta.a `(list @)`~[i k]) ar)
            (snag (get-bloq-offset meta.b `(list @)`~[k j]) br)
          ==
        ==
      ==
::
  ++  abs
    |=  a=ray
    ^-  ray
    (el-wise-op a (trans-scalar bloq.meta:a kind.meta:a %abs))
::
  ++  add-scalar
    |=  [a=ray n=@]
    ^-  ray
    =/  b=ray  (fill meta.a n)
    (add a b)
  ::
  ++  sub-scalar
    |=  [a=ray n=@]
    ^-  ray
    =/  b=ray  (fill meta.a n)
    (sub a b)
  ::
  ++  mul-scalar
    |=  [a=ray n=@]
    ^-  ray
    =/  b=ray  (fill meta.a n)
    (mul a b)
  ::
  ++  div-scalar
    |=  [a=ray n=@]
    ^-  ray
    =/  b=ray  (fill meta.a n)
    (div a b)
  ::
  ++  mod-scalar
    |=  [a=ray n=@]
    ^-  ray
    =/  b=ray  (fill meta.a n)
    (mod a b)
  ::
  ++  add
    |=  [a=ray b=ray]
    ^-  ray
    (bin-op a b (fun-scalar bloq.meta:a kind.meta:a %add))
  ::
  ++  sub
    |=  [a=ray b=ray]
    ^-  ray
    (bin-op a b (fun-scalar bloq.meta:a kind.meta:a %sub))
  ::
  ++  mul
    |=  [a=ray b=ray]
    ^-  ray
    (bin-op a b (fun-scalar bloq.meta:a kind.meta:a %mul))
  ::
  ++  div
    |=  [a=ray b=ray]
    ^-  ray
    (bin-op a b (fun-scalar bloq.meta:a kind.meta:a %div))
  ::
  ++  mod
    |=  [a=ray b=ray]
    ^-  ray
    (bin-op a b (fun-scalar bloq.meta:a kind.meta:a %mod))
   ::
  +$  ops  ?(%add %sub %mul %div %mod %gth %lth %abs)
  ::
  ++  fun-scalar
    |=  [=bloq =kind fun=ops]
    ^-  $-([@ @] @)
    ?+    kind  ~|(kind !!)
        %unsigned  
      ?+  fun  !!
        %add  ~(sum fe bloq)
        %sub  ~(dif fe bloq)
        %mul  |=([b=@ c=@] (~(sit fe bloq) (^mul b c)))
        %div  |=([b=@ c=@] (~(sit fe bloq) (^div b c)))
        %mod  |=([b=@ c=@] (~(sit fe bloq) (^mod b c)))
        %gth  |=([b=@ c=@] (gth b c))
        %lth  |=([b=@ c=@] (lth b c))
      ==
      ::
        %signed  
      ?+  fun  !!
        %add  ~(add twoc bloq)
        %mul  ~(mul twoc bloq)
        %gth  ~(gth twoc bloq)
        %lth  ~(lth twoc bloq)
      ==
      ::
        %float
      ?+  bloq  !!
        %7
        ?+  fun  !!
          %add  ~(add rq r)
          %sub  ~(sub rq r)
          %mul  ~(mul rq r)
          %div  ~(div rq r)
          %gth  ~(gth rq r)
          %lth  ~(lth rq r)
        ==
        %6
        ?+  fun  !!
          %add  ~(add rd r)
          %sub  ~(sub rd r)
          %mul  ~(mul rd r)
          %div  ~(div rd r)
          %gth  ~(gth rd r)
          %lth  ~(lth rd r)
        ==
        %5
        ?+  fun  !!
          %add  ~(add rs r)
          %sub  ~(sub rs r)
          %mul  ~(mul rs r)
          %div  ~(div rs r)
          %gth  ~(gth rs r)
          %lth  ~(lth rs r)
        ==
        %4
        ?+  fun  !!
          %add  ~(add rh r)
          %sub  ~(sub rh r)
          %mul  ~(mul rh r)
          %div  ~(div rh r)
          %gth  ~(gth rh r)
          %lth  ~(lth rh r)
        ==
      ==
    ::
    ==
  ::
  ++  trans-scalar
    |=  [=bloq =kind fun=ops]
    ^-  $-(@ @)
    ?+    kind  ~|(kind !!)
        %unsigned  
      ?+  fun  !!
        %abs  |=(b=@ b)
      ==
      ::
        %signed  !!
      ::
        %float
      ?+  bloq  !!
        %7
        ?+  fun  !!
          %abs  |=(b=@ ?:((gth:rq b .~~~0) b (mul:rq b .~~~-1)))
        ==
        %6
        ?+  fun  !!
          %abs  |=(b=@ ?:((gth:rd b .~0) b (mul:rd b .~-1)))
        ==
        %5
        ?+  fun  !!
          %abs  |=(b=@ ?:((gth:rs b .0) b (mul:rs b .-1)))
        ==
        %4
        ?+  fun  !!
          %abs  |=(b=@ ?:((gth:rh b .~~0) b (mul:rh b .~~-1)))
        ==
      ==
    ::
        ::  TODO signed integers -- add new 2's complement kind?
    ==
  ::
  ++  el-wise-op
    |=  [a=ray fun=$-(@ @)]
    ^-  ray
    %-  spac
    :-  meta.a
    =/  ali  (ravel a)
    %+  rep  bloq.meta.a
    %+  turn
      ali
    |=(e=@ (fun e))
 :: 
  ++  bin-op
    |=  [a=ray b=ray op=$-([@ @] @)]
    ^-  ray
    ?>  =(meta.a meta.b)
    %-  spac
    :-  meta.a
    =/  ali  (ravel a)
    =/  bob  (ravel b)
    =/  len  (dec (^min (lent ali) (lent bob)))
    %+  rep  bloq.meta.a
    %+  turn
      (gulf 0 len)
    |=  i=@
    (op (snag i ali) (snag i bob))
    ::
        ::  TODO signed integers -- add new 2's complement kind?
--
--