/-  *onnx, *lagoon
/+  *lagoon,
    nn=onnx-nn,
    *twoc
|%
++  type-map
|=  data-type=@
^-  [=kind bloq=@]
?:  =(1 data-type)
  [%real 5]
?:  =(6 data-type)
  [%int2 5]
?:  =(7 data-type)
  [%int2 6]
?:  =(12 data-type)
  [%uint 5]
?:  =(13 data-type)
  [%uint 6]
!!
::
++  raw-to-tensor
|=  [data-type=@ shape=(list @t) raw=@t]
^-  ray
=/  m  (type-map data-type)
=/  dat  q:(need (de:base64:mimes:html raw))
%-  spac:la
:-  [(parse-shape shape) bloq.m kind.m ~]
dat
::
++  preprocess-onnx
  |=  onnx=json
  ^-  [outputs=(list io) tensors=(map @t tensor) ops=(list op)]
  ?>  ?=(%o -.onnx)
  =/  graph  (~(got by p.onnx) %graph)
  ?>  ?=(%o -.graph)
  =/  m  p.graph
  =/  nodes  (~(got by m) %node)
  ::=/  inputs=(list io)  (parse-graph-io (~(got by m) %input))
  =/  outputs=(list io)  (parse-graph-io (~(got by m) %output))
  ?>  ?=(%a -.nodes)
  =/  sep
    %+  skid
      %+  turn
        p.nodes
      |=  j=json
      (parse-graph-op j)
    |=(x=op ?=(%constant -.x))
  ::
  ::  constants only
  ::
  =/  constants=(list op)  p.sep
  :: 
  ::  ops with constants removed
  :: 
  =/  ops=(list op)  q.sep
  ::
  ::  parse weights
  ::
  =/  initializer=(map @t tensor)
    %-  malt
    ;;  (list [@t tensor])
    (parse-graph-weights (~(got by m) %initializer))
  ::
  ::  union weights and constants to be referenced at runtime
  ::
  =/  tensors  (~(uni by initializer) (preprocess-constants constants))
  [outputs tensors ops]
::
++  run-onnx
  |=  $:  outputs=(list io)
          tensors=(map @t tensor)
          ops=(list op)
      ==
  |=  x=(map @t tensor)
  ::
  ::  load inputs
  =.  tensors  (~(uni by tensors) x)
  =|  i=@
  |-
  ?:  =(i (lent ops))
    ^-  (map @t tensor)
    %-  malt
    ;;  (list [@t tensor])
    (turn outputs |=(=io [name.io (~(got by tensors) name.io)]))
  =/  curr=op  (snag i ops)
  ~&  >  curr-op+curr
  =.  tensors
    ?+    -.curr  ~|("Unsupported op {<-.curr>}" !!)
        %reshape
      =/  ins=(list tensor)  (turn input.op.curr |=(n=@t (~(got by tensors) n)))
      =/  out-name=@t  (snag 0 output.op.curr)
      ~&  ins+ins
      =/  result  (reshape:nn (snag 0 ins) [%shape (flop ;;((list @s) +:(snag 1 ins)))])
      ?>  ?=(%array -.result)
      (~(put by tensors) out-name result)
      ::
        %relu
      =/  in-name=@t  (snag 0 input.op.curr)
      =/  out-name=@t  (snag 0 output.op.curr)
      =/  in=tensor  (~(got by tensors) in-name)
      =/  result  (relu:nn in)
      ?>  ?=(%array -.result)
      ::~>  %slog.1^(to-tank:la ray.result)
      (~(put by tensors) out-name result)
      ::
        %gemm
      =/  ins=(list tensor)  (turn input.op.curr |=(n=@t (~(got by tensors) n)))
      =/  out-name=@t  (snag 0 output.op.curr)
      =/  result  (linear:nn (snag 1 ins) (snag 2 ins) (snag 0 ins))
      ?>  ?=(%array -.result)
      ::~>  %slog.1^(to-tank:la ray.result)
      (~(put by tensors) out-name result)
    ::
        %div
      =/  ins=(list tensor)  (turn input.op.curr |=(n=@t (~(got by tensors) n)))
      =/  out-name=@t  (snag 0 output.op.curr)
      =/  result  (div:nn (snag 0 ins) (snag 1 ins))
      ?>  ?=(%array -.result)
      ::~>  %slog.1^(to-tank:la ray.result)
      (~(put by tensors) out-name result)
    ::
        %mul
      =/  ins=(list tensor)  (turn input.op.curr |=(n=@t (~(got by tensors) n)))
      =/  out-name=@t  (snag 0 output.op.curr)
      =/  result  (mul:nn (snag 0 ins) (snag 1 ins))
      ?>  ?=(%array -.result)
      ::~>  %slog.1^(to-tank:la ray.result)
      (~(put by tensors) out-name result)
    ::
        %round
      =/  in-name=@t  (snag 0 input.op.curr)
      =/  out-name=@t  (snag 0 output.op.curr)
      =/  in=tensor  (~(got by tensors) in-name)
      =/  result  (round:nn in)
      ?>  ?=(%array -.result)
      ::~>  %slog.1^(to-tank:la ray.result)
      (~(put by tensors) out-name result)
    ::
        %clip
      =/  ins=(list tensor)  (turn input.op.curr |=(n=@t (~(got by tensors) n)))
      =/  out-name=@t  (snag 0 output.op.curr)
      =/  result  (clip:nn (snag 0 ins) (snag 1 ins) (snag 2 ins))
      ?>  ?=(%array -.result)
      ::~>  %slog.1^(to-tank:la ray.result)
      (~(put by tensors) out-name result)
    ==
  %=    $
    tensors  tensors
    i        +(i)
  ==
