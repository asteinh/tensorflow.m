classdef ApiDefMap < util.mixin.Pointer
  %APIDEFMAP Summary of this class goes here
  %   Detailed explanation goes here

  properties (SetAccess=protected)
    status = [];
  end

  methods
    % TF_CAPI_EXPORT extern TF_ApiDefMap* TF_NewApiDefMap(TF_Buffer* op_list_buffer, TF_Status* status);
    function obj = ApiDefMap(op_list_buffer)
      assert(isa(op_list_buffer, 'tensorflow.Buffer'));
      status = tensorflow.Status();

      % superclass constructor
      ref = tensorflow_m_('TF_NewApiDefMap', op_list_buffer.ref, status.ref);
      status.maybe_raise();
      obj = obj@util.mixin.Pointer(ref);
      obj.status = status;
    end

    % TF_CAPI_EXPORT extern void TF_DeleteApiDefMap(TF_ApiDefMap* apimap);
    function deleteApiDefMap(obj)
      obj.delete();
    end

    % TF_CAPI_EXPORT extern void TF_ApiDefMapPut(TF_ApiDefMap* api_def_map, const char* text, size_t text_len, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern TF_Buffer* TF_ApiDefMapGet(TF_ApiDefMap* api_def_map, const char* name, size_t name_len, TF_Status* status);
    % TODO

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function delete(obj)
      if obj.isdeletable()
        tensorflow_m_('TF_DeleteApiDefMap', obj.ref);
      end
      delete@util.mixin.Pointer(obj);
    end
  end
end
