classdef ImportGraphDefResults < util.mixin.Pointer
  %IMPORTGRAPHDEFRESULTS Summary of this class goes here
  %   Detailed explanation goes here

  methods
    function obj = ImportGraphDefResults(ref_)
      assert(isa(ref_, 'uint64'));
      obj = obj@util.mixin.Pointer(ref_);
    end

    % TF_CAPI_EXPORT extern void TF_ImportGraphDefResultsReturnOutputs(TF_ImportGraphDefResults* results, int* num_outputs, TF_Output** outputs);
    % TODO

    % TF_CAPI_EXPORT extern void TF_ImportGraphDefResultsReturnOperations(TF_ImportGraphDefResults* results, int* num_opers, TF_Operation*** opers);
    % TODO

    % TF_CAPI_EXPORT extern void TF_ImportGraphDefResultsMissingUnusedInputMappings(TF_ImportGraphDefResults* results, int* num_missing_unused_input_mappings, const char*** src_names, int** src_indexes);
    % TODO

    % TF_CAPI_EXPORT extern void TF_DeleteImportGraphDefResults(TF_ImportGraphDefResults* results);
    function deleteImportGraphDefResults(obj)
      obj.delete();
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function delete(obj)
      if ~obj.isempty()
        mex_call('TF_DeleteImportGraphDefResults', obj.ref);
      end
      delete@util.mixin.Pointer(obj);
    end

  end
end
