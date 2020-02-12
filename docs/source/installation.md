# Installation

If you have sufficient user rights to adapt the path, this setup will automatically add the required paths to your MATLAB/Octave path.
It will further automatically download the TensorFlow libraries and unpack them to `rootdir/tensorflow/mex/third-party`, unless it finds an already available library in a number of default locations, including the user's downloads folder.

## Flags
The setup checks for the existence/value of some variables which you can set prior to running the function.

- `DEBUG`: a boolean (logical) flag; produces debug output if set to true

- `LIBTENSORFLOW`: a string (char array) hinting to the location of the TensorFlow library; if you have downloaded/built the shared library manually, set this variable to the root location (i.e. where LICENSE can be found) of the download

If you provide a path to a manually downloaded library folder, the library (even if not found in the hinted path) will not be automatically downloaded.
