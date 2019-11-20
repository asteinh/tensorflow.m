function bucketize(test)
  % REGISTER_OP("Bucketize")
  %   .Input("input: T")
  %   .Output("output: int32")
  %   .Attr("T: {int32, int64, float, double}")
  %   .Attr("boundaries: list(float)")

  graph = tensorflow.Graph();
  session = tensorflow.Session(graph);

  vals = rand(100,1);
  edges = [0; sort(rand(8,1)); 1];
  bins = discretize(vals, edges);
  
  t = graph.constant(vals);
  desc = graph.newOperation('Bucketize', 'Bucketize_test');
  desc.addInput(t);
  desc.setAttrFloatList('boundaries', single(edges));

  oper = desc.finishOperation();
  y = tensorflow.Output(oper);

  res = session.run([], [], y);
  buckets = double(res(1).value());
  
  test.verifyEqual(buckets, bins);
end
