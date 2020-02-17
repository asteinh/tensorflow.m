# Installation details

Let's assume you cloned the repository to your preferred location
```bash
git clone git@github.com:asteinh/tensorflow.m.git rootdir
```
where we will refer to the root directory as `rootdir`.
If you have sufficient user rights to adapt the path, the setup script will automatically add the required paths to your MATLAB/Octave path.
It will further automatically download the TensorFlow libraries and unpack them to `rootdir/tensorflow/mex/third-party`, unless it finds an already available library in a number of default locations, including the user's downloads folder.

## Flags
The setup checks the existence/value of some variables which you can set prior to running the function.

- `DEBUG`: a boolean (logical) flag; produces debug output if set to true

- `LIBTENSORFLOW`: a string (char array) hinting to the location of the TensorFlow library; if you have downloaded/built the shared library manually, set this variable to the root location (i.e. where LICENSE can be found) of the download

If you provide a path to a manually downloaded library folder, the libraries (even if not found in the hinted path) will not be automatically downloaded.

## MEX function

The source of the C MEX interface is located in `rootdir/tensorflow/mex/src`, split into an interface, a utilities and an implementation file. Corresponding headers can be found in `rootdir/tensorflow/mex/include`.
The setup script takes care of linking against required libraries and generates the resulting MEX function `tensorflow_m_.*` in `rootdir/tensorflow/mex/build`.

## Operations

More than 1200 TensorFlow operations are automatically generated during the setup. The corresponding functions are placed in `rootdir/tensorflow/+tensorflow/@Ops` and available to the user as methods of `tensorflow.Graph` objects - `tensorflow.Graph` inherits the `tensorflow.Ops` class.
