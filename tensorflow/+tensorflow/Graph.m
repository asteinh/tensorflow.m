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
      obj.status.maybe_raise();
    end

    % TF_CAPI_EXPORT extern int TF_GraphGetTensorNumDims(TF_Graph* graph, TF_Output output, TF_Status* status);
    function dims = getTensorNumDims(obj, output)
      assert(isa(output, 'tensorflow.Output'));
      dims = mex_call('TF_GraphGetTensorNumDims', obj.ref, output.ref, obj.status.ref);
      obj.status.maybe_raise();
    end

    % TF_CAPI_EXPORT extern void TF_GraphGetTensorShape(TF_Graph* graph, TF_Output output, int64_t* dims, int num_dims, TF_Status* status);
    function dims = getTensorShape(obj, output)
      assert(isa(output, 'tensorflow.Output'));
      dims = mex_call('TF_GraphGetTensorShape', obj.ref, output.ref, obj.status.ref);
      obj.status.maybe_raise();
    end

    % TF_CAPI_EXPORT extern void TF_GraphImportGraphDef(TF_Graph* graph, const TF_Buffer* graph_def, const TF_ImportGraphDefOptions* options, TF_Status* status);
    function importGraphDef(obj, buffer, options)
      assert(isa(buffer, 'tensorflow.Buffer'));
      assert(isa(options, 'tensorflow.ImportGraphDefOptions'));
      mex_call('TF_GraphImportGraphDef', obj.ref, buffer.ref, options.ref, obj.status.ref);
      obj.status.maybe_raise();
    end

    % TF_CAPI_EXPORT extern TF_Operation* TF_GraphOperationByName(TF_Graph* graph, const char* oper_name);
    function oper = operationByName(obj, oper_name)
      assert(ischar(oper_name));
      ref = mex_call('TF_GraphOperationByName', obj.ref, oper_name);
      assert(ref ~= 0, ['Couldn''t find operation by name ''' oper_name '''.']);
      oper = tensorflow.Operation(ref);
    end

    function delete(obj)
      if ~obj.isempty()
        mex_call('TF_DeleteGraph', obj.ref);
      end
      delete@util.mixin.Pointer(obj);
    end
  end
end
