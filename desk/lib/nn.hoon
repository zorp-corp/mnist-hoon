/+  *lagoon
::
::  inn: integer neural network
|%
::  Returns a reshaped linear weight matrix
++  linear-builder
  |=  [in=@ out=@ weights=ray:la]
  (reshape:la weights ~[in out])
::
::  +linear: Linear layer, usage: ((linear weights) input)
++  linear
  |=  w=ray:la
  |=  x=ray:la
  ^-  ray:la
  (matmul-2d:la w x)
::
::  +relu: Operation: for each element x in `ray`, take max(0,x)
::  need to change for %signed
++  relu
  |=  a=ray:la
  ^+  a 
  %+  el-wise-op:la
    a
  |=  x=@
  ?:((gte x 0) x 0)
::
::
++  apply
  ::  apply each layer in a sequence. usage: (apply ~[(linear w1) relu (linear w2) relu (linear w3)] x)
  |=  [layers=(list $-(ray:la ray:la)) x=ray:la]
  ^-  ray:la
  =<  +
  %^    spin
      layers
    x
  |=  [layer=$-(ray:la ray:la) x=ray:la]
  [layer (layer x)]
::
++  sigmoid
  |=  a=ray:la
  ^-  ray:la
  ::  1/(1+exp(-a))
  =/  one  (ones:la meta.a)
  =/  neg  (sub:la (zeros:la meta.a) one)
  (div:la one (add:la one (exp (mul:la neg a))))
::
++  factorial
  |=  [=meta:la n=@ud]
  ^-  ray:la
  ?:  =(0 n)  (fill:la meta data:(scalarize:la meta %rs .1))
  =/  t  1
  |-
  ?:  =(1 n)  (fill:la meta data:(scalarize:la meta %rs (sun:rs t)))
  $(n (dec n), t (mul t n))
::
++  exp
  |=  x=ray:la
  ^-  ray:la
  =/  p   (fill:la meta.x .1)
  =/  po  (fill:la meta.x .-1)
  =/  i   1
  =/  rtol  (fill:la meta.x .1e-5)
  |-
  ?:  (any:la (lth:la (abs:la (sub:la po p)) rtol))
    p
  %=  $
    i   +(i)
    p   (add:la p (div:la (pow-n x i) (factorial meta.x i)))
    po  p
  ==
::
::  restricted pow, based on integers only
++  pow-n
  |=  [x=ray:la n=@ud]
  ^-  ray:la
  ?:  =(0 n)  (scalarize:la meta.x %rs .1)
  =/  p  x
  |-
  ?:  (lth n 2)  p
  %=  $
    n  (dec n)
    p  (mul:la p x)
  ==
--