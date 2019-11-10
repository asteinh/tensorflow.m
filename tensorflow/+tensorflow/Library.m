classdef Library < util.mixin.Pointer
  %LIBRARY Summary of this class goes here
  %   Detailed explanation goes here

  methods
    function obj = Library(ref_)
      assert(isa(ref_, 'uint64'));
      obj = obj@util.mixin.Pointer(ref_);
    end

    % TF_CAPI_EXPORT extern TF_Library* TF_LoadLibrary(const char* library_filename, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern TF_Buffer TF_GetOpList(TF_Library* lib_handle);
    % TODO

    % TF_CAPI_EXPORT extern void TF_DeleteLibraryHandle(TF_Library* lib_handle);
    function deleteLibraryHandle(obj)
      obj.delete();
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function delete(obj)
      if ~obj.isempty()
        mex_call('TF_DeleteLibraryHandle', obj.ref);
      end
      delete@util.mixin.Pointer(obj);
    end

  end
end
