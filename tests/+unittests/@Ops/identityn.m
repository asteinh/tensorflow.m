function identityn(test)
  % REGISTER_OP("IdentityN")
  %   .Input("input: T")
  %   .Output("output: T")
  %   .Attr("T: list(type)")

  graph = tensorflow.Graph();
  session = tensorflow.Session(graph);
  
  testmat = rand(10,2);
  
  desc = graph.newOperation('IdentityN', 'IdentityN_test');
  desc.addInputList([graph.constant(testmat), graph.constant(uint16([1 5 4 4 5]))]);
  desc.setAttrTypeList('T', [tensorflow.DataType('TF_DOUBLE'), tensorflow.DataType('TF_UINT16')]);

  oper = desc.finishOperation();
  
  y = tensorflow.Output(oper);
  res = session.run([], [], y);
  test.verifyEqual(res(1).value, testmat);
end