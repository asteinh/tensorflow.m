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
    assertExceptionThrown(@() s.maybe_raise(), ['tensorflow:Status:' char(c)]);

    s.deleteStatus();
