clear; clc;
addpath('../../tensorflow');

% DEBUG = true;

% choose a model to be used
model.name = 'inception_v3';

switch(model.name)
  case 'nasnet_large'
    model.dl_url = 'https://storage.googleapis.com/download.tensorflow.org/models/tflite/model_zoo/upload_20180427/nasnet_large_2018_04_27.tgz';
    model.input = 'input';
    model.output = 'final_layer/predictions';
    model.isize = 299;
    model.mean = 0;
    model.scale = 255;
  case 'inception_v3'
    model.dl_url = 'https://storage.googleapis.com/download.tensorflow.org/models/inception_v3_2016_08_28_frozen.pb.tar.gz';
    model.input = 'input';
    model.output = 'InceptionV3/Predictions/Reshape_1';
    model.isize = 299;
    model.mean = 0;
    model.scale = 255;
end

%% fetching data
disp('Fetching required data ...');
mkdir('data/');

model.dl_file = ['data/model-' model.name '.tar.gz'];
if exist(model.dl_file, 'file') ~= 2
  disp('Downloading model ...');
  websave(model.dl_file, model.dl_url);
else
  disp('Model already present.');
end
if exist('data/model','dir') == 7; rmdir('data/model', 's'); end

disp('Extracting files ...');
files = untar(model.dl_file, 'data/model');
for f = files
  if strcmp(f{1}(end-2:end), '.pb'); model.graph_file = f{:};
  elseif contains(f, '.txt'); model.labels_file = f{:}; end
end

% image
mkdir('data/images');
image_file = websave('data/images/grace_hopper.jpg', 'https://storage.googleapis.com/download.tensorflow.org/example_images/grace_hopper.jpg');

disp('Data fetching done.');

%% pre-processing
disp('Pre-processing ...');

% image
img_raw = single(imread(image_file));
img = imresize(img_raw, [model.isize model.isize]);
img = (img-model.mean)./model.scale; % casting and normalization
img = reshape(img, [1, size(img)]); % adding batch dimension
img_t = tensorflow.Tensor(img);

% labels
fid = fopen(model.labels_file);
model.labels = textscan(fid, '%s', 'Delimiter', '\n'); model.labels = model.labels{1};
fclose(fid);

% read in saved graph into buffer
buf = tensorflow.Buffer();
buf.read_file(model.graph_file);

% create graph and import buffered description
graph = tensorflow.Graph();
opts = tensorflow.ImportGraphDefOptions();
graph.importGraphDef(buf, opts);

% fetch input and output layers, identified by their name
input_layer = tensorflow.Output(graph.operationByName(model.input));
output_layer = tensorflow.Output(graph.operationByName(model.output));

% create session
session = tensorflow.Session(graph);

disp('Pre-processing done.');

%% execution
disp('Running inference ...');

tic;
res = session.run(input_layer, img_t, output_layer);
toc

[vals, indices] = maxk(res(1).value(), 5);

% result should be 'military uniform'
assert(strcmp(model.labels{indices(1)}, 'military uniform'))

disp('Top labels:');
for i = indices
  idx = find(i==indices,1);
  fprintf('\t[%.3f] %s\n', vals(idx), model.labels{i});
end
