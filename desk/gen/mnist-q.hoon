/+  nn, *lagoon
:-  %say
|=  [[now=@da eny=@uv [=ship =desk =case]] [n=@ud ~] ~]
:-  %noun
:: 
|^
=/  so_1=@rs  .0.04977201852272815
=/  so-2=@rs  .0.20500931026428704
=/  s-fc1=@rs  .0.0018833551819868915
=/  s-fc2=@rs  .0.006395129706915908
=/  s-x=@rs  (div:rs .1 .127)
(test n)
++  round
  |=  [=bloq a=@rs]
  ^-  @
  (~(s-to-twoc twoc bloq) (toi:rs a))
::
++  test
  |=  n=@ud
  =/  net  model
  =/  x  (load-image n)
  =/  pred  ~>  %bout  (argmax:la (apply:nn model x))
  ~&  >  pred  pred
::
++  model 
  =/  w1
  %-  spac:la
  :-  [~[500 784] 5 %signed]
  .^(@ux %cx /(scot %p ship)/tensor/(scot %da now)/data/fc1-weight-int/mnist)
  =/  w2 
  %-  spac:la
  :-  [~[100 500] 5 %signed]
  .^(@ux %cx /(scot %p ship)/tensor/(scot %da now)/data/fc2-weight-int/mnist)
  =/  b1  
  %-  spac:la
  :-  [~[500 1] 5 %signed]
  .^(@ux %cx /(scot %p ship)/tensor/(scot %da now)/data/fc1-bias-int/mnist)
  =/  b2
  %-  spac:la
  :-  [~[100 1] 5 %signed]
  .^(@ux %cx /(scot %p ship)/tensor/(scot %da now)/data/fc2-bias-int/mnist)
  ~[(linear:nn w1 b1) relu:nn (linear:nn w2 b2)]
:: 
++  load-image
  |=  i=@
  ^-  ray:la
  =/  dat  .^(@ %cx /(scot %p ship)/tensor/(scot %da now)/data/(scot %ud i)/mnist)
  ::  convert this back to an integer by rounding
  %-  spac:la
  :-  [~[784 1] 5 %signed]
  %+  rep
    5
  %+  turn
    (rip 3 dat)
  |=  e=@
  (round 3 (div (sun:rs e) s-x))
::
++  load-labels
  ^-  (list @)
  =/  dat  .^(@ %cx /(scot %p ship)/tensor/(scot %da now)/data/labels/mnist)
  (rip 3 dat)
--
