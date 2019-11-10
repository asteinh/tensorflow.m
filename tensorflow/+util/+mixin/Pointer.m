classdef Pointer < util.mixin.Unique
  %POINTER Summary of this class goes here
  %   Detailed explanation goes here

  properties (SetAccess=private, GetAccess=protected)
    ref = uint64([]);
    is_owned = true;
  end

  methods
    function obj = Pointer(ref_, owned)
      assert(~isempty(ref_) && isa(ref_, 'uint64') && ref_ ~= 0, 'You must supply a non-empty, non-zero reference of type ''uint64''.');
      obj.ref = ref_;

      if nargin == 2 && owned == false
        obj.release();
      end
    end

    % check if the Pointer object holds a valid reference
    function res = isempty(obj)
      res = isempty(obj.ref);
    end

    % check if the referenced memory is owned by tensorflow.m
    function res = isowned(obj)
      res = obj.is_owned();
    end

    function delete(obj)
      obj.ref = [];
    end
  end

  methods (Access=protected)
    % release ownership of the referenced memory - make sure that another owner
    % takes care of freeing up the memory once it's no longer needed!
    function release(obj)
      obj.is_owned = false;
    end

    % obtain ownership of the referenced memory - make sure that no other owner
    % frees this memory to avoid segfaulting.
    function obtain(obj)
      obj.is_owned = true;
    end
  end
end
