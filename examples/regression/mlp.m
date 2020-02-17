classdef mlp
  %MLP Summary of this class goes here
  %   Detailed explanation goes here

  properties
    g, s;
    X, y, cost, pred;
    params = [];
    grad = [];
    layers = [];
  end

  methods
    function obj = mlp(layers, lambda)
      %MLP Constructs a simple MLP.

      obj.layers = layers;
      n_layers = numel(layers);
      rng(2020);
      seeds = int32(randi(1e4, n_layers-1, 4)); % seeds for random normal dists

      g = tensorflow.Graph();
      s = tensorflow.Session(g);

      % placeholders for inputs/outputs; '-1' represents 'None'
      obj.X = g.placeholder(tensorflow.DataType('TF_DOUBLE'), 'shape', [-1, layers(1)], 'name', 'X');
      obj.y = g.placeholder(tensorflow.DataType('TF_DOUBLE'), 'shape', [-1, layers(end)], 'name', 'y');

      % values for initialization
      params = [];
      y_layer = obj.X;
      % iterate over layers
      for i = 1:1:n_layers-1
        % weights
        w_ = g.variable([layers(i); layers(i+1)], tensorflow.DataType('TF_DOUBLE'), 'name', ['w' num2str(i)]);
        % bias
        b_ = g.variable([layers(i+1)], tensorflow.DataType('TF_DOUBLE'), 'name', ['b' num2str(i)]);

        stddev = g.constant(1/sqrt(layers(i)));
        % normal
        mean = g.randomstandardnormal(g.shape(w_), tensorflow.DataType('TF_DOUBLE'), 'seed', seeds(i,1));
        rnd = g.randomstandardnormal(g.shape(w_), tensorflow.DataType('TF_DOUBLE'), 'seed', seeds(i,2));
        w_init = g.add(g.mul(rnd, stddev), mean);
        mean = g.randomstandardnormal(g.shape(b_), tensorflow.DataType('TF_DOUBLE'), 'seed', seeds(i,3));
        rnd = g.randomstandardnormal(g.shape(b_), tensorflow.DataType('TF_DOUBLE'), 'seed', seeds(i,4));
        b_init = g.add(g.mul(rnd, stddev), mean);
        % uniform
%         rnd = g.randomuniform(g.shape(w_), tensorflow.DataType('TF_DOUBLE'), 'seed', seeds(i,1));
        % assign initial values
        s.run([],[], [g.assign(w_, w_init); g.assign(b_, b_init)]);

        y_pre = g.add(g.matmul(y_layer, w_), b_);
        if i == n_layers-1
          % output layer (linear)
          obj.pred = y_pre;
        else
          % hidden layers using ReLU
          y_layer = g.relu(y_pre);
        end

        params = [params; w_; b_];
      end

      % objective
      lambda_ = g.constant(lambda);
      obj.cost = g.addn([ ...
        g.mean(g.squareddifference(obj.y, g.transpose(obj.pred, g.constant(int32([1; 0])))), g.constant(int32([0;1]))), ...
        g.mul(lambda_, g.l2loss(params)) ...
      ]);

      % backpropagation
      for i = 1:1:numel(params)
        gradient = g.addGradients(obj.cost, params(i));
        obj.grad = [obj.grad; gradient];
      end

      obj.g = g;
      obj.s = s;
      obj.params = params;
    end

    function [f, w, b] = fit(obj, X, y, nepoch, batchsize, lr, gamma_mean, gamma_mom)
      %FIT Fit weights of MLP to X/y using RMSprop
      %  X ... input data
      %  y ... targets
      %  nepoch ... number of epochs to run
      %  batchsize ... data per batch
      %  lr ... learning rate [0.001]
      %  gamma_mean ... decay rate of mean value [0.9]
      %  gamma_mom ... decay rate of momentum [0.9]

      eta = obj.g.constant(lr);
      gamma = obj.g.constant(gamma_mean);
      mom_decay = obj.g.constant(gamma_mom);
      epsilon = obj.g.constant(1e-16);

      apply_rmsprop = [];
      for i = 1:1:numel(obj.params)
        shape = obj.s.run([],[],obj.g.shape(obj.params(i))).value;
        % mean
        ms = obj.g.variable(shape, tensorflow.DataType('TF_DOUBLE'), 'name', ['ms' num2str(i)]);
        % momentum
        mom = obj.g.variable(shape, tensorflow.DataType('TF_DOUBLE'), 'name', ['mom' num2str(i)]);
        % initialize mean and momentum variables
        obj.s.run([],[], [obj.g.assign(ms, obj.g.zeroslike(ms)); obj.g.assign(mom, obj.g.zeroslike(mom))]);

        % RMSprop update
        apply_ = obj.g.applyrmsprop(obj.params(i), ms, mom, eta, gamma, mom_decay, epsilon, obj.grad(i));
        apply_rmsprop = [apply_rmsprop; apply_];
      end

      ndata = size(X,1);
      nbatch = ceil(ndata/batchsize);
      f = NaN(nepoch*nbatch,1);
      cnt = 0;

      rng(2020);
      for m = 1:1:nepoch
        % in every epoch we shuffle the data
        idx = randi(ndata, ndata, 1);
        X_shuffle = X(idx,:);
        y_shuffle = y(idx,:);

        for n = 1:1:nbatch
          if n == nbatch && nbatch > ndata/batchsize
            batchsize_ = min(batchsize, ndata-(nbatch-1)*batchsize); % make batchsize of last batch adapt to remaining amount of data
          else
            batchsize_ = batchsize;
          end
          cnt = (m-1)*nbatch + n;
          idx = (1:batchsize_)+(n-1)*batchsize;
          batch_input = [ tensorflow.Tensor(X_shuffle(idx,:)), tensorflow.Tensor(y_shuffle(idx,:)) ];

          % run the parameter update
          f(cnt) = obj.s.run([obj.X, obj.y], batch_input, obj.cost).value();

          % abort on nan/inf
          if isnan(f(cnt)) || isinf(f(cnt))
            error('Invalid value encountered - aborting.');
          end

          obj.s.run([obj.X, obj.y], batch_input, [apply_rmsprop; obj.pred]);
        end

        % print output
        if mod(m, 25) == 1
          % informative header
          fprintf('-----------------\n');
          fprintf(' Epoch |   Loss  \n');
          fprintf('-----------------\n');
        end
        fprintf(' %5d | %.2e\n', m, f(cnt));

      end

      res = obj.s.run([],[], obj.params);
      w = res(1:2:end);
      b = res(2:2:end);
    end

    function yhat = predict(obj, X)
      yhat = obj.s.run(obj.X, tensorflow.Tensor(X), obj.pred).value();
    end
  end
end
