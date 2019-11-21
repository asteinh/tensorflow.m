classdef general < matlab.unittest.TestCase
  methods (Test)
    % testing general functions
    function functions(test)
      tensorflow.info();
      tensorflow.version();
    end
  end
end