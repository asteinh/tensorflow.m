function output = add(obj, x, y, varargin)
% doc

  assert(isa(x, 'tensorflow.Output'));
  assert(isa(y, 'tensorflow.Output'));
  assert(nargin >= 3 && nargin <= 4);
  if nargin == 4
    assert(ischar(varargin{1}));
    op_name = varargin{1};
  else
    [~, op_name] = util.KeyGen.sha1();
  end

  desc = obj.newOperation('Add', ['Add_' op_name]);
  
  desc.addInput(x);
  desc.addInput(y);

  oper = desc.finishOperation();
  output = tensorflow.Output(oper);
  
end

