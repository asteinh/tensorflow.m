classdef ImportGraphDefOptions < util.mixin.Pointer
  %IMPORTGRAPHDEFOPTIONS Summary of this class goes here
  %   Detailed explanation goes here

  methods
    % TF_CAPI_EXPORT extern TF_ImportGraphDefOptions* TF_NewImportGraphDefOptions(void);
    function obj = ImportGraphDefOptions()
      obj.set_reference_(tensorflow_m_('TF_NewImportGraphDefOptions'), true);
    end

    % TF_CAPI_EXPORT extern void TF_DeleteImportGraphDefOptions(TF_ImportGraphDefOptions* opts);
    function deleteImportGraphDefOptions(obj)
      obj.delete();
    end

    % TF_CAPI_EXPORT extern void TF_ImportGraphDefOptionsSetPrefix(TF_ImportGraphDefOptions* opts, const char* prefix);
    % TODO

    % TF_CAPI_EXPORT extern void TF_ImportGraphDefOptionsSetDefaultDevice(TF_ImportGraphDefOptions* opts, const char* device);
    % TODO

    % TF_CAPI_EXPORT extern void TF_ImportGraphDefOptionsSetUniquifyNames(TF_ImportGraphDefOptions* opts, unsigned char uniquify_names);
    % TODO

    % TF_CAPI_EXPORT extern void TF_ImportGraphDefOptionsSetUniquifyPrefix( TF_ImportGraphDefOptions* opts, unsigned char uniquify_prefix);
    % TODO

    % TF_CAPI_EXPORT extern void TF_ImportGraphDefOptionsAddInputMapping(TF_ImportGraphDefOptions* opts, const char* src_name, int src_index, TF_Output dst);
    % TODO

    % TF_CAPI_EXPORT extern void TF_ImportGraphDefOptionsRemapControlDependency(TF_ImportGraphDefOptions* opts, const char* src_name, TF_Operation* dst);
    % TODO

    % TF_CAPI_EXPORT extern void TF_ImportGraphDefOptionsAddControlDependency(TF_ImportGraphDefOptions* opts, TF_Operation* oper);
    % TODO

    % TF_CAPI_EXPORT extern void TF_ImportGraphDefOptionsAddReturnOutput(TF_ImportGraphDefOptions* opts, const char* oper_name, int index);
    % TODO

    % TF_CAPI_EXPORT extern int TF_ImportGraphDefOptionsNumReturnOutputs(const TF_ImportGraphDefOptions* opts);
    function nout = numReturnOutputs(obj)
      nout = double(tensorflow_m_('TF_ImportGraphDefOptionsNumReturnOutputs', obj.ref));
    end

    % TF_CAPI_EXPORT extern void TF_ImportGraphDefOptionsAddReturnOperation(TF_ImportGraphDefOptions* opts, const char* oper_name);
    % TODO

    % TF_CAPI_EXPORT extern int TF_ImportGraphDefOptionsNumReturnOperations(const TF_ImportGraphDefOptions* opts);
    function nops = numReturnOperations(obj)
      nops = double(tensorflow_m_('TF_ImportGraphDefOptionsNumReturnOperations', obj.ref));
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function delete(obj)
      if obj.isdeletable()
        tensorflow_m_('TF_DeleteImportGraphDefOptions', obj.ref);
      end
      delete@util.mixin.Pointer(obj);
    end

  end
end
