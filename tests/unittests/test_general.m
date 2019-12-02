function test_suite = test_general()
  test_functions = localfunctions();
  initTestSuite;

  function test_info()
    tensorflow.info();

  function test_version()
    tensorflow.version();
