% A basic regression example for the auto MPG data set
% cf. TensorFlow's example (https://www.tensorflow.org/tutorials/keras/regression)
% data from https://archive.ics.uci.edu/ml/datasets/auto+mpg
clear; clc

%% data
% fetching
fname = 'auto-mpg.data';
websave(fname, 'https://archive.ics.uci.edu/ml/machine-learning-databases/auto-mpg/auto-mpg.data');
raw_data = textscan(strrep(fileread(fname),'?','NaN'), '%f %f %f %f %f %f %f %f %s', 'Delimiter','\n');
map = zeros(size(raw_data{1},1),3); % 1: USA, 2: Europe, 3: Japan
for i = 1:1:size(map,1)
  map(i,raw_data{8}(i)) = 1;
end

% cleansing
%   columns: MPG, Cylinders, Displacement, Horsepower, Weight, Acceleration, Model Year, Origin
data = [raw_data{1:7} map]; % concatenate numeric values
data = data(~sum(isnan(data),2),:); % drop NaN values
rng(2020);
data = data(randi(size(data,1), size(data,1), 1),:); % randomize

ntrain = 314;
ntest = size(data,1)-ntrain;

train_data = data(1:ntrain,2:end);
train_labels = data(1:ntrain,1);
test_data = data(ntrain+1:end,2:end);
test_labels = data(ntrain+1:end,1);

% normalization
train_data_mean = mean(train_data);
train_data_std = std(train_data);
train_data_norm = (train_data - repmat(train_data_mean,ntrain,1))./repmat(train_data_std,ntrain,1);
test_data_norm = (test_data - repmat(train_data_mean,ntest,1))./repmat(train_data_std,ntest,1);

% train_data_norm = train_data;
% test_data_norm = test_data;

clear fname raw_data
%%
model = mlp([size(train_data_norm,2) 64 64 1], 0);

% arguments: X, y, nepoch, learning_rate, gamma_mean, gamma_mom
[f, w, b] = model.fit(train_data_norm, train_labels, 1000, 32, 0.001, 0.9, 0.9);

yfit = model.predict(train_data_norm);
yhat = model.predict(test_data_norm);

figure(1);
  subplot(4,2,1);
    stem(yfit-train_labels);
  subplot(4,2,3);
    stem(yhat-test_labels);
  subplot(2,2,2);
    plot([min(test_labels) max(test_labels)], [min(test_labels) max(test_labels)], 'k--'); hold on;
    plot(test_labels, yhat, 'bo'); hold off;
    xlabel('real MPG'); ylabel('predicted MPG'); grid on;
  subplot(2,2,3);
    semilogy(f); grid on;
