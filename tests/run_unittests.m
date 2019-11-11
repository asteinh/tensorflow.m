clear; clc;
addpath('../tensorflow');

import matlab.unittest.TestSuite
import matlab.unittest.TestRunner
import matlab.unittest.plugins.CodeCoveragePlugin

runner = TestRunner.withTextOutput;
runner.addPlugin(CodeCoveragePlugin.forFolder('../tensorflow/+tensorflow'));

suite = TestSuite.fromPackage('tests');
result = runner.run(suite);
