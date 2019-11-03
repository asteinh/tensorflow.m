classdef OperationDescription < util.mixin.Pointer
  %OPERATIONDESCRIPTION Summary of this class goes here
  %   Detailed explanation goes here

  properties
    status = [];
  end
  
  methods
    function obj = OperationDescription(graph, op_type, op_name)
      assert(isa(graph, 'tensorflow.Graph'));
      assert(ischar(op_type));
      assert(ischar(op_name));

      % create operation description
      obj = obj@util.mixin.Pointer(mex_call('TF_NewOperation', graph.ref, op_type, op_name));

      obj.status = tensorflow.Status();
    end

    % TF_CAPI_EXPORT extern void TF_SetDevice(TF_OperationDescription* desc, const char* device);
    % TF_CAPI_EXPORT extern void TF_AddInput(TF_OperationDescription* desc, TF_Output input);
    function addInput(obj, inp)
      assert(isa(inp, 'tensorflow.Output'));
      mex_call('TF_AddInput', obj.ref, inp.ref);
    end

    % TF_CAPI_EXPORT extern void TF_AddInputList(TF_OperationDescription* desc, const TF_Output* inputs, int num_inputs);
    % TF_CAPI_EXPORT extern void TF_AddControlInput(TF_OperationDescription* desc, TF_Operation* input);
    % TF_CAPI_EXPORT extern void TF_ColocateWith(TF_OperationDescription* desc, TF_Operation* op);
    % TF_CAPI_EXPORT extern void TF_SetAttrString(TF_OperationDescription* desc, const char* attr_name, const void* value, size_t length);
    % TF_CAPI_EXPORT extern void TF_SetAttrStringList(TF_OperationDescription* desc, const char* attr_name,  const void* const* values,  const size_t* lengths,  int num_values);
    % TF_CAPI_EXPORT extern void TF_SetAttrInt(TF_OperationDescription* desc, const char* attr_name, int64_t value);
    % TF_CAPI_EXPORT extern void TF_SetAttrIntList(TF_OperationDescription* desc, const char* attr_name, const int64_t* values, int num_values);
    % TF_CAPI_EXPORT extern void TF_SetAttrFloat(TF_OperationDescription* desc, const char* attr_name, float value);
    % TF_CAPI_EXPORT extern void TF_SetAttrFloatList(TF_OperationDescription* desc, const char* attr_name, const float* values, int num_values);
    % TF_CAPI_EXPORT extern void TF_SetAttrBool(TF_OperationDescription* desc, const char* attr_name, unsigned char value);
    % TF_CAPI_EXPORT extern void TF_SetAttrBoolList(TF_OperationDescription* desc, const char* attr_name, const unsigned char* values, int num_values);
    % TF_CAPI_EXPORT extern void TF_SetAttrType(TF_OperationDescription* desc, const char* attr_name, TF_DataType value);
    function setAttrType(obj, type_)
      assert(ischar(type_) && ismember(type_, enumeration('tensorflow.DataType')));
      type = tensorflow.DataType(type_);
      mex_call('TF_SetAttrType', obj.ref, 'dtype', uint32(type));
    end

    % TF_CAPI_EXPORT extern void TF_SetAttrTypeList(TF_OperationDescription* desc, const char* attr_name, const TF_DataType* values, int num_values);
    % TF_CAPI_EXPORT extern void TF_SetAttrPlaceholder(TF_OperationDescription* desc, const char* attr_name, const char* placeholder);
    % TF_CAPI_EXPORT extern void TF_SetAttrFuncName(TF_OperationDescription* desc, const char* attr_name, const char* value, size_t length);
    % TF_CAPI_EXPORT extern void TF_SetAttrShape(TF_OperationDescription* desc, const char* attr_name, const int64_t* dims, int num_dims);
    function setAttrShape(obj, dims)
      assert(numel(dims) > 0);
      num_dims = numel(dims);
      mex_call('TF_SetAttrShape', obj.ref, 'shape', int64(dims), int32(num_dims));
    end

    % TF_CAPI_EXPORT extern void TF_SetAttrShapeList(TF_OperationDescription* desc, const char* attr_name, const int64_t* const* dims, const int* num_dims, int num_shapes);
    % TF_CAPI_EXPORT extern void TF_SetAttrTensorShapeProto(TF_OperationDescription* desc, const char* attr_name, const void* proto, size_t proto_len, TF_Status* status);
    % TF_CAPI_EXPORT extern void TF_SetAttrTensorShapeProtoList(TF_OperationDescription* desc, const char* attr_name, const void* const* protos, const size_t* proto_lens, int num_shapes, TF_Status* status);
    % TF_CAPI_EXPORT extern void TF_SetAttrTensor(TF_OperationDescription* desc, const char* attr_name, TF_Tensor* value, TF_Status* status);
    % TF_CAPI_EXPORT extern void TF_SetAttrTensorList(TF_OperationDescription* desc, const char* attr_name, TF_Tensor* const* values, int num_values, TF_Status* status);
    % TF_CAPI_EXPORT extern void TF_SetAttrValueProto(TF_OperationDescription* desc, const char* attr_name, const void* proto, size_t proto_len, TF_Status* status);
    % TF_CAPI_EXPORT extern TF_Operation* TF_FinishOperation(TF_OperationDescription* desc, TF_Status* status);
    function oper = finishOperation(obj)
      oper = tensorflow.Operation(mex_call('TF_FinishOperation', obj.ref, obj.status.ref));
      obj.status.maybe_raise();
    end

    function delete(obj)
      if ~obj.isempty()
        mex_call('TFM_DeleteOperationDescription', obj.ref);
      end
      delete@util.mixin.Pointer(obj);
    end

  end
end
