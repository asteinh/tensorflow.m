function output = mul(obj, x, y, op_name)
% doc

  assert(nargin >= 3 && nargin <= 4, 'Wrong number of input arguments.');
  assert(isa(x, 'tensorflow.Output') && isa(y, 'tensorflow.Output'), 'Provided arguments must be of class tensorflow.Output.');
  if nargin < 4
    [~, op_name] = util.KeyGen.sha1();
  end

  desc = obj.newOperation('Mul', ['Mul_' op_name]);
  desc.addInput(x);
  desc.addInput(y);

  % TODO handle control inputs
  % foreach ( TFOperation control in CurrentDependencies )
  %   desc.AddControlInput (control);

  oper = desc.finishOperation();
  output = tensorflow.Output(oper);
  
end