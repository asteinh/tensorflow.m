# tensorflow.m

Matlab bindings for the [C library of Tensorflow](https://www.tensorflow.org/install/lang_c).

## About
`tensorflow.m` interfaces TensorFlow's C API via a MEX function and Matlab wrapper classes. This software is in active development, you may stumble upon occasional *Not implemented.* messages - feel free to open an issue or contribute via pull requests.

## Install

### Unix/Mac
Download the [TensorFlow C library](https://www.tensorflow.org/install/lang_c) for your platform and extract the content in your download folder - the folder name has to contain `libtensorflow` to be found. Open Matlab (with rights to be able to save the path) and run the `setup.m` function in this repository's root folder.

### Windows
We're working on that...

## Examples
![](docs/img/coco_id_299649_result.jpg)
