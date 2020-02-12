# Quick start

## Requirements
To install and use tensorflow.m, you will need the following:
- a recent version of MATLAB or Octave (check the remarks on [compatibility](Compatibility))
- a C compiler (set up to build the MEX file)
- internet access to download the TensorFlow libraries (if not already downloaded)

tensorflow.m **does not** depend on any MATLAB/Octave toolboxes or other third-party libraries.

## Installation

**Clone** the repository to your preferred location
```bash
git clone git@github.com:asteinh/tensorflow.m.git rootdir
```
where we will refer to the root directory as `rootdir`.

tensorflow.m comes with a **setup function** that sets up the path, builds the MEX interface and generates TensorFlow operations.
Fire up MATLAB/Octave, change your directory to `rootdir` and run `setup.m`. Especially the automatic generation of operations might take a while, so stay tuned.

If the setup finishes without any errors, you're good to go on and run a first example.

## First steps
We will now quickly introduce some key functionality of tensorflow.m. For more details, have a look at the [API documentation](api-doc/index).

More often than not, your implementation will start with a plain graph, which is initialized by
```matlab
graph = tensorflow.Graph();
```

This graph subsequently allows us to use TensorFlow's operations, e.g.
```matlab
c = graph.constant(rand(2,3)); % creates a constant 2-by-3 tensor
```
To evaluate an operation, we need to create a session
```matlab
session = tensorflow.Session(graph);
```
and then run the outputs we want to obtain
```matlab
c_val = session.run([], [], c).value();
```
Note the appended `.value()`, which fetches the numeric values of a tensor.

## Where to go from here
You're all set.
Feel free to head over to [the examples](examples/index) and have a go at more complex examples, or start working on your own project.
For details on available operations, etc. take a look at the [API documentation](api-doc/index).
