function test_suite = test_Tensor()
  test_functions = localfunctions();
  initTestSuite;

% testing constructors of Tensor
function test_constructors()
  t0 = tensorflow.Tensor();

  % case: Tensor from data
  t1 = tensorflow.Tensor(rand(randi([2 6], [1 5])));

  % case: Tensor from ref
  t2 = tensorflow.Tensor(t1.ref, false);
  assertEqual(t2.ref, t1.ref);
  t2.deleteTensor();
  t1.deleteTensor();

  % case: Tensor from dtype and dims
  t3 = tensorflow.Tensor('TF_DOUBLE', [6 4]);

  assertExceptionThrown(@() tensorflow.Tensor('foo', 'bar', 'miss'), 'tensorflow:Tensor:InputArguments');

% testing utility functions
function test_utilities()
  vals = int16(randi([-255 255], randi([2 6], [1 3])));
  t = tensorflow.Tensor(vals);

  output = evalc('t.value();');
  assertFalse(isempty(output));

  assertEqual(numel(vals), t.elementCount);
  assertEqual(numel(vals)*2, t.byteSize);

  assertExceptionThrown(@() t.value(vals, 'miss'), 'tensorflow:Tensor:value:InputArguments');

  % check bufferized data
  buf = t.data();
  vals_ = typecast(buf.data(), 'int16'); % have to cast manually
  vals_ = permute(reshape(vals_, fliplr(size(vals))), [numel(size(vals)):-1:1]); % have to transform to column-major manually
  assertEqual(vals, vals_);
