classdef GraphTest < matlab.unittest.TestCase
  methods (Test)
    function interface(testCase)
      % Testing interface of Graph
      graph = tensorflow.Graph();
      dims = [5 4];

      % constants
      c1 = graph.constant(rand(5));
      c2 = graph.constant(single(rand(3)), 'test');

      % placeholders
      p1 = graph.placeholder('TF_UINT64');
      p2 = graph.placeholder('TF_DOUBLE', dims);
      p3 = graph.placeholder('TF_DOUBLE', [2 3], 'test');

      % get tensor shape
      dims_check = graph.getTensorShape(p2);
      testCase.verifyEqual(dims, dims_check);
      % change tensor shape
      graph.setTensorShape(p1, repmat(dims,1,2));
      dims_check = graph.getTensorShape(p1);
      testCase.verifyEqual(repmat(dims,1,2), dims_check);

      % get number of dimensions
      numdims_check = graph.getTensorNumDims(p1);
      testCase.verifyEqual(numdims_check, 2*numel(dims));
      numdims_check = graph.getTensorNumDims(p2);
      testCase.verifyEqual(numdims_check, numel(dims));

      % retrieve operation
      c2_op = graph.operationByName('Constant_test');
      p3_op = graph.operationByName('Placeholder_test');

      % manual deletion
      graph.deleteGraph();
    end
  end
end
