/-  *onnx
/+  *lagoon
!:
|%
++  pro  |:([a=`@s`--1 b=`@s`--1] (pro:si a b))
::
++  div
  |=  [a=tensor b=tensor]
  ^-  tensor
  ?>  ?=(%scalar -.b)
  ?>  ?=(%array -.a)
  ?>  =(kind.b kind.meta.ray.a)
  ~&   >>  div-by+`@rs`val.b
  [%array (div-scalar:la ray.a val.b)]
::
++  mul
  |=  [a=tensor b=tensor]
  ^-  tensor
  ?>  ?=(%array -.a)
  ?>  ?=(%scalar -.b)
  ?>  =(kind.b kind.meta.ray.a)
  ~&   >>  mul-by+`@rs`val.b
  [%array (mul-scalar:la ray.a val.b)]
::
++  round
  |=  a=tensor
  ^-  tensor
  ?>  ?=(%array -.a)
  ?>  =(%real kind.meta.ray.a)
  :-  %array
  %+  el-wise-op:la
    ray.a
  |=  x=@
  (san:rs (need (toi:rs x)))
::
++  clip
  |=  [m=tensor min=tensor max=tensor]
  ^-  tensor
  ?>  ?=(%array -.m)
  ?>  ?=(%scalar -.min)
  ?>  ?=(%scalar -.max)
  :-  %array
  %+  el-wise-op:la
    ray.m
  |=  a=@
  ?:  ;;(? ((fun-scalar:la meta.ray.m %gth) a val.max))
    val.max
  ?:  ;;(? ((fun-scalar:la meta.ray.m %lth) a val.min))
    val.min
  a
::
++  reshape
  |=  [x=tensor shape=tensor]
  ^-  tensor
  ?>  ?=(%array -.x)
  ?>  ?=(%shape -.shape)
  =/  inferred-shape=(list @)  (process-shape shape.shape (reel shape.meta.ray.x ^mul))
  [%array (reshape:la ray.x inferred-shape)]
::
++  process-shape
  |=  [ir=(list @s) size=@]
  ^-  (list @)
  =/  pozz=(list @s)
    %+  skim
      ir
    |=(x=@s -:(old:si x))
  ~|  'Only one dimension can be inferred'
  ?>  (lte +((lent pozz)) (lent ir))
  =/  mask-total  +:(old:si (roll pozz pro))
  =/  inferred-dim  (^div size mask-total) 
  %+  turn
    ir
  |=  x=@s
  =/  old-x  (old:si x)
  ?:  -.old-x
    +.old-x
  inferred-dim
::
::  +linear: Linear layer, usage: ((linear weights bias) input)
++  linear
  |=  [w=tensor b=tensor x=tensor]
  ^-  tensor
  ?>  ?=(%array -.w)
  ?>  ?=(%array -.b)
  ?>  ?=(%array -.x)
  [%array (add:la (mmul:la ray.w ray.x) ray.b)]
::
::
::  +relu: Operation: for each element x in `ray`, take max(0,x)
::  use +relu-signed for %signed kind
::
++  relu
  |=  x=tensor
  ^-  tensor
  ?>  ?=(%array -.x)
  =/  a  ray.x
  :-  %array
  %+  el-wise-op:la
    a
  |=  x=@
  ?:(!=(0 ((fun-scalar:la meta.a %gth) x 0)) x 0)
::
--
