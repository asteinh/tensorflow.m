classdef Enumeration < handle
  % Note: We drag along a public value (string representation) to be shown when
  % calling 'disp' on an instance
  properties (GetAccess=public, SetAccess=protected)
    value = NaN; % exposed value
  end

  properties (Access=protected)
    % internal value, constituted by identifying string and enumeration value
    value_ = { '', NaN };
  end

  methods
    % overloads for casting
    function val = uint32(obj)
      val = uint32(zeros(size(obj)));
      for i = 1:1:numel(obj)
        val(i) = uint32(obj(i).value_{2});
      end
    end
    function val = int32(obj)
      val = int32(zeros(size(obj)));
      for i = 1:1:numel(obj)
        val(i) = int32(obj(i).value_{2});
      end
    end
    function val = char(obj)
      val = cell(size(obj));
      for i = 1:1:numel(obj)
        val{i} = obj(i).value_{1};
      end
    end

    % overloads for comparison
    function is = eq(A, B)
      [A, B] = util.mixin.Enumeration.sanitize_(A, B);
      is = (A.value_{2} == B.value_{2});
    end
    function is = ge(A, B)
      [A, B] = util.mixin.Enumeration.sanitize_(A, B);
      is = (A.value_{2} >= B.value_{2});
    end
    function is = gt(A, B)
      [A, B] = util.mixin.Enumeration.sanitize_(A, B);
      is = (A.value_{2} > B.value_{2});
    end
    function is = le(A, B)
      [A, B] = util.mixin.Enumeration.sanitize_(A, B);
      is = (A.value_{2} <= B.value_{2});
    end
    function is = lt(A, B)
      [A, B] = util.mixin.Enumeration.sanitize_(A, B);
      is = (A.value_{2} < B.value_{2});
    end
    function is = ne(A, B)
      [A, B] = util.mixin.Enumeration.sanitize_(A, B);
      is = (A.value_{2} ~= B.value_{2});
    end
  end

  methods (Access=protected)
    function set_value_(obj, val_cell)
      obj.value  = val_cell{1};
      obj.value_ = val_cell;
    end
  end

  methods (Static, Access=protected)
    function is = is_int_robust_(val)
      if ~isempty(val) && isnumeric(val)
        is = ( (val >= 0) && (norm(double(val-round(val))) < eps) );
      else
        is = false;
      end
    end

    function varargout = sanitize_(varargin)
      for i = 1:nargin
        if isa(varargin{i}, 'util.mixin.Enumeration')
          cl = class(varargin{i});
        end
      end
      assert(~isempty(cl), 'Sanitizing inputs failed - apparently none of the inputs is of class util.mixin.Enumeration.');
      varargout = varargin;
      for i = 1:nargin
        if ~isa(varargin{i}, cl)
          varargout{i} = feval(cl, varargin{i});
        end
      end
    end
  end
end
