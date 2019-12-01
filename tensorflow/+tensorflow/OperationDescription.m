classdef OperationDescription < util.mixin.Pointer
  %OPERATIONDESCRIPTION Summary of this class goes here
  %   Detailed explanation goes here

  properties
    status = [];
  end

  methods
    % TF_CAPI_EXPORT extern TF_OperationDescription* TF_NewOperation(TF_Graph* graph, const char* op_type, const char* oper_name);
    function obj = OperationDescription(graph, op_type, op_name)
      assert(isa(graph, 'tensorflow.Graph'), 'Provided graph must be of class tensorflow.Graph.');
      assert(ischar(op_type), 'Provided operation type must be a string.');
      assert(ischar(op_name), 'Provided operation name must be a string.');

      % create operation description
      ref = tensorflow_m_('TF_NewOperation', graph.ref, op_type, op_name);
      obj.set_reference_(ref, true);

      obj.status = tensorflow.Status();
    end

    % TF_CAPI_EXPORT extern void TF_SetDevice(TF_OperationDescription* desc, const char* device);
    function setDevice(obj, device)
      assert(ischar(device), 'Device must be provided as a string.');
      tensorflow_m_('TF_SetDevice', obj.ref, device(:)');
    end

    % TF_CAPI_EXPORT extern void TF_AddInput(TF_OperationDescription* desc, TF_Output input);
    function addInput(obj, inp)
      assert(isa(inp, 'tensorflow.Output'), 'Provided input must be of class tensorflow.Output.');
      tensorflow_m_('TF_AddInput', obj.ref, inp.ref);
    end

    % TF_CAPI_EXPORT extern void TF_AddInputList(TF_OperationDescription* desc, const TF_Output* inputs, int num_inputs);
    function addInputList(obj, inps)
      assert(isa(inps, 'tensorflow.Output'), 'Provided inputs must be of class tensorflow.Output.');
      tensorflow_m_('TF_AddInputList', obj.ref, [inps.ref]);
    end

    % TF_CAPI_EXPORT extern void TF_AddControlInput(TF_OperationDescription* desc, TF_Operation* input);
    function addControlInput(obj, inp)
      assert(isa(inp, 'tensorflow.Operation'), 'Provided input must be of class tensorflow.Operation.');
      tensorflow_m_('TF_AddControlInput', obj.ref, inp.ref);
    end

    % TF_CAPI_EXPORT extern void TF_ColocateWith(TF_OperationDescription* desc, TF_Operation* op);
    function colocateWith(obj, op)
      assert(isa(op, 'tensorflow.Operation'), 'Provided operation must be of class tensorflow.Operation.');
      tensorflow_m_('TF_ColocateWith', obj.ref, op.ref);
    end

    % TF_CAPI_EXPORT extern void TF_SetAttrString(TF_OperationDescription* desc, const char* attr_name, const void* value, size_t length);
    function setAttrString(obj, attr, str)
      obj.assert_attr_(attr);
      assert(ischar(str), 'Provided string must be a char array.');
      tensorflow_m_('TF_SetAttrString', obj.ref, attr(:)', uint8(str(:)'));
    end

    % TF_CAPI_EXPORT extern void TF_SetAttrStringList(TF_OperationDescription* desc, const char* attr_name,  const void* const* values,  const size_t* lengths,  int num_values);
    function setAttrStringList(obj, attr, strs)
      obj.assert_attr_(attr);
      assert(iscell(strs) && all(cellfun(@(x) ischar(x), strs)), 'Provided strings must be supplied as a cell of char arrays.');
      tensorflow_m_('TF_SetAttrStringList', obj.ref, attr(:)', strs(:)');
    end

    % TF_CAPI_EXPORT extern void TF_SetAttrInt(TF_OperationDescription* desc, const char* attr_name, int64_t value);
    function setAttrInt(obj, attr, value)
      obj.assert_attr_(attr);
      assert(isinteger(value), 'Provided value must be an integer.');
      tensorflow_m_('TF_SetAttrInt', obj.ref, attr(:)', int64(value));
    end

    % TF_CAPI_EXPORT extern void TF_SetAttrIntList(TF_OperationDescription* desc, const char* attr_name, const int64_t* values, int num_values);
    function setAttrIntList(obj, attr, values)
      obj.assert_attr_(attr);
      assert(isinteger(values), 'Provided values must be integers.');
      tensorflow_m_('TF_SetAttrIntList', obj.ref, attr(:)', int64(values(:)'));
    end

    % TF_CAPI_EXPORT extern void TF_SetAttrFloat(TF_OperationDescription* desc, const char* attr_name, float value);
    function setAttrFloat(obj, attr, value)
      obj.assert_attr_(attr);
      assert(isa(value, 'single'), 'Provided value must be of class single.');
      tensorflow_m_('TF_SetAttrFloat', obj.ref, attr(:)', value);
    end

    % TF_CAPI_EXPORT extern void TF_SetAttrFloatList(TF_OperationDescription* desc, const char* attr_name, const float* values, int num_values);
    function setAttrFloatList(obj, attr, values)
      obj.assert_attr_(attr);
      assert(isa(values, 'single'), 'Provided values must be of class single.');
      tensorflow_m_('TF_SetAttrFloatList', obj.ref, attr(:)', values(:)');
    end

    % TF_CAPI_EXPORT extern void TF_SetAttrBool(TF_OperationDescription* desc, const char* attr_name, unsigned char value);
    function setAttrBool(obj, attr, value)
      obj.assert_attr_(attr);
      assert(isa(value, 'logical'), 'Provided value must be of class logical.');
      tensorflow_m_('TF_SetAttrBool', obj.ref, attr(:)', value);
    end

    % TF_CAPI_EXPORT extern void TF_SetAttrBoolList(TF_OperationDescription* desc, const char* attr_name, const unsigned char* values, int num_values);
    function setAttrBoolList(obj, attr, values)
      obj.assert_attr_(attr);
      assert(isa(values, 'logical'), 'Provided values must be of class logical.');
      tensorflow_m_('TF_SetAttrBoolList', obj.ref, attr(:)', uint8(values(:))');
    end

    % TF_CAPI_EXPORT extern void TF_SetAttrType(TF_OperationDescription* desc, const char* attr_name, TF_DataType value);
    function setAttrType(obj, attr, dtype)
      obj.assert_attr_(attr);
      dtype = tensorflow.DataType(dtype);
      tensorflow_m_('TF_SetAttrType', obj.ref, attr(:)', uint32(dtype));
    end

    % TF_CAPI_EXPORT extern void TF_SetAttrTypeList(TF_OperationDescription* desc, const char* attr_name, const TF_DataType* values, int num_values);
    function setAttrTypeList(obj, attr, dtypes)
      obj.assert_attr_(attr);
      if ~isa(dtypes, 'tensorflow.DataType')
        dtypes_ = dtypes;
        dtypes = [];
        for i = 1:1:numel(dtypes_)
          dtypes = [dtypes; tensorflow.DataType(dtypes_(i))];
        end
      end
      tensorflow_m_('TF_SetAttrTypeList', obj.ref, attr(:)', uint32(dtypes(:))');
    end

    % TF_CAPI_EXPORT extern void TF_SetAttrPlaceholder(TF_OperationDescription* desc, const char* attr_name, const char* placeholder);
    function setAttrPlaceholder(obj, attr, ph)
      obj.assert_attr_(attr);
      assert(ischar(ph), 'Provided placeholder identifier must be a char array.');
      tensorflow_m_('TF_SetAttrPlaceholder', obj.ref, attr(:)', ph(:)');
    end

    % TF_CAPI_EXPORT extern void TF_SetAttrFuncName(TF_OperationDescription* desc, const char* attr_name, const char* value, size_t length);
    function setAttrFuncName(obj, attr, funcname)
      obj.assert_attr_(attr);
      assert(ischar(funcname), 'Provided function name must be a char array.');
      tensorflow_m_('TF_SetAttrFuncName', obj.ref, attr(:)', funcname(:)');
    end

    % TF_CAPI_EXPORT extern void TF_SetAttrShape(TF_OperationDescription* desc, const char* attr_name, const int64_t* dims, int num_dims);
    function setAttrShape(obj, attr, dims)
      obj.assert_attr_(attr);
      assert(numel(dims) > 0, 'Number of dimension must be greater than zero.');
      num_dims = numel(dims);
      tensorflow_m_('TF_SetAttrShape', obj.ref, attr(:)', int64(dims), int32(num_dims));
    end

    % TF_CAPI_EXPORT extern void TF_SetAttrShapeList(TF_OperationDescription* desc, const char* attr_name, const int64_t* const* dims, const int* num_dims, int num_shapes);
    function setAttrShapeList(obj, attr, dimlist)
      obj.assert_attr_(attr);
      assert(iscell(dimlist) && all(cellfun(@(x) isnumeric(x), dimlist)), 'List of shapes must be provided as cell of numeric arrays.');
      dimlist = cellfun(@(x) int64(x), dimlist, 'UniformOutput', false);
      tensorflow_m_('TF_SetAttrShapeList', obj.ref, attr(:)', dimlist(:)');
    end

    % TF_CAPI_EXPORT extern void TF_SetAttrTensorShapeProto(TF_OperationDescription* desc, const char* attr_name, const void* proto, size_t proto_len, TF_Status* status);
    % NOT_SUPPORTED

    % TF_CAPI_EXPORT extern void TF_SetAttrTensorShapeProtoList(TF_OperationDescription* desc, const char* attr_name, const void* const* protos, const size_t* proto_lens, int num_shapes, TF_Status* status);
    % NOT_SUPPORTED

    % TF_CAPI_EXPORT extern void TF_SetAttrTensor(TF_OperationDescription* desc, const char* attr_name, TF_Tensor* value, TF_Status* status);
    function setAttrTensor(obj, attr, tensor)
      obj.assert_attr_(attr);
      assert(isa(tensor, 'tensorflow.Tensor'), 'Provided tensor must be of class tensorflow.Tensor.');
      tensorflow_m_('TF_SetAttrTensor', obj.ref, attr(:)', tensor.ref, obj.status.ref);
      obj.status.maybe_raise();
    end

    % TF_CAPI_EXPORT extern void TF_SetAttrTensorList(TF_OperationDescription* desc, const char* attr_name, TF_Tensor* const* values, int num_values, TF_Status* status);
    function setAttrTensorList(obj, attr, tensors)
      obj.assert_attr_(attr);
      assert(isa(tensors, 'tensorflow.Tensor'), 'Provided tensors must be of class tensorflow.Tensor.');
      tensorflow_m_('TF_SetAttrTensorList', obj.ref, attr(:)', [tensors.ref], obj.status.ref);
      obj.status.maybe_raise();
    end

    % TF_CAPI_EXPORT extern void TF_SetAttrValueProto(TF_OperationDescription* desc, const char* attr_name, const void* proto, size_t proto_len, TF_Status* status);
    % NOT_SUPPORTED

    % TF_CAPI_EXPORT extern TF_Operation* TF_FinishOperation(TF_OperationDescription* desc, TF_Status* status);
    function oper = finishOperation(obj)
      ref = tensorflow_m_('TF_FinishOperation', obj.ref, obj.status.ref);
      obj.status.maybe_raise();
      oper = tensorflow.Operation(ref);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function delete(obj)
      if obj.isdeletable()
        tensorflow_m_('TFM_DeleteOperationDescription', obj.ref);
      end
      delete@util.mixin.Pointer(obj);
    end

  end

  methods (Access=private)
    function assert_attr_(obj, attr)
      % Validate if given argument is a valid attribute
      assert(ischar(attr) && isvector(attr), 'Provided attribute must be a one-dimensional char array.');
      % TODO cross-check with defined attributes of this op description
    end
  end
end
