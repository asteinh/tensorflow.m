clear; clc;

graph = tensorflow.Graph();
session = tensorflow.Session(graph);

t = graph.constant([0.1 0.5 1.1 1.7 2.5]);

% REGISTER_OP("Bucketize")
%     .Input("input: T")
%     .Output("output: int32")
%     .Attr("T: {int32, int64, float, double}")
%     .Attr("boundaries: list(float)")
%     .SetShapeFn(shape_inference::UnchangedShape);

desc = graph.newOperation('Bucketize', 'Bucketize_test');
desc.addInput(t);
desc.setAttrFloatList('boundaries', single([.75 1 2]));

oper = desc.finishOperation();
y = tensorflow.Output(oper);

res = session.run([], [], y);
buckets = res(1).value()
