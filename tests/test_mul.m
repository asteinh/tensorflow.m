% test_mul - script to test multiplication operations

dtypes = enumeration('tensorflow.DataType');
ndims = [1 2 3 4 5];

for dtype = dtypes'
  try
    mdtype = dtype.TF2M;
    for nd = ndims
      disp(['Running ' mdtype ' in ' num2str(nd) ' dimensions.']);
      test_multiplication(dtype, nd)
    end
  catch e
    disp(e.message)
  end
end

%% element-wise multiplication
function test_multiplication(dtype, ndim)
  graph = tensorflow.Graph();
  session = tensorflow.Session(graph);
  a = graph.placeholder(char(dtype));
  b = graph.placeholder(char(dtype));
  y = graph.mul(a, b);
  
  dims = randi([2 10],1,5);
  dims = dims(1:ndim);
  
  aVal = cast(randn(dims), dtype.TF2M);
  bVal = cast(randn(dims), dtype.TF2M);
  exptd = aVal.*bVal;
  
%   dtype.TF2M
  
  res = session.run([a, b], ...
                    [tensorflow.Tensor(aVal), tensorflow.Tensor(bVal)], ...
                    [y]);
  mulRes = cast(res(1).data(), dtype.TF2M);
  
  if ndim < 3
    assert(norm(double(exptd-mulRes)) < eps);
    warning('Passing...');
  else
    warning('Not implemented...');
  end
end
