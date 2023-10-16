/+  *lagoon
|%
+$  weight-ir  [name=@t dims=(list @t) data-type=@ raw=@t]
::
::  IR for constant op types, output should always be length 1.
+$  constant-ir  [output=(list @t) name=@t optype=@t attribute=const-attribute]
+$  const-raw-no-dim  [output=(list @t) name=@t optype=@t attribute=[t=[data-type=@ raw=@t] name=@t type=@t]]
+$  const-raw-dim  [output=(list @t) name=@t optype=@t attribute=[t=[dims=(list @t) data-type=@ raw=@t] name=@t type=@t]]
+$  const-attribute
  $%  [%sized [t=[dims=(list @t) data-type=@ raw=@t] name=@t type=@t]]
      [%unsized [t=[data-type=@ raw=@t] name=@t type=@t]]
  ==
::
+$  op
    $%  [%reshape op=op-generic]
        [%gemm op=op-generic]
        [%add op=op-generic]
        [%relu op=op-generic]
        [%round op=op-generic]
        [%mul op=op-generic]
        [%div op=op-generic]
        [%clip op=op-generic]
        [%constant op=constant-ir]
    ==
+$  op-generic  [input=(list @t) output=(list @t) name=@t optype=@t]
::
+$  tensor
  $%  [%array =ray:la]
      [%scalar kind=term val=@]
      [%shape shape=(list @s)]
  ==
::
::  input/output type
::
+$  io  [name=@t elem-type=@ dim-param=@t dim-value=@t]
::
--
