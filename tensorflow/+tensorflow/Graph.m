classdef Graph < util.mixin.Pointer
  %GRAPH Summary of this class goes here
  %   Detailed explanation goes here

  properties (SetAccess=protected)
    status = [];
  end

  methods
    function obj = Graph()
      % superclass constructor
      obj = obj@util.mixin.Pointer(mex_call('TF_NewGraph'));

      obj.status = tensorflow.Status();
    end

    function output = const(obj, tensor)
      error('Not yet implemented.');

      % desc = tensorflow.OperationDescription(obj, 'Constant', ['Constant_' op_name]);
      %
    	% desc = TF_NewOperation(graph, "Const", name);
    	% TF_SetAttrTensor(desc, "value", tensor, status);
    	% TF_SetAttrType(desc, "dtype", TF_TensorType(tensor));
    	% return TF_FinishOperation(desc, status);
      %
      % oper = desc.finishOperation();
      % output = tensorflow.Output(oper, 1);
    end

    function output = placeholder(obj, dtype, shape, op_name)
      if nargin < 2 || nargin > 4
        error('Wrong number of input arguments.');
      end
      if nargin < 4
        [~, op_name] = util.KeyGen.sha1();
      end
      if nargin < 3
        shape = [];
      end

      desc = tensorflow.OperationDescription(obj, 'Placeholder', ['Placeholder_' op_name]);

      % TODO handle control inputs
      % foreach ( TFOperation control in CurrentDependencies )
      %   desc.AddControlInput (control);

      desc.setAttrType(dtype);
      if ~isempty(shape)
        desc.setAttrShape(shape);
      end

      oper = desc.finishOperation();
      output = tensorflow.Output(oper, 1);
    end

    function output = add(obj, x, y, op_name)
      if nargin < 3 || nargin > 4
        error('Wrong number of input arguments.');
      end
      assert(isa(x, 'tensorflow.Output'));
      assert(isa(y, 'tensorflow.Output'));
      if nargin < 4
        [~, op_name] = util.KeyGen.sha1();
      end

      desc = tensorflow.OperationDescription(obj, 'Add', ['Add_' op_name]);
      desc.addInput(x);
      desc.addInput(y);

      oper = desc.finishOperation();
      output = tensorflow.Output(oper, 1);
    end

    function output = mul(obj, x, y, op_name)
      if nargin < 3 || nargin > 4
        error('Wrong number of input arguments.');
      end
      assert(isa(x, 'tensorflow.Output'));
      assert(isa(y, 'tensorflow.Output'));
      if nargin < 4
        [~, op_name] = util.KeyGen.sha1();
      end

      desc = tensorflow.OperationDescription(obj, 'Mul', ['Mul_' op_name]);
      desc.addInput(x);
      desc.addInput(y);

      % TODO handle control inputs
      % foreach ( TFOperation control in CurrentDependencies )
      %   desc.AddControlInput (control);

      oper = desc.finishOperation();
      output = tensorflow.Output(oper, 1);
    end

    % TF_CAPI_EXPORT extern void TF_GraphSetTensorShape(TF_Graph* graph, TF_Output output, const int64_t* dims, const int num_dims, TF_Status* status);
    function setTensorShape(obj, output, dims)
      mex_call('TF_GraphSetTensorShape', obj.ref, output.ref, int64(dims), int32(numel(dims)), obj.status.ref);
    end

    % TF_CAPI_EXPORT extern int TF_GraphGetTensorNumDims(TF_Graph* graph, TF_Output output, TF_Status* status);
    function dims = getTensorNumDims(obj, output)
      assert(isa(output, 'tensorflow.Output'));
      dims = mex_call('TF_GraphGetTensorNumDims', obj.ref, output.ref, obj.status.ref);
    end

    % TF_CAPI_EXPORT extern void TF_GraphGetTensorShape(TF_Graph* graph, TF_Output output, int64_t* dims, int num_dims, TF_Status* status);
    function dims = getTensorShape(obj, output)
      assert(isa(output, 'tensorflow.Output'));
      dims = mex_call('TF_GraphGetTensorShape', obj.ref, output.ref, obj.status.ref);
    end

    function delete(obj)
      if ~obj.isempty()
        mex_call('TF_DeleteGraph', obj.ref);
      end
      delete@util.mixin.Pointer(obj);
    end
  end
end
