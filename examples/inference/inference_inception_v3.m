clear; clc;
addpath('../../tensorflow');

url_model = 'https://storage.googleapis.com/download.tensorflow.org/models/inception_v3_2016_08_28_frozen.pb.tar.gz';

%% fetching data
disp('Fetching required data ...');

if exist('data/model.tar.gz', 'file') ~= 2
  disp('Downloading model ...');
  websave('data/model.tar.gz', url_model);
else
  disp('Model already present.');
end

delete('data/model/*');

disp('Extracting files ...');
files = untar('data/model.tar.gz','data/model');
for f = files
  if contains(f, '.pb'); model_file = f{:};
  elseif contains(f, '.txt'); labels_file = f{:}; end
end

% image
image_file = websave('data/images/grace_hopper.jpg', 'https://storage.googleapis.com/download.tensorflow.org/example_images/grace_hopper.jpg');

disp('Data fetching done.');

%% pre-processing
disp('Pre-processing ...');

% image
isize = 299;
mean = 0;
scale = 255;

img_raw = single(imread(image_file));
img = imresize(img_raw, [isize isize]);
img = (img-mean)./scale; % casting and normalization
img = reshape(img, [1, size(img)]); % adding batch dimension
img_t = tensorflow.Tensor(img);

% labels
fid = fopen(labels_file);
labels = textscan(fid, '%s', 'Delimiter', '\n'); labels = labels{1};
fclose(fid);

% read in saved graph into buffer
buf = tensorflow.Buffer();
buf.read_file(model_file);

% create graph and import buffered description
graph = tensorflow.Graph();
opts = tensorflow.ImportGraphDefOptions();
graph.importGraphDef(buf, opts);

% fetch input and output layers, identified by their name
input_layer = tensorflow.Output(graph.operationByName('input'));
output_layer = tensorflow.Output(graph.operationByName('InceptionV3/Predictions/Reshape_1'));

% create session
session = tensorflow.Session(graph);

disp('Pre-processing done.');

%% execution
disp('Running inference ...');

tic;
res = session.run(input_layer, img_t, output_layer);
toc

[vals, indices] = maxk(res.data(), 5);

% result should be 'military uniform'
% assert(strcmp(labels{indices(1)}, 'military uniform'))

disp('Top labels:');
for i = indices
  idx = find(i==indices,1);
  fprintf('\t[%.3f] %s\n', vals(idx), labels{i});
end
