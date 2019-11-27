classdef Pointer < util.mixin.Base
  %POINTER Summary of this class goes here
  %   Detailed explanation goes here

  properties (SetAccess=private, GetAccess=public)
    ref = uint64([]);
  end

  properties (Access=private)
    is_owned = true;
  end

  methods
    function obj = Pointer(ref, owned)
      assert(~isempty(ref) && isa(ref, 'uint64') && ref ~= 0, 'You must supply a non-empty, non-zero reference of type ''uint64''.');
      obj.ref = ref;

      if nargin == 2 && owned == false
        obj.is_owned = false;
      end
    end

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

    % check if the referenced memory is owned by tensorflow.m
    function res = isowned(obj)
      res = obj.is_owned();
    end

    % check if Pointer object holds a valid reference and is owned
    function res = isdeletable(obj)
      res = ~obj.isempty() && obj.is_owned();
    end

    function delete(obj)
      obj.ref = [];
      delete@util.mixin.Base(obj);
    end
  end
end
