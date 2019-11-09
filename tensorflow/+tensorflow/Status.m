classdef Status < util.mixin.Pointer
  %STATUS Summary of this class goes here
  %   Detailed explanation goes here

  methods
    % TF_CAPI_EXPORT extern TF_Status* TF_NewStatus(void);
    function obj = Status()
      obj = obj@util.mixin.Pointer(mex_call('TF_NewStatus'));
    end

    % TF_CAPI_EXPORT extern TF_Code TF_GetCode(const TF_Status* s);
    function code = GetCode(obj)
      code = tensorflow.Code(mex_call('TF_GetCode', obj.ref));
    end

    % TF_CAPI_EXPORT extern const char* TF_Message(const TF_Status* s);
    function msg = Message(obj)
      msg = mex_call('TF_Message', obj.ref);
    end

    % TF_CAPI_EXPORT extern void TF_DeleteStatus(TF_Status*);
    function deleteStatus(obj)
      obj.delete();
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function maybe_raise(obj)
      c = obj.GetCode();
      if c ~= tensorflow.Code('TF_OK')
        e = MException(['tensorflow:Status:' char(c)], obj.Message());
        throw(e);
      end
    end

    function delete(obj)
      if ~obj.isempty()
        mex_call('TF_DeleteStatus', obj.ref);
      end
      delete@util.mixin.Pointer(obj);
    end
  end
end
