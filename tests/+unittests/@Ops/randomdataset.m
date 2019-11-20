function randomdataset(test)
  % REGISTER_OP("RandomDataset")
  %   .Input("seed: int64")
  %   .Input("seed2: int64")
  %   .Output("handle: variant")
  %   .Attr("output_types: list(type) >= 1")
  %   .Attr("output_shapes: list(shape) >= 1")

  graph = tensorflow.Graph();
  session = tensorflow.Session(graph);
  
  seeds = int64(randi([-1e6 1e6], [1 2]));
  dtypes = tensorflow.DataType(randi([1 23], [1 10]));
  shapes = cell(10,1);
  for i=1:numel(shapes)
    ndims = randi([1 4]);
    shapes{i} = randi([1 5], [1 ndims]);
  end
  
  desc = graph.newOperation('RandomDataset', 'RandomDataset_test');
  desc.addInput(graph.constant(seeds(1)));
  desc.addInput(graph.constant(seeds(2)));
  desc.setAttrTypeList('output_types', dtypes);
  desc.setAttrShapeList('output_shapes', shapes);

  y = tensorflow.Output(desc.finishOperation());
  res = session.run([], [], y);
  random_datasets = res(1).value();

end