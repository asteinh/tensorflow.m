% Building a simple MLP implemented with basic TF operations.
clear; clc

% settings
layers = [64, 20, 10];
learning_rate = 0.01;
niter = 10;

%% data
websave('data.csv', 'https://www.openml.org/data/get_csv/28/dataset_28_optdigits.arff');
data = csvread('data.csv', 1);
ntrain = 5000;
xdata = data(1:ntrain,1:end-1);
ydata = repmat(data(1:ntrain,end), 1, layers(end));

%% building the MLP
n_layers = numel(layers);
g = tensorflow.Graph();
s = tensorflow.Session(g);

% placeholders for inputs/outputs; '-1' represents 'None'
x = g.placeholder(tensorflow.DataType('TF_DOUBLE'), 'shape', [-1, layers(1)]);
y = g.placeholder(tensorflow.DataType('TF_DOUBLE'), 'shape', [-1, layers(end)]);

% values for initialization
stddev = g.constant(1);
mean = g.constant(0);
seed = 1;

w = [];
w_assign = [];
b = [];
b_assign = [];
y_ = x;
% iterate over layers
for i = 1:1:n_layers-1
  % weights
  w_ = g.variable([layers(i) layers(i+1)], tensorflow.DataType('TF_DOUBLE'), 'name', ['w' num2str(i)]);
  w = [w; w_];
  % randomstandardnormal op
  w_shape = g.constant(int32([layers(i); layers(i+1)]));
  rnd = g.randomstandardnormal(w_shape, tensorflow.DataType('TF_DOUBLE'), 'seed', int32(seed));
  w_init = g.add(g.mul(rnd, stddev), mean);
  % assign op
  w_assign = [w_assign; g.assign(w_, w_init)];

  % bias
  b_ = g.variable([1 layers(i+1)], tensorflow.DataType('TF_DOUBLE'), 'name', ['b' num2str(i)]);
  b = [b; b_];
  % randomstandardnormal op
  b_shape = g.constant(int32([1; layers(i+1)]));
  rnd = g.randomstandardnormal(b_shape, tensorflow.DataType('TF_DOUBLE'), 'seed', int32(seed));
  b_init = g.add(g.mul(rnd, stddev), mean);
  % assign op
  b_assign = [b_assign; g.assign(b_, b_init)];

  % output of layer
  if i == n_layers-1
    if layers(end) == 1
      % output layer for binary classification
      pred = g.sigmoid(g.add(g.matmul(y_, w_), b_));
    else
      % output layer for multiclass
      pred = g.softmax(g.add(g.matmul(y_, w_), b_));
    end
  else
    % hidden layers using ReLU
    y_ = g.relu(g.add(g.matmul(y_, w_), b_));
  end
end

% initialize
s.run([],[],[w_assign; b_assign]);

% objective
cost = g.add( ...
         g.mean(g.square(g.sub(pred, y)), g.constant(int32([0; 1]))), ... % loss
         g.mul(g.constant(1e-6), g.l2loss(w)) ... % regularization
       );
% cost = g.add( ...
%          g.mean(g.mul(g.constant(-1), g.sum(g.mul(y, g.log(g.sub(pred, y))), g.constant(int32(1)))), g.constant(int32(0))), ...
%          g.mul(g.constant(1e-6), g.l2loss(w)) ...
%        );

% backpropagation
w_apply = [];
alpha = g.constant(learning_rate);
for i = 1:1:numel(w)
  gradient = g.addGradients(cost, w(i));
  w_apply = [w_apply; g.applygradientdescent(w(i), alpha, gradient)];
end
b_apply = [];
for i = 1:1:numel(b)
  gradient = g.addGradients(cost, b(i));
  b_apply = [b_apply; g.applygradientdescent(b(i), alpha, gradient)];
end

%%
inputs = [tensorflow.Tensor(xdata); tensorflow.Tensor(ydata)];
for i = 1:1:niter
  f = s.run([x; y], inputs, cost);
  fprintf('Loss it %3d = %3.3d\n', i, f.value);
  res = s.run([x; y], inputs, [w_apply; b_apply; pred]);
end
