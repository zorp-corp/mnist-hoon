/+  ox=onnx
/+  *nu-lagoon
:-  %say
|=  [[now=@da eny=@uv [=ship =desk =case]] [onnx-path=path img-path=path ~] ~]
:-  %noun
|^
=/  x  (malt `(list [@t tensor:ox])`~[[%input1 [%array (load-image img-path)]]])
=/  onnx-file=json  .^(json %cx onnx-path)
=/  output-map=(map @t tensor:ox)  ((run-onnx:ox (preprocess-onnx:ox onnx-file)) x)
=/  out  (~(got by output-map) 'output')
?>  ?=(%array -.out)
~&  >  prediction+(argmax:la ray.out)
~
::
++  load-image
  |=  =path
  ^-  ray:la
  =/  img  .^(@ %cx path)
  =/  missing  (sub 784 (met 5 img))
  %-  spac:la
  :-  [~[784 1] 5 %float ~]
  ::
  ::  lsh to recover zeros lost by flop-rep
  %+  lsh
    [5 missing]
  %+  rep
    5
  ::  flop since lagoon is big endian
  (flop (rip 5 img))
--