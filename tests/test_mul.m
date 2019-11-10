% test_mul - script to test multiplication operations

dtypes = enumeration('tensorflow.DataType')';
ndims = [1:7];

tic;
for dtype = dtypes
  try
    mdtype = dtype.TF2M;
    for nd = ndims
      test_multiplication(dtype, nd);
    end
  catch e
    disp(['Error: ' e.message]);
  end
end
t_mul = toc;
fprintf('Ran mul-tests in %.1f s.\n', t_mul);

%% element-wise multiplication
function test_multiplication(dtype, ndim)
  fprintf('Running %s in %d dimensions.\n', dtype, ndim);
  graph = tensorflow.Graph();
  session = tensorflow.Session(graph);

  a = graph.placeholder(char(dtype));
  b = graph.placeholder(char(dtype));
  y = graph.mul(a, b);

  dims = randi([2 10],1,10);
  dims = dims(1:ndim);

  aVal = cast(randn(dims), dtype.TF2M);
  bVal = cast(randn(dims), dtype.TF2M);
  exptd = aVal.*bVal;

  res = session.run([a, b], ...
                    [tensorflow.Tensor(aVal), tensorflow.Tensor(bVal)], ...
                    [y]);
  mulRes = res(1).data();

  assert(norm(double(exptd(:)-mulRes(:))) < eps);
end