::
++  preprocess-constants
  |=  ops=(list op)
  ^-  (map @t tensor)
  %-  malt
  ;;  (list [@t tensor])
  %+  turn
    %+  skim
      ops
    |=  x=op
    ?=(%constant -.x)
  |=  y=op
  ?>  ?=(%constant -.y)
  =/  attr=const-attribute  attribute.op.y
  :-  (snag 0 output.op.y)
  ?-    -.attr
      %unsized
    =/  m  (type-map data-type.t.attr)
      :+  %scalar
        kind.m
      =/  raw  q:(need (de:base64:mimes:html raw.t.attr))
      ?.  ?=(%int2 kind.m)  
        raw
      (~(twoc-to-s twoc bloq.m) raw)
  ::
      %sized
    =/  m  (type-map data-type.t.attr)
    :-  %shape
    =/  raws  (rip bloq.m q:(need (de:base64:mimes:html raw.t.attr)))
    ?.  ?=(%int2 kind.m)  
      raws
    %+  turn
      raws
    |=  x=@ 
    (~(twoc-to-s twoc bloq.m) x)
  ==
::
::  top level parsers
::
++  parse-graph-io
  |=  input=json
  ^-  (list io)
  ?>  ?=(%a -.input)
  %+  turn
    p.input
  |=  j=json
  ^-  io
  ?>  ?=(%o -.j)
  =/  typ=[elem-type=@t dim-param=@t dim-value=@t] 
    (parse-type (~(got by p.j) %type))
  :*  (parse-name (~(got by p.j) %name))
    elem-type.typ
    dim-param.typ
    dim-value.typ
  ==
::
++  parse-graph-op
  |=  op=json
  ^-  ^op
  ?>  ?=(%o -.op)
  =/  optype  (~(got by p.op) %'opType')
  ?>  ?=(%s -.optype)
  ?+    p.optype  ~|("Unsupported optype {<p.optype>}" !!)
      %'Reshape'
    [%reshape (parse-op-generic op)]
  ::
       %'Gemm'
    [%gemm (parse-op-generic op)]
  ::
      %'Add'
    [%add (parse-op-generic op)]
  ::
      %'Div'
    [%div (parse-op-generic op)]
  ::
      %'Round'
    [%round (parse-op-generic op)]
  ::
      %'Mul'
    [%mul (parse-op-generic op)]
  ::
      %'Clip'
    [%clip (parse-op-generic op)]
  ::
      %'Relu' 
    [%relu (parse-op-generic op)]
  ::
      %'Constant'
    :-  %constant
    ::  check for sized/unsized 
    =/  ir-unit  (parse-op-constant-dim op)
    ?:  ?=(~ ir-unit)
      =/  ir=const-raw-no-dim  (need (parse-op-constant-no-dim op))
      :*  output=output.ir
          name=name.ir
          optype=optype.ir
          attribute=[%unsized attribute.ir]
      ==
    =/  ir=const-raw-dim  (need ir-unit)
    :*  output=output.ir
        name=name.ir
        optype=optype.ir
        attribute=[%sized attribute.ir]
    ==
  ==
