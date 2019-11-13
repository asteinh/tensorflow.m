classdef MathOps < matlab.unittest.TestCase
  methods (Test)
    function add(testCase)
      % Testing addition

%       dtypes = enumeration('tensorflow.DataType')';
      dtypes = tensorflow.DataType({'TF_FLOAT', 'TF_DOUBLE', 'TF_INT32'});
      ndims = [1:5]; % considered dimensions

      graph = tensorflow.Graph();
      session = tensorflow.Session(graph);

      for dtype = dtypes
        try
          mdtype = tensorflow.DataType.tf2m(dtype);
          for nd = ndims
            dims = randi([2 10], 1, nd);
            aVal = rand_tensor([dims 1], mdtype);
            bVal = rand_tensor([dims 1], mdtype);
            exptd = aVal+bVal;

            y = graph.add(graph.constant(aVal), graph.constant(bVal));
            res = session.run([], [], y);
            addRes = res(1).value();
            testCase.verifyEqual(exptd(:), addRes(:));
          end
        catch e
          if strcmp(e.identifier, 'tensorflow:DataType:tf2m')
            disp(['Error: ' e.message]);
          else
            disp(e);
          end
        end
      end
    end

    function mul(testCase)
      % Testing element-wise multiplication

%       dtypes = enumeration('tensorflow.DataType')';
      dtypes = tensorflow.DataType({'TF_FLOAT', 'TF_DOUBLE', 'TF_INT64'});
      ndims = [1:5]; % considered dimensions

      graph = tensorflow.Graph();
      session = tensorflow.Session(graph);

      for dtype = dtypes
        try
          mdtype = tensorflow.DataType.tf2m(dtype);
          for nd = ndims
            dims = randi([2 10], 1, nd);
            aVal = rand_tensor([dims 1], mdtype);
            bVal = rand_tensor([dims 1], mdtype);
            exptd = aVal.*bVal;

            y = graph.mul(graph.constant(aVal), graph.constant(bVal));
            res = session.run([], [], y);
            mulRes = res(1).value();
            testCase.verifyEqual(exptd(:), mulRes(:));
          end
        catch e
          if strcmp(e.identifier, 'tensorflow:DataType:tf2m')
            disp(['Error: ' e.message]);
          else
            disp(e);
          end
        end
      end
    end
  end
end
