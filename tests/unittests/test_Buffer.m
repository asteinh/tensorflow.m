function test_suite = test_Buffer()
  test_functions = localfunctions();
  initTestSuite;

  % testing constructors of Buffer
  function test_constructors()
    % case: buffer from char array
    bufA = tensorflow.Buffer(rand_char_arr(1000)); % elseif nargin == 1 && ischar(varargin{1})

    % case: buffer from ref
    bufB = tensorflow.Buffer(bufA.ref); % if nargin == 1 && isa(varargin{1}, 'uint64')
    assertEqual(bufA.data, bufB.data);

    bufC = tensorflow.Buffer(bufA.ref, true);
    assertEqual(bufA.data, bufC.data);

    assertExceptionThrown(@() tensorflow.Buffer(bufA.ref, 'miss'), 'tensorflow:Buffer:InputArguments');

    % case 3: empty buffer
    buf = tensorflow.Buffer(); % elseif nargin == 0
    assertTrue(isempty(buf.data()));
    buf.deleteBuffer();

    % otherwise
    assertExceptionThrown(@() tensorflow.Buffer(double(0)), 'tensorflow:Buffer:InputArguments');

  % testing utility functions
  function test_utilities()
    buf = tensorflow.Buffer();
    sz = 1000;
    data_tx = rand_char_arr(sz);
    buf.data(data_tx);
    data_rx = buf.data();
    assertEqual(uint8(data_tx), data_rx);
    assertEqual(sz, buf.length());

  % testing file IO
  function test_fileIO()
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
      assertEqual(uint8(data_tx), data_rx);
    end

  function str = rand_char_arr(len)
    symbols = ['a':'z' 'A':'Z' '0':'9'];
    nums = randi(numel(symbols), [1 len]);
    str = symbols(nums);
