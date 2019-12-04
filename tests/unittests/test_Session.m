function test_suite = test_Session()
  test_functions = localfunctions();
  initTestSuite;

  function test_constructors()
    g = tensorflow.Graph();
    s = tensorflow.Session(g);

    s2 = tensorflow.Session(s.ref);

    sopt = tensorflow.SessionOptions();
    s3 = tensorflow.Session(g, sopt);
    s3.deleteSession();
    sopt.deleteSessionOptions();

    assertExceptionThrown(@() tensorflow.Session(g, sopt, 'toomany'), 'tensorflow:Session:InputArguments');

  function test_utilities()
    g = tensorflow.Graph();
    s = tensorflow.Session(g);

    assertExceptionThrown(@() s.run(), 'tensorflow:Session:run:InputArguments');
