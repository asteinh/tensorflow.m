clear;
addpath('../../tensorflow');
tensorflow.info % pre status

graph = tensorflow.Graph();
session = tensorflow.Session(graph);
a = graph.placeholder('TF_DOUBLE');
b = graph.placeholder('TF_DOUBLE');
y = graph.mul(a, b);

aVal = randn([2 5]);
bVal = randn([2 5]);
exptd = aVal.*bVal;
res = session.run([a, b], ...
                  [tensorflow.Tensor(aVal), tensorflow.Tensor(bVal)], ...
                  [y]);
mulRes = res(1).value();

tensorflow.info % post status

clear graph
