function matrixsolve(test)
  % REGISTER_OP("MatrixSolve")
  %   .Input("matrix: T")
  %   .Input("rhs: T")
  %   .Output("output: T")
  %   .Attr("adjoint: bool = False")
  %   .Attr("T: {double, float, half, complex64, complex128}")

  graph = tensorflow.Graph();
  session = tensorflow.Session(graph);

  A = rand(10,10);
  b = graph.placeholder('TF_DOUBLE', [10 1]);

  desc = graph.newOperation('MatrixSolve', 'MatrixSolve_test');
  desc.addInput(graph.constant(A));
  desc.addInput(b);
  desc.setAttrBool('adjoint', true);
  desc.setAttrType('T', tensorflow.DataType('TF_DOUBLE'));

  oper = desc.finishOperation();
  y = tensorflow.Output(oper);

  bval = rand(10,1);
  res = session.run([b], [tensorflow.Tensor(bval)], [y]);
  test.verifyTrue(norm(res(1).value-(A.')\bval) < 1e-6);
end
