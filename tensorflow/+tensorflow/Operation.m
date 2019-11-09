classdef Operation < util.mixin.Pointer
  %OPERATION Summary of this class goes here
  %   Detailed explanation goes here

  methods
    function obj = Operation(ref_)
      assert(isa(ref_, 'uint64'));
      obj = obj@util.mixin.Pointer(ref_);
    end

    % TF_CAPI_EXPORT extern const char* TF_OperationName(TF_Operation* oper);
    function res = name(obj)
      res = mex_call('TF_OperationName', obj.ref);
    end

    % TF_CAPI_EXPORT extern const char* TF_OperationOpType(TF_Operation* oper);
    function res = opType(obj)
      res = mex_call('TF_OperationOpType', obj.ref);
    end

    % TF_CAPI_EXPORT extern const char* TF_OperationDevice(TF_Operation* oper);
    function res = device(obj)
      res = mex_call('TF_OperationDevice', obj.ref);
    end

    % TF_CAPI_EXPORT extern int TF_OperationNumOutputs(TF_Operation* oper);
    function res = numOutputs(obj)
      res = mex_call('TF_OperationNumOutputs', obj.ref);
    end

    % TF_CAPI_EXPORT extern int TF_OperationOutputListLength(TF_Operation* oper, const char* arg_name, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern int TF_OperationNumInputs(TF_Operation* oper);
    function res = numInputs(obj)
      res = mex_call('TF_OperationNumInputs', obj.ref);
    end

    % TF_CAPI_EXPORT extern int TF_OperationInputListLength(TF_Operation* oper, const char* arg_name, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern int TF_OperationNumControlInputs(TF_Operation* oper);
    function res = numControlInputs(obj)
      res = mex_call('TF_OperationNumControlInputs', obj.ref);
    end

    % TF_CAPI_EXPORT extern int TF_OperationGetControlInputs(TF_Operation* oper, TF_Operation** control_inputs, int max_control_inputs);
    % TODO

    % TF_CAPI_EXPORT extern int TF_OperationNumControlOutputs(TF_Operation* oper);
    function res = numControlOutputs(obj)
      res = mex_call('TF_OperationNumControlOutputs', obj.ref);
    end

    % TF_CAPI_EXPORT extern int TF_OperationGetControlOutputs(TF_Operation* oper, TF_Operation** control_outputs, int max_control_outputs);
    % TODO

    % TF_CAPI_EXPORT extern TF_AttrMetadata TF_OperationGetAttrMetadata(TF_Operation* oper, const char* attr_name, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern void TF_OperationGetAttrString(TF_Operation* oper, const char* attr_name, void* value, size_t max_length, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern void TF_OperationGetAttrStringList(TF_Operation* oper, const char* attr_name, void** values, size_t* lengths, int max_values, void* storage, size_t storage_size, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern void TF_OperationGetAttrInt(TF_Operation* oper, const char* attr_name, int64_t* value, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern void TF_OperationGetAttrIntList(TF_Operation* oper, const char* attr_name, int64_t* values, int max_values, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern void TF_OperationGetAttrFloat(TF_Operation* oper, const char* attr_name, float* value, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern void TF_OperationGetAttrFloatList(TF_Operation* oper, const char* attr_name, float* values, int max_values, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern void TF_OperationGetAttrBool(TF_Operation* oper, const char* attr_name, unsigned char* value, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern void TF_OperationGetAttrBoolList(TF_Operation* oper, const char* attr_name, unsigned char* values, int max_values, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern void TF_OperationGetAttrType(TF_Operation* oper, const char* attr_name, TF_DataType* value, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern void TF_OperationGetAttrTypeList(TF_Operation* oper, const char* attr_name, TF_DataType* values, int max_values, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern void TF_OperationGetAttrShape(TF_Operation* oper, const char* attr_name, int64_t* value, int num_dims, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern void TF_OperationGetAttrShapeList(TF_Operation* oper, const char* attr_name, int64_t** dims, int* num_dims, int num_shapes, int64_t* storage, int storage_size, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern void TF_OperationGetAttrTensorShapeProto(TF_Operation* oper, const char* attr_name, TF_Buffer* value, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern void TF_OperationGetAttrTensorShapeProtoList(TF_Operation* oper, const char* attr_name, TF_Buffer** values, int max_values, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern void TF_OperationGetAttrTensor(TF_Operation* oper, const char* attr_name, TF_Tensor** value, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern void TF_OperationGetAttrTensorList(TF_Operation* oper, const char* attr_name, TF_Tensor** values, int max_values, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern void TF_OperationGetAttrValueProto(TF_Operation* oper, const char* attr_name, TF_Buffer* output_attr_value, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern void TF_OperationToNodeDef(TF_Operation* oper, TF_Buffer* output_node_def, TF_Status* status);
    % TODO

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function delete(obj)
      if ~obj.isempty()
        mex_call('TFM_DeleteOperation', obj.ref);
      end
      delete@util.mixin.Pointer(obj);
    end

  end
end
