classdef Function < util.mixin.Pointer
  %FUNCTION Summary of this class goes here
  %   Detailed explanation goes here

  methods
    function obj = Function(ref)
      assert(isa(ref, 'uint64'));
      obj.set_reference_(ref, true);
    end

    % TF_CAPI_EXPORT extern const char* TF_FunctionName(TF_Function* func);
    % TODO

    % TF_CAPI_EXPORT extern void TF_FunctionToFunctionDef(TF_Function* func, TF_Buffer* output_func_def, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern TF_Function* TF_FunctionImportFunctionDef(const void* proto, size_t proto_len, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern void TF_FunctionSetAttrValueProto(TF_Function* func, const char* attr_name, const void* proto, size_t proto_len, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern void TF_FunctionGetAttrValueProto(TF_Function* func, const char* attr_name, TF_Buffer* output_attr_value, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern void TF_DeleteFunction(TF_Function* func);
    function deleteFunction(obj)
      obj.delete();
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function delete(obj)
      if obj.isdeletable()
        tensorflow_m_('TF_DeleteFunction', obj.ref);
      end
      delete@util.mixin.Pointer(obj);
    end

  end
end
