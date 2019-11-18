classdef Server < util.mixin.Pointer
  %SERVER Summary of this class goes here
  %   Detailed explanation goes here

  properties (SetAccess=protected)
    status = [];
  end

  methods
    % TF_CAPI_EXPORT extern TF_Server* TF_NewServer(const void* proto, size_t proto_len, TF_Status* status);
    function obj = Server(proto)
      % using a TF_Buffer to handle proto and its length
      assert(isa(proto, 'tensorflow.Buffer'));
      status = tensorflow.Status();

      % superclass constructor
      obj = obj@util.mixin.Pointer(tensorflow_m_('TF_NewServer', proto.ref, status.ref));
      obj.status = status;
    end

    % TODO

    % TF_CAPI_EXPORT extern void TF_ServerStart(TF_Server* server, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern void TF_ServerStop(TF_Server* server, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern void TF_ServerJoin(TF_Server* server, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern const char* TF_ServerTarget(TF_Server* server);
    % TODO

    % TF_CAPI_EXPORT extern void TF_DeleteServer(TF_Server* server);
    function deleteServer(obj)
      obj.delete();
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function delete(obj)
      if obj.isdeletable()
        tensorflow_m_('TF_DeleteServer', obj.ref);
      end
      delete@util.mixin.Pointer(obj);
    end
  end
end
