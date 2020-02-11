function test_suite = test_Status()
  test_functions = localfunctions();
  initTestSuite;

  function test_utilities()
    s = tensorflow.Status();
    c = tensorflow.Code('TF_UNKNOWN');
    msg = 'Testing status interface...';
    s.setStatus(c, msg);
    assertEqual(s.getCode, c);
    assertEqual(s.message, msg);
    str = char(c);
    assertExceptionThrown(@() s.maybe_raise(), ['tensorflow:Status:' str{1}]);

    s.deleteStatus();
