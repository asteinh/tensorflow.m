# tensorflow.m

Matlab bindings for the [C library of Tensorflow](https://www.tensorflow.org/install/lang_c).

[![CircleCI](https://img.shields.io/circleci/build/github/asteinh/tensorflow.m/master?style=flat-square)](https://circleci.com/gh/asteinh/tensorflow.m)
[![codecov](https://img.shields.io/codecov/c/github/asteinh/tensorflow.m/master?style=flat-square)](https://codecov.io/gh/asteinh/tensorflow.m)
[![Gitter](https://img.shields.io/gitter/room/tensorflowm/community?color=rgb%2870%2C%20188%2C%20153%29&style=flat-square)](https://gitter.im/tensorflowm/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
[![Issues](https://img.shields.io/github/issues-raw/asteinh/tensorflow.m?style=flat-square)](https://github.com/asteinh/tensorflow.m/issues)
[![License](https://img.shields.io/github/license/asteinh/tensorflow.m?style=flat-square)](https://github.com/asteinh/tensorflow.m/blob/master/LICENSE)

### About
`tensorflow.m` interfaces TensorFlow's C API via a MEX function and Matlab wrapper classes. This software is in active development, you may stumble upon occasional *Not implemented.* messages - feel free to open an issue or contribute via pull requests.

The development of these MATLAB bindings obeys [the recommended approach](https://github.com/tensorflow/docs/blob/master/site/en/r1/guide/extend/bindings.md) to the best of our capabilities.

### Install

To install `tensorflow.m` you call the `setup()` function in `setup.m`, located in the root directory of the repository. If not provided (see *Flags* hereafter) nor found in a number of default search locations, the setup will automatically download and unpack the latest [TensorFlow C library](https://www.tensorflow.org/install/lang_c) into `tensorflow/mex/`.

**Note** Observed in MATLAB R2019b, on Linux/Mac: MATLAB's `untar` function doesn't seem to appreciate symlinks, which will break the automated download&unpack (yielding the error `file not recognized: File truncated`). You can avoid this problem by manually downloading and unpacking the C library [from here](https://www.tensorflow.org/install/lang_c) and either placing it e.g. in your `$HOME/Downloads/` directory or pointing the setup to its location using the `LIBTENSORFLOW` variable (see below).

###### Flags
The setup checks for the existence/value of two variables which you can set prior to running the function:

- `DEBUG`: a boolean (logical) flag; produces debug output if set to true
- `LIBTENSORFLOW`: a string (char array) hinting to the location of the TensorFlow library; if you have downloaded/built the shared library manually, set this variable to the root location (i.e. where LICENSE can be found) of the download

  **Note** If you provide a path to a manually downloaded library folder, the library (even if not found in the hinted path) will *not* be automatically downloaded.
