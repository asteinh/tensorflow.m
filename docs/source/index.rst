.. tensorflow.m documentation master file, created by
   sphinx-quickstart on Wed Feb 12 08:02:33 2020.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to tensorflow.m's documentation!
========================================

.. toctree::
   :maxdepth: 2
   :hidden:
   :glob:
   :caption: Docs

   quick-start
   installation

.. toctree::
   :maxdepth: 2
   :hidden:
   :glob:

   examples/index

.. toctree::
   :maxdepth: 2
   :hidden:
   :glob:

   api-doc/index

tensorflow.m is a free and open-source MATLAB/Octave package, interfacing `TensorFlow <https://www.tensorflow.org/>`_'s `C API <https://www.tensorflow.org/install/lang_c>`_ without requiring any additional tools.

Looking for an easy way to get started? Check out the `quick start guide <quick-start.html>`_.

This allows you to use the functionality of TensorFlow's core from within MATLAB/Octave via a MEX function and wrapper classes.
Since the purpose of this package is to interface libraries provided by TensorFlow (rather than duplicating code in another language), anything not exposed to the C API is considered beyond the scope.
As an example, modules like ``tf.estimator`` or ``tf.keras`` in Python are not accessible in tensorflow.m.

.. _Compatibility:

Compatibility
-------------
tensorflow.m is written to work for recent versions of MATLAB (tested on R2019b; Windows, macOS and Linux) and Octave.
Unit tests are run against Octave 4.4.1 and 5.1.0 on a Debian x86-64 image.

.. _License:

License
-------
tensorflow.m is licensed under the `Apache License 2.0 <https://www.apache.org/licenses/LICENSE-2.0>`_.

**Note**: This software is in active development, we cannot make any promises regarding the stability of the API.
