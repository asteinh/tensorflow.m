classdef Pointer < util.mixin.Unique
  %POINTER Summary of this class goes here
  %   Detailed explanation goes here

  properties (SetAccess=private, GetAccess=protected)
    ref = uint64([]);
  end

  methods
    function obj = Pointer(ref_)
      assert(~isempty(ref_) && isa(ref_, 'uint64') && ref_ ~= 0, 'You must supply a non-empty, non-zero reference of type ''uint64''.');
      obj.ref = ref_;
    end

    % check if the Pointer object holds a valid reference
    function res = isempty(obj)
      res = isempty(obj.ref);
    end

    function delete(obj)
      obj.ref = [];
    end
  end
end
