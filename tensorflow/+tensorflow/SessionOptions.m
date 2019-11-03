classdef SessionOptions < util.mixin.Pointer
  %SESSIONOPTIONS Summary of this class goes here
  %   Detailed explanation goes here

  methods
    function obj = SessionOptions()
      obj = obj@util.mixin.Pointer(mex_call('TF_NewSessionOptions'));
    end

    % TF_CAPI_EXPORT extern void TF_SetTarget(TF_SessionOptions* options, const char* target);
    % TF_CAPI_EXPORT extern void TF_SetConfig(TF_SessionOptions* options, const void* proto, size_t proto_len, TF_Status* status);
    % TF_CAPI_EXPORT extern void TF_DeleteSessionOptions(TF_SessionOptions*);
    function DeleteSessionOptions(obj)
      obj.delete();
    end

    function delete(obj)
      if ~obj.isempty()
        mex_call('TF_DeleteSessionOptions', obj.ref);
      end
      delete@util.mixin.Pointer(obj);
    end
  end
end
