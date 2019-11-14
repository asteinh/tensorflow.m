clear; clc;
addpath('../../tensorflow');

% DEBUG = true;

model.name = 'ssd_mobilenet_v2_coco';
model.dl_url = 'http://download.tensorflow.org/models/object_detection/ssd_mobilenet_v2_coco_2018_03_29.tar.gz';
model.input = 'input';
model.output = 'final_layer/predictions';
model.isize = 300;
model.mean = 0;
model.scale = 255;


%% fetching data
disp('Fetching required data ...');
mkdir('data-detection/');

model.dl_file = ['data-detection/model-' model.name '.tar.gz'];
if exist(model.dl_file, 'file') ~= 2
  disp('Downloading model ...');
  websave(model.dl_file, model.dl_url);
else
  disp('Model already present.');
end
if exist('data-detection/model','dir') == 7; rmdir('data-detection/model', 's'); end

disp('Extracting files ...');
files = untar(model.dl_file, 'data-detection/model');
for f = files
  if strcmp(f{1}(end-2:end), '.pb'); model.graph_file = f{:}; end
end

% image
mkdir('data-detection/images');
% image_file = websave('data-detection/images/coco_id_299649.jpg', 'https://farm6.staticflickr.com/5296/5480700684_94ebcdeb43_z.jpg');
image_file = websave('data-detection/images/tf-test_images-image2.jpg', 'https://github.com/tensorflow/models/raw/master/research/object_detection/test_images/image2.jpg');

disp('Data fetching done.');

%% pre-processing
disp('Pre-processing ...');

% image
img_raw = imread(image_file);
img = imresize(img_raw, [model.isize model.isize]);
img_t = tensorflow.Tensor(reshape(img, [1, size(img)]));

% read in saved graph into buffer
buf = tensorflow.Buffer();
buf.read_file(model.graph_file);

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

% number of detections:
fprintf('Detected %d object(s)!\n', res(4).value);

image(img)

