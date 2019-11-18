classdef DeviceList < util.mixin.Pointer
  %DEVICELIST Summary of this class goes here
  %   Detailed explanation goes here

  methods
    function obj = DeviceList(ref)
      assert(isa(ref, 'uint64'));
      obj = obj@util.mixin.Pointer(ref);
    end

    % TF_CAPI_EXPORT extern void TF_DeleteDeviceList(TF_DeviceList* list);
    function deleteDeviceList(obj)
      obj.delete();
    end

    % TF_CAPI_EXPORT extern int TF_DeviceListCount(const TF_DeviceList* list);
    % TODO

    % TF_CAPI_EXPORT extern const char* TF_DeviceListName(const TF_DeviceList* list, int index, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern const char* TF_DeviceListType(const TF_DeviceList* list, int index, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern int64_t TF_DeviceListMemoryBytes(const TF_DeviceList* list, int index, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern uint64_t TF_DeviceListIncarnation(const TF_DeviceList* list, int index, TF_Status* status);
    % TODO

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function delete(obj)
      if obj.isdeletable()
        tensorflow_m_('TF_DeleteDeviceList', obj.ref);
      end
      delete@util.mixin.Pointer(obj);
    end

  end
end
