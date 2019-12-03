classdef Status < util.mixin.Pointer
  %STATUS Summary of this class goes here
  %   Detailed explanation goes here

  methods
    % TF_CAPI_EXPORT extern TF_Status* TF_NewStatus(void);
    function obj = Status()
      ref = tensorflow_m_('TF_NewStatus');
      obj.set_reference_(ref, true);
    end

    % TF_CAPI_EXPORT extern void TF_DeleteStatus(TF_Status*);
    function deleteStatus(obj)
      obj.delete();
    end

    % TF_CAPI_EXPORT extern void TF_SetStatus(TF_Status* s, TF_Code code, const char* msg);
    function setStatus(obj, code, msg)
      code_num = uint32(tensorflow.Code(code));
      assert(ischar(msg), 'Provided message must be a string.');
      tensorflow_m_('TF_SetStatus', obj.ref, code_num, msg);
    end

    % TF_CAPI_EXPORT extern TF_Code TF_GetCode(const TF_Status* s);
    function code = getCode(obj)
      code = tensorflow.Code(tensorflow_m_('TF_GetCode', obj.ref));
    end

    % TF_CAPI_EXPORT extern const char* TF_Message(const TF_Status* s);
    function msg = message(obj)
      msg = tensorflow_m_('TF_Message', obj.ref);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function maybe_raise(obj)
      c = obj.getCode();
      if c ~= tensorflow.Code('TF_OK')
        error(['tensorflow:Status:' char(c)], obj.message());
      end
    end

    function delete(obj)
      if obj.isdeletable()
        tensorflow_m_('TF_DeleteStatus', obj.ref);
      end
      delete@util.mixin.Pointer(obj);
    end
  end
end
