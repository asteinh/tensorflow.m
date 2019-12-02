classdef Input < util.mixin.Pointer
  %INPUT Summary of this class goes here
  %   Detailed explanation goes here

  methods
    function obj = Input(oper, index)
      assert(nargin >= 1 && nargin <= 2);
      assert(isa(oper, 'uint64'), 'First argument does not seem to be a valid reference.');

      if nargin == 1; index = 0; end
      obj.set_reference_(tensorflow_m_('TF_NewInput', oper, index), true);
    end

    % TF_CAPI_EXPORT extern TF_DataType TF_OperationInputType(TF_Input oper_in);
    function type = operationInputType(obj)
      error('tensorflow:Input:operationInputType:NotImplemented', 'Not implemented.'); % TODO
      type = tensorflow.DataType(tensorflow_m_('TF_OperationInputType', obj.ref));
    end

    % TF_CAPI_EXPORT extern TF_Output TF_OperationInput(TF_Input oper_in);
    function output = operationInput(obj)
      error('tensorflow:Input:operationInput:NotImplemented', 'Not implemented.'); % TODO
      output = tensorflow.Output();
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function delete(obj)
      if obj.isdeletable()
        tensorflow_m_('TFM_DeleteInput', obj.ref);
      end
      delete@util.mixin.Pointer(obj);
    end
  end
end
