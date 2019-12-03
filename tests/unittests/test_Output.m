function test_suite = test_Output()
  test_functions = localfunctions();
  initTestSuite;

  function test_constructors()
    o1 = tensorflow.Output();

    g = tensorflow.Graph();
    o2 = g.constant(rand(5,3));
    o3 = tensorflow.Output(o2.ref, false);

    assertEqual(o2.ref, o3.ref);
    o3.delete();
    o2.delete();

    t = tensorflow.Tensor(logical(0));
    desc = g.newOperation('Const', 'const_tester');
    desc.setAttrTensor('value', t);
    desc.setAttrType('dtype', t.type);
    o4 = tensorflow.Output(desc.finishOperation(), 1);

    assertEqual(o4.numConsumers, 0);

    assertExceptionThrown(@() tensorflow.Output('foo', 'bar', 'miss'), 'tensorflow:Output:InputArguments');
