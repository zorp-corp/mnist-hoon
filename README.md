# MNIST handwritten digit recognition in hoon

Run a pretrained MNIST model from your urbit ship using ONNX weights!

![alt-text](https://github.com/zorp-corp/mnist-hoon/blob/master/pred.jpeg)

## Instructions

1. Copy the contents of `desk` into a desk named `%mnist` on a fakezod.
2. This repo comes preloaded with 9 MNIST images taken from the test set. The filename of each image serves as its label. 
To run inference on the first image: `0.mnist` do:

```hoon
+mnist!run-onnx /=mnist=/data/net-quant/json /=mnist=/data/0/mnist
```

Where `/=mnist=/data/net-quant/json` is the path of the ONNX weight file. The generator should output `[%pred 0]`, making its prediction for the first image the number `0`.

## Replication
The model used was a two-layer fully connected neural network of dimensions (784, 500) and (500, 10). A RELU activation 
was used after the first layer.  Models similar to this one have a reported error in the 1-3% range according to Yann LeCunn's
[website](https://web.archive.org/web/20230201163719/https://yann.lecun.com/exdb/mnist/). We achieved an error rate of 2% for
both quantized and unquantized models.

The model was trained in Google Collab using pytorch. The script used to pretrain the model can be found in `urth/mnist.ipynb`. The notebook walks you through the process of pretraining the model, calculating scaling factors, quantizing the weights, and exporting the weights. The script I used to preprocess the MNIST images before copying them over to urbit is in `process-normalize.py`.

Although inference is done in int8, the format of the array elements are float32 clipped to int8 range [-127, 127]. This is purely 
for convenience. In real int8 inference, all of the array elements would be int8, while the bias would be int32. This 
is a space saving measure for when the operation is done in hardware, which we are not doing currently.

##  ONNX
The demo runs by loading weights in the ONNX format. For ease of use, these weights were converted to JSON using the [onnx2json](https://github.com/PINTO0309/onnx2json) tool. We currently support a handful of operations necessary for running this quantized mnist demo. The operations supported are: Gemm, Mul, Div, Round, Clip, Relu, Reshape, Constant.

When you export a torch model to ONNX, it requires you to assign a label to each input and output tensor in your network. For `gen/onnx.hoon`, you must pass in a `(map @t tensor)` where the key is the input name. The `run-onnx` gate also outputs a `(map @t tensor)`, your output tensor(s) and under the key(s) you assigned them during the export step.
