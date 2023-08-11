/+  nn, *lagoon
:-  %say
|=  [[now=@da eny=@uv [=ship =desk =case]] [n=@ud ~] ~]
:-  %noun
:: 
|^
(test n)
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
  :-  [~[500 784] 5 %float]
  .^(@ux %cx /(scot %p ship)/tensor/(scot %da now)/data/fc1-weight/mnist)
  =/  w2 
  %-  spac:la
  :-  [~[100 500] 5 %float]
  .^(@ux %cx /(scot %p ship)/tensor/(scot %da now)/data/fc2-weight/mnist)
  =/  b1  
  %-  spac:la
  :-  [~[500 1] 5 %float]
  .^(@ux %cx /(scot %p ship)/tensor/(scot %da now)/data/fc1-bias/mnist)
  =/  b2
  %-  spac:la
  :-  [~[100 1] 5 %float]
  .^(@ux %cx /(scot %p ship)/tensor/(scot %da now)/data/fc2-bias/mnist)
  ~[(linear:nn w1 b1) relu:nn (linear:nn w2 b2)]
:: 
++  load-image
  |=  i=@
  ^-  ray:la
  =/  dat  .^(@ %cx /(scot %p ship)/tensor/(scot %da now)/data/(scot %ud i)/mnist)
  %-  spac:la
  :-  [~[784 1] 5 %float]
  %+  rep  5 
  %+  turn
    (rip 3 dat)
  |=  e=@
  (sun:rs e)
++  load-labels
  ^-  (list @)
  =/  dat  .^(@ %cx /(scot %p ship)/tensor/(scot %da now)/data/labels/mnist)
  (rip 3 dat)
--