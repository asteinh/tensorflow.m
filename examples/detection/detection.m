clear; clc;
addpath('../../tensorflow');

% DEBUG = true;

model.name = 'ssd_mobilenet_v2_coco';
model.dl_url = 'http://download.tensorflow.org/models/object_detection/ssd_mobilenet_v2_coco_2018_03_29.tar.gz';
model.isize = 300;
model.mean = 0;
model.scale = 1;

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
  if strcmp(f{1}(end-2:end), '.pb'); model.graph_file = f{:}; end
end

% image
mkdir('data/images');
image_file = websave('data/images/coco_id_299649.jpg', 'https://farm6.staticflickr.com/5296/5480700684_94ebcdeb43_z.jpg');
% image_file = websave('data/images/surfers.jpg', 'https://github.com/tensorflow/tensorflow/raw/master/tensorflow/examples/multibox_detector/data/surfers.jpg');

% labels
label_file = websave('data/coco-labels-paper.txt', 'https://raw.githubusercontent.com/amikelive/coco-labels/master/coco-labels-paper.txt');
fid = fopen(label_file);
model.labels = textscan(fid, '%s', 'Delimiter', '\n'); model.labels = model.labels{1};
fclose(fid);

disp('Data fetching done.');

%% pre-processing
disp('Pre-processing ...');

% image
img_raw = imread(image_file);
img = (imresize(img_raw, [model.isize model.isize])-model.mean)./model.scale;
img_t = tensorflow.Tensor(reshape(img, [1, size(img)]));

% read in saved graph into buffer
buf = tensorflow.Buffer().read_file(model.graph_file);

% create graph and import buffered description
graph = tensorflow.Graph();
opts = tensorflow.ImportGraphDefOptions();
graph.importGraphDef(buf, opts);

% fetch input and output layers, identified by their name
tf_input = tensorflow.Output(graph.operationByName('image_tensor'));
tf_scores = tensorflow.Output(graph.operationByName('detection_scores'));
tf_boxes = tensorflow.Output(graph.operationByName('detection_boxes'));
tf_classes = tensorflow.Output(graph.operationByName('detection_classes'));
tf_num_detections = tensorflow.Output(graph.operationByName('num_detections'));

% create session
session = tensorflow.Session(graph);

disp('Pre-processing done.');

%% execution
disp('Running inference ...');

tic;
res = session.run(tf_input, img_t, [tf_scores tf_boxes tf_classes tf_num_detections]);
toc

detection_threshold = 0.3;

% postprocessing
detection_scores = res(1).value;
detection_boxes = res(2).value; detection_boxes = reshape(detection_boxes(:), [4, 100]);
detection_classes = res(3).value;
num_detections = min(res(4).value, sum(detection_scores > detection_threshold));

% load('python_results.mat');
% detection_scores = double(detection_scores);
% detection_boxes = squeeze(detection_boxes);
% detection_classes = detection_classes;
% num_detections = numel(find(detection_scores > detection_threshold));

image(img)

for i = 1:1:num_detections
  boxlim = double(detection_boxes(:,i));
  xmin = boxlim(2)*model.isize;
  ymin = boxlim(1)*model.isize;
  dx = (boxlim(4)-boxlim(2))*model.isize;
  dy = (boxlim(3)-boxlim(1))*model.isize;
  hold on;
  score = (detection_scores(i)-detection_threshold)/(1-detection_threshold);
  label = model.labels{detection_classes(i)};
  col = perc_to_col(score);
  rectangle('position', [xmin ymin dx dy], 'edgecolor', col, 'linewidth', 2);
  text(xmin, ymin-6, sprintf('%s @ %.2f', model.labels{detection_classes(i)}, detection_scores(i)), 'color', col);
  hold off;
end

function rgb = perc_to_col(p)
  assert(p >= 0 && p <= 1);
  rgb = p*[0 1 0] + (1-p)*[1 0 0];
end