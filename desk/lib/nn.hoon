/+  *lagoon
::
::  inn: integer neural network
|%
::  Returns a reshaped linear weight matrix
++  linear-builder
  |=  [in=@ out=@ weights=ray:la]
  (reshape:la weights ~[in out])
::
::  +linear: Linear layer, usage: ((linear weights bias) input)
++  linear
  |=  [w=ray:la b=ray:la]
  |=  x=ray:la
  ^-  ray:la
  (add:la (matmul-2d:la w x) b)
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
  ::  apply each layer in a sequence. usage: (apply ~[(linear w1 b1) relu (linear w2 b2) relu (linear w3 b2)] x)
  |=  [layers=(list $-(ray:la ray:la)) x=ray:la]
  ^-  ray:la
  =<  +
  %^    spin
      layers
    x
  |=  [layer=$-(ray:la ray:la) x=ray:la]
  [layer (layer x)]
::
--