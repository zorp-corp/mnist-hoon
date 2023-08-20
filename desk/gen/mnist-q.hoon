/+  nn, *lagoon
:-  %say
|=  [[now=@da eny=@uv [=ship =desk =case]] [n=@ud ~] ~]
:-  %noun
:: 
|^
(test n)
::
::
::  scale down by dividing and round
::
++  round
  |=  [=bloq a=@rs]
  =/  b  (toi:rs a)
  ?@  b
    ~|(round+a !!)
  (~(s-to-twoc twoc bloq) (need b))
::
::
++  test
  |=  n=@ud
  =/  net  model
  =/  x  (load-image n)
  =/  res  ~>  %bout  (apply:nn model x) 
  ~>  %slog.1^(to-tank:la res)
  =/  pred   (argmax:la res)
  ~&  >  pred  pred
::
++  model 
  =/  so-1=@rs  .0.0578187957523376
  =/  so-2=@rs  .0.2039385517751138
  =/  s-fc1=@rs  .0.0023238762157169854
  =/  s-fc2=@rs  .0.006298254794023168
  =/  s-x=@rs  (div:rs .1 .127)
  =/  sl1=@rs  (div:rs (mul:rs s-fc1 s-x) so-1)
  =/  sl2=@rs  (div:rs (mul:rs s-fc2 so-1) so-2)
  =/  w1
  %-  spac:la
  :-  [~[500 784] 5 %signed]
  .^(@ux %cx /(scot %p ship)/tensor/(scot %da now)/data/fc1-weight-int32/mnist)
  =/  w2 
  %-  spac:la
  :-  [~[10 500] 5 %signed]
  .^(@ux %cx /(scot %p ship)/tensor/(scot %da now)/data/fc2-weight-int32/mnist)
  ::
  =/  b1  
  %-  spac:la
  :-  [~[500 1] 5 %signed]
  .^(@ux %cx /(scot %p ship)/tensor/(scot %da now)/data/fc1-bias-int32/mnist)
  ::
  =/  b2
  %-  spac:la
  :-  [~[10 1] 5 %signed]
  .^(@ux %cx /(scot %p ship)/tensor/(scot %da now)/data/fc2-bias-int32/mnist)
  ~[(q-linear:nn w1 b1 sl1) relu-signed:nn (q-linear:nn w2 b2 sl2)]
:: 
++  load-image
  |=  i=@
  ^-  ray:la
  =/  dat  .^(@ %cx /(scot %p ship)/tensor/(scot %da now)/data/int/(scot %ud i)/mnist)
  %-  spac:la
  :-  [~[784 1] 5 %signed]
  %+  rep
    5
  %+  turn
    (rip 5 dat)
  |=  e=@
  ::
  ::  Squeeze images in range [0, 127]
  =/  b  (div e 2)
  ::
  ?:(=(b 128) (dec b) b)
::
++  load-labels
  ^-  (list @)
  =/  dat  .^(@ %cx /(scot %p ship)/tensor/(scot %da now)/data/labels/mnist)
  (rip 3 dat)
--
