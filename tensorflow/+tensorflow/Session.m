classdef Session < util.mixin.Pointer
  %SESSION Summary of this class goes here
  %   Detailed explanation goes here

  properties (SetAccess=protected)
    % graph = [];
    opts = [];
    status = [];
  end

  methods
    function obj = Session(graph)
      assert(isa(graph, 'tensorflow.Graph'), 'Provided graph must be of class tensorflow.Graph.');

      % create SessionOptions and Status
      opts = tensorflow.SessionOptions();
      status = tensorflow.Status();

      % superclass constructor
      obj = obj@util.mixin.Pointer(tensorflow_m_('TF_NewSession', graph.ref, opts.ref, status.ref));

      obj.opts = opts;
      obj.status = status;
      % obj.graph = graph;
    end

    % TF_CAPI_EXPORT extern void TF_CloseSession(TF_Session*, TF_Status* status);
    % TODO

    % TF_CAPI_EXPORT extern void TF_DeleteSession(TF_Session*, TF_Status* status);
    function deleteSession(obj)
      obj.delete();
    end

    % TF_CAPI_EXPORT extern void TF_SessionRun(TF_Session* session, const TF_Buffer* run_options, const TF_Output* inputs, TF_Tensor* const* input_values, int ninputs, const TF_Output* outputs, TF_Tensor** output_values, int noutputs, const TF_Operation* const* target_opers, int ntargets, TF_Buffer* run_metadata, TF_Status*);
    function res = run(obj, inputs, input_values, outputs, target_opers, run_options, run_metadata)
      if nargin < 4 || nargin > 8
        error('tensorflow:Session:run:InputArguments', 'Wrong number of input arguments provided.');
      end
      if numel(inputs) > 0
        assert(isa(inputs, 'tensorflow.Output'), 'Provided inputs must be of class tensorflow.Output.');
        assert(isa(input_values, 'tensorflow.Tensor'), 'Provided input values must be of class tensorflow.Tensor.');
      end
      assert(numel(outputs) > 0 && isa(outputs, 'tensorflow.Output'), 'Provided outputs must be non-empty and of class tensorflow.Output.');

      % TODO additional arguments are not supported yet; consider this pseudo code
      target_opers = [];
      if nargin > 4
        assert(isa(target_opers, 'tensorflow.Operation'), 'Provided target operations must be of class tensorflow.Operation.');
      end
      run_options = [];
      if nargin > 5
        assert(isa(run_options, 'tensorflow.Buffer'), 'Provided run options must be of class tensorflow.Buffer.');
      end
      run_metadata = [];
      if nargin > 6
        assert(isa(run_metadata, 'tensorflow.Buffer'), 'Provided run metadata must be of class tensorflow.Buffer.');
      end

      ninputs = numel(inputs);
      inputs_ref = [];
      input_values_ref = [];
      if ninputs > 0
        assert(ninputs == numel(input_values), 'Number of provided inputs and input values must be equal.');
        inputs_ref = [inputs.ref];
        input_values_ref = [input_values.ref];
      end

      noutputs = numel(outputs);
      outputs_ref = [];
      if noutputs > 0
        outputs_ref = [outputs.ref];
      end

      ntargets = numel(target_opers);
      target_opers_ref = [];
      if ntargets > 0
        target_opers_ref = [target_opers.ref];
      end

      refs = tensorflow_m_('TF_SessionRun', obj.ref, run_options, ...
                      inputs_ref, input_values_ref, int32(ninputs), ...
                      outputs_ref, int32(noutputs), ...
                      target_opers_ref, ntargets, run_metadata, obj.status.ref);

      obj.status.maybe_raise();

      res = tensorflow.Tensor.empty(noutputs,0);
      for i = 1:1:noutputs
        res(i) = tensorflow.Tensor(refs(i));
      end

    end

    % TF_CAPI_EXPORT extern void TF_SessionPRunSetup(TF_Session*, const TF_Output* inputs, int ninputs, const TF_Output* outputs, int noutputs, const TF_Operation* const* target_opers, int ntargets, const char** handle, TF_Status*);
    % TODO

    % TF_CAPI_EXPORT extern void TF_SessionPRun(TF_Session*, const char* handle, const TF_Output* inputs, TF_Tensor* const* input_values, int ninputs, const TF_Output* outputs, TF_Tensor** output_values, int noutputs, const TF_Operation* const* target_opers, int ntargets, TF_Status*);
    % TODO

    % TF_CAPI_EXPORT extern TF_DeviceList* TF_SessionListDevices(TF_Session* session, TF_Status* status);
    % TODO

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function delete(obj)
      if obj.isdeletable()
        tensorflow_m_('TF_DeleteSession', obj.ref, obj.status.ref);
        obj.status.maybe_raise();
      end
      delete@util.mixin.Pointer(obj);
    end
  end
end
