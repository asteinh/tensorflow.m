% Building a simple MLP implemented with basic TF operations.
clear; clc

% settings
layers = [64, 10, 1];

% building the MLP
n_layers = numel(layers);
g = tensorflow.Graph();

% placeholders for inputs/outputs; '-1' represents 'None'
x = g.placeholder(tensorflow.DataType('TF_FLOAT'), 'shape', [-1, layers(1)]);
y = g.placeholder(tensorflow.DataType('TF_FLOAT'), 'shape', [-1, layers(end)]);

% values for initialization
stddev = g.constant(single(1));
mean = g.constant(single(0));
seed = 1;

w = [];
b = [];
y_ = x;
% iterate over layers
for i = 1:1:n_layers-1
  % weights
  w_ = g.variable([layers(i) layers(i+1)], tensorflow.DataType('TF_FLOAT'), 'name', ['w' num2str(i)]);
  w = [w; w_];
  % randomstandardnormal op
  w_shape = g.constant(int32([layers(i); layers(i+1)]));
  rnd = g.randomstandardnormal(w_shape, tensorflow.DataType('TF_FLOAT'), 'seed', int32(seed));
  w_init = g.add(g.mul(rnd, stddev), mean);
  % assign op
  g.assign(w_, w_init);

  % bias
  b_ = g.variable([layers(i+1)], tensorflow.DataType('TF_FLOAT'), 'name', ['b' num2str(i)]);
  b = [b; b_];
  % randomstandardnormal op
  b_shape = g.constant(int32(layers(i+1)));
  rnd = g.randomstandardnormal(b_shape, tensorflow.DataType('TF_FLOAT'), 'seed', int32(seed));
  b_init = g.add(g.mul(rnd, stddev), mean);
  % assign op
  g.assign(b_, b_init);

  % accumulated output of layer
  y_ = g.relu(g.add(g.matmul(y_, w_), b_));
end

% objective
loss = g.add( ...
         g.mean(g.square(g.sub(y_, y)), g.constant(int32([0; 1]))), ... % loss
         g.mul(g.constant(single(1e-6)), g.l2loss(w)) ... % regularization
       );

% backpropagation
gradients = g.addGradients(loss, w);

%TODO
