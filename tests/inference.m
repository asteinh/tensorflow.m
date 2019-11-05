% An example of inception, based on
% - https://github.com/tensorflow/tensorflow/tree/master/tensorflow/examples/label_image
% and code provided in
% https://stackoverflow.com/questions/41688217/how-to-load-a-graph-with-tensorflow-so-and-c-api-h-in-c-language

clear; clc;
addpath('../tensorflow');

% read in saved graph into buffer
buf = tensorflow.Buffer();
buf.read_file('../data/inception_v3/inception_v3_2016_08_28_frozen.pb');

% create graph and import buffered description
graph = tensorflow.Graph();
opts = tensorflow.ImportGraphDefOptions();
graph.ImportGraphDef(buf, opts);

assert(graph.status.GetCode == 'TF_OK');
  

