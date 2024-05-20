/-  *lagoon
/+  ox=onnx,
    *lagoon
:-  %say
|=  [[now=@da eny=@uv [=ship =desk =case]] [onnx-path=path img-path=path ~] ~]
:-  %noun
|^
~>  %bout
=/  x  (malt `(list [@t tensor:ox])`~[[%input1 [%array (load-image img-path)]]])
=/  onnx-file=json  .^(json %cx onnx-path)
=/  output-map=(map @t tensor:ox)  ((run-onnx:ox (preprocess-onnx:ox onnx-file)) x)
=/  out  (~(got by output-map) 'output')
?>  ?=(%array -.out)
~&  >>>  ray.out
~&  >  prediction+(argmax:la ray.out)
~
::
++  load-image
  |=  =path
  ^-  ray
  %-  spac:la
  :-  [~[784 1] 5 %real ~]
  .^(@ %cx path)
--