::
++  parse-type
  |=  typ=json
  ?>  ?=(%o -.typ)
  ?>  (~(has by p.typ) %'tensorType')
  %-  parse-tensor-type
  (~(got by p.typ) %'tensorType')
::
++  parse-graph-weights
  |=  input=json
  ^-  (list [@t tensor])
  ?>  ?=(%a -.input)
  %+  turn
    p.input
  |=  j=json
  ^-  [@t tensor]
  ?>  ?=(%o -.j)
  =/  w=weight-ir  (parse-weight j)
  :*  name=name.w
      `tensor`[%array (raw-to-tensor [data-type dims raw]:w)]
  ==
::
::  json parsers
::
++  parse-op-generic
=,  dejs:format
%-  ot
:~  [%input (ar so)]
    [%output (ar so)]
    [%name so]
    [%'opType' so]
==
::
++  parse-op-constant-dim
=,  dejs-soft:format
%-  ot
:~  [%output |=(jon=json output=%.(jon (ar so)))]
    [%name |=(jon=json name=%.(jon so))]
    [%'opType' |=(jon=json optype=%.(jon so))]
    :-  %attribute
    |=  jon=json
    ^=  attribute
    %.  jon
    %-  at
    :~  %-  ot
        :~  :-  %t
            |=  jon=json
            ^=  t
            %.  jon
            %-  ot
            :~  :-  %dims
                |=(jon=json dims=%.(jon (ar so)))
                :-  %'dataType'
                |=(jon=json data-type=%.(jon ni))
              ::
                :-  %'rawData'
                |=(jon=json raw=%.(jon so))
            ==
            [%name |=(jon=json name=%.(jon so))]
            [%type |=(jon=json type=%.(jon so))]
        ==
    ==
==
::
++  parse-op-constant-no-dim
=,  dejs-soft:format
%-  ot
:~  [%output |=(jon=json output=%.(jon (ar so)))]
    [%name |=(jon=json name=%.(jon so))]
    [%'opType' |=(jon=json optype=%.(jon so))]
    :-  %attribute
    |=  jon=json
    ^=  attribute
    %.  jon
    %-  at
    :~  %-  ot
        :~  :-  %t
            |=  jon=json
            ^=  t
            %.  jon
            %-  ot
            :~  :-  %'dataType'
                |=(jon=json data-type=%.(jon ni))
              ::
                :-  %'rawData'
                |=(jon=json raw=%.(jon so))
            ==
            [%name |=(jon=json name=%.(jon so))]
            [%type |=(jon=json type=%.(jon so))]
        ==
    ==
==
::
:: TODO: what happens when there are multiple dims? 
++  parse-tensor-type 
=,  dejs:format
%-  ot
:~  [%'elemType' ni]
    :-  %shape
    %-  ot
    :~  :-  %dim
        %-  at
        ~[(ot ~[[%'dimParam' so]]) (ot ~[[%'dimValue' so]])]
    ==
==
::
++  parse-name
  |=  name=json
  ?>  ?=(%s -.name)
  p.name
::
++  parse-weight
=,  dejs:format
%-  ot
:~  [%name so]
    [%dims (ar so)]
    [%'dataType' ni]
    [%'rawData' so]
==
::
++  parse-shape
  |=  shape=(list @t)
  ::
  ::  Check if shape is flattened
  ::
  =?  shape  =((lent shape) 1)
  (snoc shape '1')
  ^-  (list @)
  %+  turn
    shape
  |=  x=@t
  (rash x dem)
--