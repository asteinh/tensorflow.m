classdef Operation < util.mixin.Pointer
  %OPERATION Summary of this class goes here
  %   Detailed explanation goes here

  properties
    status = [];
  end

  methods
    function obj = Operation(ref)
      assert(isa(ref, 'uint64'));
      obj = obj@util.mixin.Pointer(ref);
      obj.status = tensorflow.Status();
    end

    % TF_CAPI_EXPORT extern const char* TF_OperationName(TF_Operation* oper);
    function res = name(obj)
      res = tensorflow_m_('TF_OperationName', obj.ref);
    end

    % TF_CAPI_EXPORT extern const char* TF_OperationOpType(TF_Operation* oper);
    function res = opType(obj)
      res = tensorflow_m_('TF_OperationOpType', obj.ref);
    end

    % TF_CAPI_EXPORT extern const char* TF_OperationDevice(TF_Operation* oper);
    function res = device(obj)
      res = tensorflow_m_('TF_OperationDevice', obj.ref);
    end

    % TF_CAPI_EXPORT extern int TF_OperationNumOutputs(TF_Operation* oper);
    function res = numOutputs(obj)
      res = double(tensorflow_m_('TF_OperationNumOutputs', obj.ref));
    end

    % TF_CAPI_EXPORT extern int TF_OperationOutputListLength(TF_Operation* oper, const char* arg_name, TF_Status* status);
    function res = outputListLength(obj, name)
      assert(ischar(name), 'Provided output list identifier must be a char array.');
      res = double(tensorflow_m_('TF_OperationOutputListLength', obj.ref, name, obj.status.ref));
      obj.status.maybe_raise();
    end

    % TF_CAPI_EXPORT extern int TF_OperationNumInputs(TF_Operation* oper);
    function res = numInputs(obj)
      res = double(tensorflow_m_('TF_OperationNumInputs', obj.ref));
    end

    % TF_CAPI_EXPORT extern int TF_OperationInputListLength(TF_Operation* oper, const char* arg_name, TF_Status* status);
    function res = inputListLength(obj, name)
      assert(ischar(func), 'Provided input list identifier must be a char array.');
      res = double(tensorflow_m_('TF_OperationInputListLength', obj.ref, name, obj.status.ref));
      obj.status.maybe_raise();
    end

    % TF_CAPI_EXPORT extern int TF_OperationNumControlInputs(TF_Operation* oper);
    function res = numControlInputs(obj)
      res = double(tensorflow_m_('TF_OperationNumControlInputs', obj.ref));
    end

    % TF_CAPI_EXPORT extern int TF_OperationGetControlInputs(TF_Operation* oper, TF_Operation** control_inputs, int max_control_inputs);
    function res = getControlInputs(obj)
      n = obj.numControlInputs();
      if n > 0
        res = tensorflow.Operation.empty(n, 0);
        n_ = double(tensorflow_m_('TF_OperationGetControlInputs', obj.ref, [res.ref], n));
        assert(n == n_, ['Number of fetched control inputs (' n_ ') does not match number of existing control inputs (' n ').']);
      else
        res = [];
      end
    end

    % TF_CAPI_EXPORT extern int TF_OperationNumControlOutputs(TF_Operation* oper);
    function res = numControlOutputs(obj)
      res = double(tensorflow_m_('TF_OperationNumControlOutputs', obj.ref));
    end

    % TF_CAPI_EXPORT extern int TF_OperationGetControlOutputs(TF_Operation* oper, TF_Operation** control_outputs, int max_control_outputs);
    function res = getControlOutputs(obj)
      n = obj.numControlOutputs();
      if n > 0
        res = tensorflow.Operation.empty(n, 0);
        n_ = double(tensorflow_m_('TF_OperationGetControlOutputs', obj.ref, [res.ref], n));
        assert(n == n_, ['Number of fetched control outputs (' n_ ') does not match number of existing control outputs (' n ').']);
      else
        res = [];
      end
    end

    % TF_CAPI_EXPORT extern TF_AttrMetadata TF_OperationGetAttrMetadata(TF_Operation* oper, const char* attr_name, TF_Status* status);
    % NOT_SUPPORTED

    % TF_CAPI_EXPORT extern void TF_OperationGetAttrString(TF_Operation* oper, const char* attr_name, void* value, size_t max_length, TF_Status* status);
    function str = getAttrString(obj, attr)
      obj.assert_attr(attr);
      str = tensorflow_m_('TF_OperationGetAttrString', obj.ref, attr(:)', obj.status.ref);
      obj.status.maybe_raise();
    end

    % TF_CAPI_EXPORT extern void TF_OperationGetAttrStringList(TF_Operation* oper, const char* attr_name, void** values, size_t* lengths, int max_values, void* storage, size_t storage_size, TF_Status* status);
    function str = getAttrStringList(obj, attr)
      obj.assert_attr(attr);
      str = tensorflow_m_('TF_OperationGetAttrStringList', obj.ref, attr(:)', obj.status.ref);
      obj.status.maybe_raise();
    end

    % TF_CAPI_EXPORT extern void TF_OperationGetAttrInt(TF_Operation* oper, const char* attr_name, int64_t* value, TF_Status* status);
    function value = getAttrInt(obj, attr)
      obj.assert_attr(attr);
      value = tensorflow_m_('TF_OperationGetAttrInt', obj.ref, attr(:)', obj.status.ref);
      obj.status.maybe_raise();
    end

    % TF_CAPI_EXPORT extern void TF_OperationGetAttrIntList(TF_Operation* oper, const char* attr_name, int64_t* values, int max_values, TF_Status* status);
    function values = getAttrIntList(obj, attr)
      obj.assert_attr(attr);
      values = tensorflow_m_('TF_OperationGetAttrIntList', obj.ref, attr(:)', obj.status.ref);
      obj.status.maybe_raise();
    end

    % TF_CAPI_EXPORT extern void TF_OperationGetAttrFloat(TF_Operation* oper, const char* attr_name, float* value, TF_Status* status);
    function value = getAttrFloat(obj, attr)
      obj.assert_attr(attr);
      value = tensorflow_m_('TF_OperationGetAttrFloat', obj.ref, attr(:)', obj.status.ref);
      obj.status.maybe_raise();
    end

    % TF_CAPI_EXPORT extern void TF_OperationGetAttrFloatList(TF_Operation* oper, const char* attr_name, float* values, int max_values, TF_Status* status);
    function values = getAttrFloatList(obj, attr)
      obj.assert_attr(attr);
      values = tensorflow_m_('TF_OperationGetAttrFloatList', obj.ref, attr(:)', obj.status.ref);
      obj.status.maybe_raise();
    end

    % TF_CAPI_EXPORT extern void TF_OperationGetAttrBool(TF_Operation* oper, const char* attr_name, unsigned char* value, TF_Status* status);
    function value = getAttrBool(obj, attr)
      obj.assert_attr(attr);
      value = tensorflow_m_('TF_OperationGetAttrBool', obj.ref, attr(:)', obj.status.ref);
      obj.status.maybe_raise();
    end

    % TF_CAPI_EXPORT extern void TF_OperationGetAttrBoolList(TF_Operation* oper, const char* attr_name, unsigned char* values, int max_values, TF_Status* status);
    function values = getAttrBoolList(obj, attr)
      obj.assert_attr(attr);
      values = tensorflow_m_('TF_OperationGetAttrBoolList', obj.ref, attr(:)', obj.status.ref);
      obj.status.maybe_raise();
    end

    % TF_CAPI_EXPORT extern void TF_OperationGetAttrType(TF_Operation* oper, const char* attr_name, TF_DataType* value, TF_Status* status);
    function dtype = getAttrType(obj, attr)
      obj.assert_attr(attr);
      value = tensorflow_m_('TF_OperationGetAttrType', obj.ref, attr(:)', obj.status.ref);
      obj.status.maybe_raise();
      dtype = tensorflow.DataType(value);
    end

    % TF_CAPI_EXPORT extern void TF_OperationGetAttrTypeList(TF_Operation* oper, const char* attr_name, TF_DataType* values, int max_values, TF_Status* status);
    function dtypes = getAttrTypeList(obj, attr)
      obj.assert_attr(attr);
      values = tensorflow_m_('TF_OperationGetAttrTypeList', obj.ref, attr(:)', obj.status.ref);
      obj.status.maybe_raise();
      dtypes = tensorflow.DataType.empty(numel(values),0);
      for i=1:numel(values)
        dtypes(i) = tensorflow.DataType(values(i));
      end
    end

    % TF_CAPI_EXPORT extern void TF_OperationGetAttrShape(TF_Operation* oper, const char* attr_name, int64_t* value, int num_dims, TF_Status* status);
    function shape = getAttrShape(obj, attr)
      obj.assert_attr(attr);
      shape = double(tensorflow_m_('TF_OperationGetAttrShape', obj.ref, attr(:)', obj.status.ref));
      obj.status.maybe_raise();
    end

    % TF_CAPI_EXPORT extern void TF_OperationGetAttrShapeList(TF_Operation* oper, const char* attr_name, int64_t** dims, int* num_dims, int num_shapes, int64_t* storage, int storage_size, TF_Status* status);
    function shapes = getAttrShapeList(obj, attr)
      obj.assert_attr(attr);
      shapes = double(tensorflow_m_('TF_OperationGetAttrShapeList', obj.ref, attr(:)', obj.status.ref));
      obj.status.maybe_raise();
    end

    % TF_CAPI_EXPORT extern void TF_OperationGetAttrTensorShapeProto(TF_Operation* oper, const char* attr_name, TF_Buffer* value, TF_Status* status);
    % NOT_SUPPORTED

    % TF_CAPI_EXPORT extern void TF_OperationGetAttrTensorShapeProtoList(TF_Operation* oper, const char* attr_name, TF_Buffer** values, int max_values, TF_Status* status);
    % NOT_SUPPORTED

    % TF_CAPI_EXPORT extern void TF_OperationGetAttrTensor(TF_Operation* oper, const char* attr_name, TF_Tensor** value, TF_Status* status);
    function tensor = getAttrTensor(obj, attr)
      obj.assert_attr(attr);
      ref = tensorflow_m_('TF_OperationGetAttrTensor', obj.ref, attr(:)', obj.status.ref);
      obj.status.maybe_raise();
      tensor = tensorflow.Tensor(ref, true);
    end

    % TF_CAPI_EXPORT extern void TF_OperationGetAttrTensorList(TF_Operation* oper, const char* attr_name, TF_Tensor** values, int max_values, TF_Status* status);
    function tensors = getAttrTensorList(obj, attr)
      obj.assert_attr(attr);
      refs = tensorflow_m_('TF_OperationGetAttrTensorList', obj.ref, attr(:)', obj.status.ref);
      obj.status.maybe_raise();
      tensors = tensorflow.Tensor.empty(numel(refs), 0);
      for i = 1:1:numel(refs)
        tensors(i) = tensorflow.Tensor(refs(i), true);
      end
    end

    % TF_CAPI_EXPORT extern void TF_OperationGetAttrValueProto(TF_Operation* oper, const char* attr_name, TF_Buffer* output_attr_value, TF_Status* status);
    % NOT_SUPPORTED

    % TF_CAPI_EXPORT extern void TF_OperationToNodeDef(TF_Operation* oper, TF_Buffer* output_node_def, TF_Status* status);
    % TODO

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function delete(obj)
      if obj.isdeletable()
        tensorflow_m_('TFM_DeleteOperation', obj.ref);
      end
      delete@util.mixin.Pointer(obj);
    end

  end

  methods (Access=private)
    function assert_attr(obj, attr)
      % Validate if given argument is a valid attribute
      assert(ischar(attr) && isvector(attr), 'Provided attribute must be a one-dimensional char array.');
      % TODO cross-check with defined attributes of this operation
    end
  end
end
