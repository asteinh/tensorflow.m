function test_suite = test_Code()
  test_functions = localfunctions();
  initTestSuite;

  function test_constructors()
    c0 = tensorflow.Code(0);
    c1 = tensorflow.Code(1);
    cA = tensorflow.Code('TF_OK');
    cB = tensorflow.Code('TF_CANCELLED');

    c_cpy = tensorflow.Code(c0);

    assertTrue(c0 == cA);
    assertTrue(c0 == c_cpy);
    assertFalse(c0 == c1);
    assertFalse(c0 == cB);
    assertFalse(c1 == cA);

    assertTrue(c0 ~= cB);
    assertTrue(c0 <= cB);
    assertTrue(c0 <= cA);
    assertTrue(c0 <  cB);

    assertTrue(c1 ~= cA);
    assertTrue(c0 >= cA);
    assertTrue(c1 >= cA);
    assertTrue(c1 >  cA);

    assertExceptionThrown(@() tensorflow.Code([]), 'tensorflow:Code:InputArguments');
