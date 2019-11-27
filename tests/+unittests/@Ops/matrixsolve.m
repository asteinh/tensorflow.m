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
  b = graph.placeholder('TF_DOUBLE', 'shape', [10 1]);
  y = graph.matrixsolve(graph.constant(A), b, 'adjoint', true);

  bval = rand(10,1);
  res = session.run([b], [tensorflow.Tensor(bval)], [y]);
  test.verifyTrue(norm(res(1).value-(A.')\bval) < 1e-6);
end
