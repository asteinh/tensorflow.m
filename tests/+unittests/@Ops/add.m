function add(test)
  % REGISTER_OP("Add")
  %   .Input("x: T")
  %   .Input("y: T")
  %   .Output("z: T")
  %   .Attr(
  %       "T: {bfloat16, half, float, double, uint8, int8, int16, int32, int64, "
  %       "complex64, complex128, string}")
  %   .SetShapeFn(shape_inference::BroadcastBinaryOpShapeFn);
  
  dtypes = [ ...
    tensorflow.DataType('TF_FLOAT'), ...
    tensorflow.DataType('TF_DOUBLE'), ...
    tensorflow.DataType('TF_INT32') ...
  ];
  ndims = [1:5]; % considered dimensions

  graph = tensorflow.Graph();
  session = tensorflow.Session(graph);

  for dtype = dtypes
    try
      mdtype = tensorflow.DataType.tf2m(dtype);
      for nd = ndims
        dims = randi([2 10], 1, nd);
        aVal = rand_tensor([dims 1], mdtype);
        bVal = rand_tensor([dims 1], mdtype);
        exptd = aVal+bVal;

        y = graph.add(graph.constant(aVal), graph.constant(bVal));
        res = session.run([], [], y);
        addRes = res(1).value();
        test.verifyEqual(exptd(:), addRes(:));
      end
    catch e
      if strcmp(e.identifier, 'tensorflow:DataType:tf2m')
        disp(['Error: ' e.message]);
      else
        disp(e);
      end
    end
  end
end