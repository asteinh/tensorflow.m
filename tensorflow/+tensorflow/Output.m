classdef Output < util.mixin.Pointer
  %OUTPUT Summary of this class goes here
  %   Detailed explanation goes here

  methods
    function obj = Output(varargin)
      if nargin == 1 && isa(varargin{1}, 'uint64')
        ref = varargin{1}; % create pointer from given reference
        owned = false;
      else
        if nargin == 1
          oper = varargin{1};
          index = 0;
        elseif nargin == 2
          oper = varargin{1};
          index = varargin{2};
        else
          error(['Cannot create tensorflow.Output with given arguments.']);
        end
        assert(isa(oper, 'tensorflow.Operation'));
        assert(isnumeric(index));
        ref = tensorflow_m_('TFM_NewOutput', oper.ref, index);
        owned = true;
      end

      obj = obj@util.mixin.Pointer(ref, owned);
    end

    % TF_CAPI_EXPORT extern TF_DataType TF_OperationOutputType(TF_Output oper_out);
    function type = operationOutputType(obj)
      type = tensorflow.DataType(tensorflow_m_('TF_OperationOutputType', obj.ref));
    end

    % TF_CAPI_EXPORT extern int TF_OperationOutputNumConsumers(TF_Output oper_out);
    function num = operationOutputNumConsumers(obj)
      num = tensorflow_m_('TF_OperationOutputNumConsumers', obj.ref);
    end

    % TF_CAPI_EXPORT extern int TF_OperationOutputConsumers(TF_Output oper_out, TF_Input* consumers, int max_consumers);
    function consumers = operationOutputConsumers(obj)
      error('Not implemented.'); % TODO

      max_consumers = obj.TF_OperationOutputNumConsumers();
      consumers = [];
      for i = 1:1:max_consumers
        consumers = [consumers; tensorflow.Input()];
      end
      tensorflow_m_('TF_OperationOutputConsumers', obj.ref);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function delete(obj)
      if ~obj.isempty() && obj.isowned()
        tensorflow_m_('TFM_DeleteOutput', obj.ref);
      end
      delete@util.mixin.Pointer(obj);
    end
  end
end
