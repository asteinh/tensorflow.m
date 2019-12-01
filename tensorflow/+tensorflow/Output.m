classdef Output < util.mixin.Pointer & util.mixin.Vectorize
  %OUTPUT Summary of this class goes here
  %   Detailed explanation goes here

  methods
    function obj = Output(varargin)
      if nargin == 0
        % dummy, for copying
        return;
      elseif nargin == 2 && isa(varargin{1}, 'uint64') && islogical(varargin{2})
        % construction by reference
        ref = varargin{1};
        owned = varargin{2};
        assert(numel(owned) == 1, 'tensorflow:Output:InputArguments', '(Vectorized) Construction by reference has to have a single ownership flag.');
        if numel(ref) > 1
          obj = vectorize_constructor_(obj, varargin{:});
          return;
        else
          obj.set_reference_(ref, owned);
        end
      else
        if nargin == 1
          oper = varargin{1};
          index = 0;
        elseif nargin == 2
          oper = varargin{1};
          index = varargin{2};
        else
          error('tensorflow:Output:InputArguments', 'Cannot create tensorflow.Output with given arguments.');
        end
        assert(isa(oper, 'tensorflow.Operation'), 'tensorflow:Output:InputArguments', 'Construction by tensorflow.Operation requires the first input to be of class tensorflow.Operation.');
        assert(isnumeric(index), 'tensorflow:Output:InputArguments', 'Construction by tensorflow.Operation accepts an index as second argument, which must be numeric.');
        ref = tensorflow_m_('TFM_NewOutput', oper.ref, index);
        obj.set_reference_(ref, true);
      end
    end

    % TF_CAPI_EXPORT extern TF_DataType TF_OperationOutputType(TF_Output oper_out);
    function type = type(obj)
      type = tensorflow.DataType(tensorflow_m_('TF_OperationOutputType', obj.ref));
    end

    % TF_CAPI_EXPORT extern int TF_OperationOutputNumConsumers(TF_Output oper_out);
    function num = numConsumers(obj)
      num = tensorflow_m_('TF_OperationOutputNumConsumers', obj.ref);
    end

    % TF_CAPI_EXPORT extern int TF_OperationOutputConsumers(TF_Output oper_out, TF_Input* consumers, int max_consumers);
    function c = consumers(obj)
      error('tensorflow:Output:operationOutputConsumers:NotImplemented', 'Not implemented.'); % TODO

      max_consumers = obj.numConsumers();
      c = [];
      for i = 1:1:max_consumers
        c = [c; tensorflow.Input()];
      end
      tensorflow_m_('TF_OperationOutputConsumers', obj.ref);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function delete(obj)
      if obj.isdeletable()
        tensorflow_m_('TFM_DeleteOutput', obj.ref);
      end
      delete@util.mixin.Pointer(obj);
    end
  end
end
