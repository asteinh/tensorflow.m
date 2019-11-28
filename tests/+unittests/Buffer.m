classdef Buffer < matlab.unittest.TestCase
  methods (Test)
    % testing constructors of Buffer
    function constructors(testCase)
      % case: buffer from char array
      bufA = tensorflow.Buffer(rand_char_arr(1000)); % elseif nargin == 1 && ischar(varargin{1})

      % case: buffer from ref
      bufB = tensorflow.Buffer(bufA.ref); % if nargin == 1 && isa(varargin{1}, 'uint64')
      testCase.assertEqual(bufA.ref, bufB.ref);

      % case 3: empty buffer
      buf = tensorflow.Buffer(); % elseif nargin == 0
      testCase.assertEmpty(buf.data());
      buf.deleteBuffer();

      % otherwise
      testCase.verifyError(@() tensorflow.Buffer(double(0)), 'tensorflow:Buffer:InputArguments');
    end

    % testing utility functions
    function utilities(testCase)
      buf = tensorflow.Buffer();
      sz = 1000;
      data_tx = rand_char_arr(sz);
      buf.data(data_tx);
      data_rx = buf.data();
      testCase.assertEqual(uint8(data_tx), data_rx);
      testCase.assertEqual(sz, buf.length());
    end

    % testing file IO
    function fileIO(testCase)
      % generate random file name for temporary storage
      fname = ['tensorflow_m_unittest_' rand_char_arr(10) '.bin'];
      floc = fullfile(tempdir, fname);

      % two buffer sizes: 100 byte & 1 Mb
      for sz = [100 1e6]
        rbuf = tensorflow.Buffer();
        wbuf = tensorflow.Buffer();
        data_tx = rand_char_arr(sz);
        wbuf.data(data_tx);
        wbuf.write_file(floc); % write to file
        rbuf.read_file(floc); % read from file
        delete(floc);
        data_rx = rbuf.data();
        testCase.assertEqual(uint8(data_tx), data_rx);
      end
    end
  end
end
