% Building a simple MLP implemented with basic TF operations.
clear; clc

% settings
layers = [64, 10, 10];

learning_rate = 0.999;
lambda = 1e-6;

nepoch = 1000;
nbatch = 1;

seed = 2020;

%% data
websave('data.csv', 'https://www.openml.org/data/get_csv/28/dataset_28_optdigits.arff');
data = csvread('data.csv', 1);
ntrain = 200;
xdata = data(1:ntrain,1:end-1);
ydata = zeros(ntrain,10);
for i =1:1:ntrain
  ydata(i, 1+data(i,end)) = 1;
end

%% building the MLP
n_layers = numel(layers);
rng(seed);
seeds = int32(randi(1e4, n_layers-1, 2)); % seeds for random normal dists

g = tensorflow.Graph();
s = tensorflow.Session(g);

% placeholders for inputs/outputs; '-1' represents 'None'
x = g.placeholder(tensorflow.DataType('TF_DOUBLE'), 'shape', [-1, layers(1)]);
y = g.placeholder(tensorflow.DataType('TF_DOUBLE'), 'shape', [-1, layers(end)]);

% values for initialization
stddev = g.constant(1.0);
mean = g.constant(0.0);
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
  w_shape = g.constant(int32([layers(i); layers(i+1)]));
  rnd = g.randomstandardnormal(w_shape, tensorflow.DataType('TF_DOUBLE'), 'seed', seeds(i,1));
  w_init = g.add(g.mul(rnd, stddev), mean);
  w_assign = [w_assign; g.assign(w_, w_init)];

  % bias
  b_ = g.variable([1 layers(i+1)], tensorflow.DataType('TF_DOUBLE'), 'name', ['b' num2str(i)]);
  b = [b; b_];
  b_shape = g.constant(int32([1; layers(i+1)]));
  rnd = g.randomstandardnormal(b_shape, tensorflow.DataType('TF_DOUBLE'), 'seed', seeds(i,2));
  b_init = g.add(g.mul(rnd, stddev), mean);
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

% initialize (only run target operations)
s.run([],[],[w_assign; b_assign]);

% objective
cost = g.add( ...
         g.mean(g.square(g.sub(y,pred)), g.constant(int32([0; 1]))), ... % loss
         g.mul(g.constant(lambda), g.l2loss(w)) ... % regularization
       );

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

%% training, mini-batches
fval = [];
n_per_batch = ntrain/nbatch;
for i = 1:1:nepoch
  idx = randperm(ntrain);
  xdata_ = xdata(idx,:);
  ydata_ = ydata(idx,:);
  for k = 1:1:nbatch
    idx_ = (1:n_per_batch)+n_per_batch*(k-1);
    inputs = [...
      tensorflow.Tensor(xdata_(idx_,:)); ...
      tensorflow.Tensor(ydata_(idx_,:)) ...
    ];
    f = s.run([x; y], inputs, [w_apply; b_apply; cost]);
    fval = [fval; f(end).value];
    fprintf('Loss it %3d = %3.3e\n', i, fval(end));
  end
end

%% post-processing
% final prediciton for full data
res = s.run([x; y], [tensorflow.Tensor(xdata); tensorflow.Tensor(ydata)], pred);

y_raw = res.value;
y_pred = NaN(ntrain,1);
for i = 1:1:ntrain
  y_pred(i) = find(y_raw(i,:)==max(y_raw(i,:)))-1;
end

figure(1);
subplot(2,1,1); plot(fval)
subplot(2,1,2); stem(y_pred-data(1:ntrain,end))
