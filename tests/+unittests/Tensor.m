classdef Tensor < matlab.unittest.TestCase
  methods (Test)
    % testing constructors of Tensor
    function constructors(testCase)
      % case: Tensor from data
      t1 = tensorflow.Tensor(rand(randi([2 6], [1 5])));
      
      % case: Tensor from ref
      t2 = tensorflow.Tensor(t1.ref);
      testCase.assertEqual(t2.ref, t1.ref);
      t2.deleteTensor();

      % case: Tensor from dtype and dims
      t3 = tensorflow.Tensor('TF_DOUBLE', [6 4]);

      % otherwise
      testCase.verifyError(@() tensorflow.Tensor(), 'tensorflow:Tensor:InputArguments');
    end
    
    % testing utility functions
    function utilities(testCase)
      vals = int16(randi([-255 255], randi([2 6], [1 3])));
      t = tensorflow.Tensor(vals);
      
      output = evalc('t.value();');
      testCase.assertNotEmpty(output);
      
      testCase.assertEqual(numel(vals), t.elementCount);
      testCase.assertEqual(numel(vals)*2, t.byteSize);
      
      testCase.verifyError(@() t.value(vals, 'miss'), 'tensorflow:Tensor:value:InputArguments');
      
      % check bufferized data
      buf = t.data();
      vals_ = typecast(buf.data(), 'int16'); % have to cast manually
      vals_ = permute(reshape(vals_, fliplr(size(vals))), [numel(size(vals)):-1:1]); % have to transform to column-major manually
      testCase.assertEqual(vals, vals_);
    end
  end
end
