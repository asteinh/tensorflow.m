clear; clc;
addpath('../../tensorflow');

url_model = 'https://storage.googleapis.com/download.tensorflow.org/models/inception5h.zip';

%% fetching data
disp('Fetching required data ...');

if exist('data/model.zip', 'file') ~= 2
  disp('Downloading model ...');
  websave('data/model.zip', url_model);
else
  disp('Model already present.');
end

delete('data/model/*');

disp('Extracting files ...');
files = unzip('data/model.zip','data/model');
for f = files
  if contains(f, '.pb'); model_file = f{:};
  elseif contains(f, '.txt'); labels_file = f{:}; end
end

% image
image_file = websave('data/images/terrier.jpg', 'https://cdn.pixabay.com/photo/2014/05/13/07/44/yorkshire-terrier-343198_960_720.jpg');

disp('Data fetching done.');

%% pre-processing
disp('Pre-processing ...');

% image
isize = 224;
mean = 117;
scale = 1;

img_raw = imread(image_file);
img = imresize(img_raw, [isize isize]);
img = (single(img)-single(mean))./scale; % casting and normalization
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
input_oper = graph.operationByName('input');
input_layer = tensorflow.Output(input_oper, 1);
output_oper = graph.operationByName('output');
output_layer = tensorflow.Output(output_oper, 1);

% create session
session = tensorflow.Session(graph);

disp('Pre-processing done.');

%% execution
disp('Running inference ...');

res = session.run(input_layer, img_t, output_layer);

[vals, indices] = maxk(res.data(), 5);
figure(); plot(res.data());

% result should be 'military uniform'
% assert(strcmp(labels{indices(1)}, 'military uniform'))

disp('Top labels:');
for i = indices
  idx = find(i==indices,1);
  fprintf('\t[%.3f] %s\n', vals(idx), labels{i});
end
