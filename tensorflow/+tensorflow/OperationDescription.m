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
      assert(ischar(op_type), 'Provided operation tupe must be a string.');
      assert(ischar(op_name), 'Provided operation name must be a string.');

      % create operation description
      obj = obj@util.mixin.Pointer(mex_call('TF_NewOperation', graph.ref, op_type, op_name));

      obj.status = tensorflow.Status();
    end

    % TF_CAPI_EXPORT extern void TF_SetDevice(TF_OperationDescription* desc, const char* device);
    % TODO

    % TF_CAPI_EXPORT extern void TF_AddInput(TF_OperationDescription* desc, TF_Output input);
    function addInput(obj, inp)
      assert(isa(inp, 'tensorflow.Output'), 'Provided input must be of class tensorflow.Output.');
      mex_call('TF_AddInput', obj.ref, inp.ref);
    end

    % TF_CAPI_EXPORT extern void TF_AddInputList(TF_OperationDescription* desc, const TF_Output* inputs, int num_inputs);
    % TODO

    % TF_CAPI_EXPORT extern void TF_AddControlInput(TF_OperationDescription* desc, TF_Operation* input);
    % TODO

    % TF_CAPI_EXPORT extern void TF_ColocateWith(TF_OperationDescription* desc, TF_Operation* op);
    % TODO

    % TF_CAPI_EXPORT extern void TF_SetAttrString(TF_OperationDescription* desc, const char* attr_name, const void* value, size_t length);
    % TODO

    % TF_CAPI_EXPORT extern void TF_SetAttrStringList(TF_OperationDescription* desc, const char* attr_name,  const void* const* values,  const size_t* lengths,  int num_values);
    % TODO

    % TF_CAPI_EXPORT extern void TF_SetAttrInt(TF_OperationDescription* desc, const char* attr_name, int64_t value);
    % TODO

    % TF_CAPI_EXPORT extern void TF_SetAttrIntList(TF_OperationDescription* desc, const char* attr_name, const int64_t* values, int num_values);
    % TODO

    % TF_CAPI_EXPORT extern void TF_SetAttrFloat(TF_OperationDescription* desc, const char* attr_name, float value);
    % TODO

    % TF_CAPI_EXPORT extern void TF_SetAttrFloatList(TF_OperationDescription* desc, const char* attr_name, const float* values, int num_values);
    % TODO

    % TF_CAPI_EXPORT extern void TF_SetAttrBool(TF_OperationDescription* desc, const char* attr_name, unsigned char value);
    % TODO

    % TF_CAPI_EXPORT extern void TF_SetAttrBoolList(TF_OperationDescription* desc, const char* attr_name, const unsigned char* values, int num_values);
    % TODO

    % TF_CAPI_EXPORT extern void TF_SetAttrType(TF_OperationDescription* desc, const char* attr_name, TF_DataType value);
    function setAttrType(obj, type)
      if ~isa(type, 'tensorflow.DataType')
        assert(ismember(type, enumeration('tensorflow.DataType')), 'Provided data type cannot be interpreted.');
        type = tensorflow.DataType(type);
      end
      mex_call('TF_SetAttrType', obj.ref, 'dtype', uint32(type));
    end

    % TF_CAPI_EXPORT extern void TF_SetAttrTypeList(TF_OperationDescription* desc, const char* attr_name, const TF_DataType* values, int num_values);
    % TODO

    % TF_CAPI_EXPORT extern void TF_SetAttrPlaceholder(TF_OperationDescription* desc, const char* attr_name, const char* placeholder);
    % TODO

    % TF_CAPI_EXPORT extern void TF_SetAttrFuncName(TF_OperationDescription* desc, const char* attr_name, const char* value, size_t length);
    % TODO

    % TF_CAPI_EXPORT extern void TF_SetAttrShape(TF_OperationDescription* desc, const char* attr_name, const int64_t* dims, int num_dims);
    function setAttrShape(obj, dims)
      assert(numel(dims) > 0, 'Number of dimension must be greater than zero.');
      num_dims = numel(dims);
      mex_call('TF_SetAttrShape', obj.ref, 'shape', int64(dims), int32(num_dims));
    end

    % TF_CAPI_EXPORT extern void TF_SetAttrShapeList(TF_OperationDescription* desc, const char* attr_name, const int64_t* const* dims, const int* num_dims, int num_shapes);
    % TODO

    % TF_CAPI_EXPORT extern void TF_SetAttrTensorShapeProto(TF_OperationDescription* desc, const char* attr_name, const void* proto, size_t proto_len, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern void TF_SetAttrTensorShapeProtoList(TF_OperationDescription* desc, const char* attr_name, const void* const* protos, const size_t* proto_lens, int num_shapes, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern void TF_SetAttrTensor(TF_OperationDescription* desc, const char* attr_name, TF_Tensor* value, TF_Status* status);
    function setAttrTensor(obj, tensor)
      assert(isa(tensor, 'tensorflow.Tensor'), 'Provided tensor must be of class tensorflow.Tensor.');
      mex_call('TF_SetAttrTensor', obj.ref, 'value', tensor.ref, obj.status.ref);
      obj.status.maybe_raise();
    end

    % TF_CAPI_EXPORT extern void TF_SetAttrTensorList(TF_OperationDescription* desc, const char* attr_name, TF_Tensor* const* values, int num_values, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern void TF_SetAttrValueProto(TF_OperationDescription* desc, const char* attr_name, const void* proto, size_t proto_len, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern TF_Operation* TF_FinishOperation(TF_OperationDescription* desc, TF_Status* status);
    function oper = finishOperation(obj)
      ref = mex_call('TF_FinishOperation', obj.ref, obj.status.ref);
      obj.status.maybe_raise();
      oper = tensorflow.Operation(ref);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function delete(obj)
      if ~obj.isempty()
        mex_call('TFM_DeleteOperationDescription', obj.ref);
      end
      delete@util.mixin.Pointer(obj);
    end

  end
end
