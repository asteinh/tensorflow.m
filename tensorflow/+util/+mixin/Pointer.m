classdef Pointer < util.mixin.Base
  %POINTER Summary of this class goes here
  %   Detailed explanation goes here

  properties (SetAccess=private, GetAccess=public)
    ref = uint64([]);
  end

  properties (GetAccess=public, SetAccess=private)
    isowned = true;
  end

  methods (Access=public)
    % check if the Pointer object holds a valid reference
    function res = isempty(obj)
      if numel(obj) == 1
        res = isempty(obj.ref);
      else
        res = false(1,numel(obj));
        for i = 1:1:numel(obj)
          res(i) = obj(i).isempty();
        end
      end
    end

    % check if Pointer object holds a valid reference and is owned
    function res = isdeletable(obj)
      res = ~obj.isempty() && obj.isowned;
    end

    function delete(obj)
      obj.ref = [];
      delete@util.mixin.Base(obj);
    end
  end

  methods (Access=protected)
    function set_reference_(obj, ref, owned)
      assert(numel(ref) == 1 && isa(ref, 'uint64') && ref ~= 0, 'You must supply a non-empty, non-zero reference of type ''uint64''.');
      assert(numel(owned) == 1 && islogical(owned), 'You must supply a non-empty, logical value for the ownership of the referenced memory.');
      obj.ref = ref;
      obj.isowned = owned;
    end
  end
end
