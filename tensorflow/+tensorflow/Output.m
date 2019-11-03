classdef Output < util.mixin.Pointer
  %OUTPUT Summary of this class goes here
  %   Detailed explanation goes here

  methods
    function obj = Output(oper, index)
      if nargin == 1
        index = 0;
      elseif nargin > 2
        error('Cannot create tensorflow.Output with given arguments.');
      end
      assert(isa(oper, 'tensorflow.Operation'));
      assert(isnumeric(index));

      obj = obj@util.mixin.Pointer(mex_call('TFM_NewOutput', oper.ref, index));
    end

    % TF_CAPI_EXPORT extern TF_DataType TF_OperationOutputType(TF_Output oper_out);
    function type = operationOutputType(obj)
      type = tensorflow.DataType(mex_call('TF_OperationOutputType', obj.ref));
    end

    % TF_CAPI_EXPORT extern int TF_OperationOutputNumConsumers(TF_Output oper_out);
    function num = operationOutputNumConsumers(obj)
      num = mex_call('TF_OperationOutputNumConsumers', obj.ref);
    end

    % TF_CAPI_EXPORT extern int TF_OperationOutputConsumers(TF_Output oper_out, TF_Input* consumers, int max_consumers);
    function consumers = operationOutputConsumers(obj)
      error('Not implemented.'); % TODO

      max_consumers = obj.TF_OperationOutputNumConsumers();
      consumers = [];
      for i = 1:1:max_consumers
        consumers = [consumers; tensorflow.Input()];
      end
      mex_call('TF_OperationOutputConsumers', obj.ref);
    end

    function delete(obj)
      if ~obj.isempty()
        mex_call('TFM_DeleteOutput', obj.ref);
      end
      delete@util.mixin.Pointer(obj);
    end
  end
end
