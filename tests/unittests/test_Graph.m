function test_suite = test_Graph()
  test_functions = localfunctions();
  initTestSuite;

function test_interface()
  % Testing interface of Graph
  graph = tensorflow.Graph();
  dims = [5 4];

  % constants
  c1 = graph.constant(rand(5));
  c2 = graph.constant(single(rand(3)), 'name', 'test_c2');

  % placeholders
  p1 = graph.placeholder('TF_UINT64');
  p2 = graph.placeholder('TF_DOUBLE', 'shape', dims);
  p3 = graph.placeholder('TF_DOUBLE', 'shape', [2 3], 'name', 'test_p3');

  % get tensor shape
  dims_check = graph.getTensorShape(p2);
  assertEqual(dims, dims_check);
  % change tensor shape
  graph.setTensorShape(p1, repmat(dims,1,2));
  dims_check = graph.getTensorShape(p1);
  assertEqual(repmat(dims,1,2), dims_check);

  % get number of dimensions
  numdims_check = graph.getTensorNumDims(p1);
  assertEqual(numdims_check, 2*numel(dims));
  numdims_check = graph.getTensorNumDims(p2);
  assertEqual(numdims_check, numel(dims));

  % retrieve operation
  c2_op = graph.operationByName('test_c2');
  p3_op = graph.operationByName('test_p3');

  % manual deletion
  graph.deleteGraph();

function test_gradient()
  graph = tensorflow.Graph();
  session = tensorflow.Session(graph);

  x = graph.placeholder('TF_FLOAT');
  y = graph.square(x);
  grad1 = graph.addGradients(y, x);
  grad2 = graph.addGradients(graph.square(y), x);

  res = session.run(x, tensorflow.Tensor(single(1)), grad1).value();
  assertEqual(res, single(2));
  res = session.run(x, tensorflow.Tensor(single(5)), grad1).value();
  assertEqual(res, single(10));
  res = session.run(x, tensorflow.Tensor(single(5)), grad2).value();
  assertEqual(res, single(500));
