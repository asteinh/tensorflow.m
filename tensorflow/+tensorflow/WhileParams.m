classdef WhileParams < util.mixin.Pointer
  %WHILEPARAMS Summary of this class goes here
  %   Detailed explanation goes here

  methods
    function obj = WhileParams(ref_)
      assert(isa(ref_, 'uint64'));
      obj = obj@util.mixin.Pointer(ref_);
    end

    % TF_CAPI_EXPORT extern void TF_FinishWhile(const TF_WhileParams* params, TF_Status* status, TF_Output* outputs);
    % TODO

    % TF_CAPI_EXPORT extern void TF_AbortWhile(const TF_WhileParams* params);
    function abortWhile(obj)
      mex_call('TF_AbortWhile', obj.ref);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function delete(obj)
      if ~obj.isempty()
        obj.abortWhile();
        mex_call('TFM_DeleteWhile', obj.ref);
      end
      delete@util.mixin.Pointer(obj);
    end
  end
end
