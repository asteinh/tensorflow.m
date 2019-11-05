classdef ImportGraphDefOptions < util.mixin.Pointer
  %IMPORTGRAPHDEFOPTIONS Summary of this class goes here
  %   Detailed explanation goes here

  methods
    function obj = ImportGraphDefOptions()
      % create operation description
      obj = obj@util.mixin.Pointer(mex_call('TF_NewImportGraphDefOptions'));
    end

    function delete(obj)
      if ~obj.isempty()
        mex_call('TF_DeleteImportGraphDefOptions', obj.ref);
      end
      delete@util.mixin.Pointer(obj);
    end

  end
end
