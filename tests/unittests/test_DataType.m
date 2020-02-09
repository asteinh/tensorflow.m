function test_suite = test_DataType()
  test_functions = localfunctions();
  initTestSuite;

  function test_constructors()
    d0 = tensorflow.DataType(1);
    d1 = tensorflow.DataType(2);
    dA = tensorflow.DataType('TF_FLOAT');
    dB = tensorflow.DataType('TF_DOUBLE');

    drevA = tensorflow.DataType('single');
    drevB = tensorflow.DataType('double');

    d_cpy = tensorflow.DataType(d0);

    assertTrue(d0 == dA);
    assertTrue(d0 == d_cpy);
    assertTrue(drevA == dA);
    assertTrue(drevB == dB);
    assertFalse(d0 == d1);
    assertFalse(d0 == dB);
    assertFalse(d1 == dA);

    assertTrue(d0 ~= dB);
    assertTrue(d0 <= dB);
    assertTrue(d0 <= dA);
    assertTrue(d0 <  dB);

    assertTrue(d1 ~= dA);
    assertTrue(d0 >= dA);
    assertTrue(d1 >= dA);
    assertTrue(d1 >  dA);

    assertExceptionThrown(@() tensorflow.DataType([]), 'tensorflow:DataType:InputArguments');

  function test_utilities()
    d = tensorflow.DataType(2);
    assertEqual(d.DataTypeSize, 8);

    testdouble = 1.0;
    assertEqual(tensorflow.DataType.m2tf(testdouble), 'TF_DOUBLE');
    assertEqual(tensorflow.DataType.m2tf('double'), 'TF_DOUBLE');

    assertFalse(tensorflow.DataType.ismember(0));
    assertTrue(tensorflow.DataType.ismember('TF_BOOL'));
    assertTrue(tensorflow.DataType.ismember('logical'));
    assertFalse(tensorflow.DataType.ismember(logical(0)));
