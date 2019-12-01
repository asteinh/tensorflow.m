classdef Vectorize < handle
  %VECTORIZE Adds capability to vectorize constructors.
  %   Vectorization is based on the first input argument. The remaining arguments
  %   are copied to the element-wise constructor.

  methods (Access=protected)
    function obj = vectorize_constructor_(obj, varargin)
      if nargin ~= 0
        inp = varargin{1};
        if nargin > 1
          add_arg = varargin(2:end);
        else
          add_arg = {};
        end
        if numel(inp) <= 1 || ischar(inp)
          % shortcut
          return;
        else
          % create matrix of elements
          m = size(inp, 1);
          n = size(inp, 2);
          obj(m,n) = obj(1,1).empty_copy(); % automatic allocation of array of objects
          for i = 1:1:m
            for j = 1:1:n
              obj(i,j) = feval(class(obj), inp(i,j), add_arg{:});
            end
          end
        end
      end
    end

    function cp = empty_copy_(obj)
      cp = feval(class(obj));
    end
  end

  % methods (Abstract, Access=protected)
  %   element_constructor(obj, varargin)
  % end
end
