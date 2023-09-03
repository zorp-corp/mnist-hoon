# MNIST handwritten digit recognition in hoon

Run a pretrained MNIST model from your urbit ship!

![alt-text](https://github.com/zorp-corp/mnist-hoon/blob/master/pred.jpeg)

## Instructions
1. Copy the contents of `desk` into a desk named `%mnist` on a fakezod.
2. This repo comes preloaded with 4 MNIST images taken from the test set. 
To run int8 inference on the first image: `0.mnist` do:

```hoon
+mnist!mnist-q 0
```

Where 0 corresponds to the image's filename.

The generator should output `[%pred 7]`, making it's prediction for the first image the number `7`.

## Replication
The model used was a two-layer fully connected neural network of dimensions (784, 500) and (500, 10). A RELU activation 
was used after the first layer.  Models similar to this one have a reported error in the 1-3% range according to Yann LeCunn's
[website](https://web.archive.org/web/20230201163719/https://yann.lecun.com/exdb/mnist/). We achieved an error rate of 2% for
both quantized and unquantized models.

The model was trained in Google Collab. The script used to pretrain the model can be found in `notebook/mnist.ipynb`. The notebook
goes through the process of pretraining the model, calculating scaling factors, and quantizing the weights
step by step. 

Although inference is done in int8, the format of the array elements are int32 clipped to int8 range (-127, 127). This is purely 
for convenience. In real int8 inference, all of the array elements would be int8, while the bias would be int32. This 
is a space saving measure for when the operation is done in hardware, which we are not doing currently.
