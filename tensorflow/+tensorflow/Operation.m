classdef Operation < util.mixin.Pointer
  %OPERATION Summary of this class goes here
  %   Detailed explanation goes here

  methods
    function obj = Operation(ref_)
      assert(isa(ref_, 'uint64'));

      % create operation
      obj = obj@util.mixin.Pointer(ref_);
    end

    % TF_CAPI_EXPORT extern TF_DataType TF_OperationOutputType(TF_Output oper_out);
    function type = operationOutputType(obj)
      type = tensorflow.DataType(mex_call('TF_OperationOutputType', obj.ref));
    end

    function delete(obj)
      if ~obj.isempty()
        mex_call('TFM_DeleteOperation', obj.ref);
      end
      delete@util.mixin.Pointer(obj);
    end

  end
end
