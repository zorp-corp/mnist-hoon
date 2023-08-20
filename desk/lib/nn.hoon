/+  *lagoon
::
::  inn: integer neural network
!:
|%
::
++  clip
  :: TODO infer max and min
  |=  [[max=@ min=@] =ray:la]
  %+  el-wise-op:la
    ray
  |=  a=@
  ?:  ;;(? ((fun-scalar:la bloq.meta.ray kind.meta.ray %gth) a max))
    max
  ?:  ;;(? ((fun-scalar:la bloq.meta.ray kind.meta.ray %lth) a min))
    min
  a
::
::  scale up
++  scale
  |=  [=ray:la s=@rs]
  ^-  ray:la
  ::%+  clip
  ::  [129 127]
  %+  el-wise-op:la
    ray
  |=  a=@
  =/  a1  (~(twoc-to-s twoc bloq.meta.ray) a)
  =/  b  (need (toi:rs (mul:rs (san:rs a1) s)))
  (~(s-to-twoc twoc bloq.meta.ray) b)
::
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
::  +q-linear: Quantized linear layer
::
::  Note that s = (s_in*s_weight) / s_out
::  the s_* values should be precomputed.
::
++  q-linear
  |=  [w=ray:la b=ray:la s=@rs]
  |=  x=ray:la
  ^-  ray:la
  (scale (add:la (matmul-2d:la w x) b) s)
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
++  relu-signed
  |=  a=ray:la
  ^+  a 
  %+  el-wise-op:la 
    a
  |=  x=@
  ?:(;;(? ((fun-scalar:la bloq.meta.a kind.meta.a %gth) x 0)) x 0)
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
  ~&  >  'applying layer'
  =/  y  (layer x)
  ::~>  %slog.1^(to-tank:la y)
  ~&  >  y
  [layer y]
::
--