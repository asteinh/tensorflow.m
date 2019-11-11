classdef BufferTest < matlab.unittest.TestCase
  methods (Test)
    function interface(testCase)
      % Testing interface of Buffer
      
      % empty Buffer (de)allocation
      buf = tensorflow.Buffer();
      testCase.assertEmpty(buf.data());
      buf.deleteBuffer();

      % Buffer with length 1000
      buf = tensorflow.Buffer();
      data_tx = rand_char_arr(1000);
      buf.data(data_tx);
      data_rx = buf.data();
      testCase.assertEqual(uint8(data_tx), data_rx)
    end
  end
end
