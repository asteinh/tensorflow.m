classdef Vectorize < handle
  %VECTORIZE Adds capability to vectorize constructors.
  %   Vectorization is based on the first input argument. The remaining arguments
  %   are copied to the element-wise constructor.

  methods (Access=protected)
    function obj = vectorize_constructor_(obj, varargin)
      if nargin == 1
        return;
      end

      vec_arg = varargin{1};
      add_arg = {};
      if nargin > 2
        add_arg = varargin(2:end);
      end
      if numel(vec_arg) <= 1 || ischar(vec_arg)
        % vectorizing argument is scalar or a string
        return;
      else
        % create matrix of elements
        m = size(vec_arg, 1);
        n = size(vec_arg, 2);
        obj(m,n) = obj(1,1).empty_copy_(); % automatic allocation of array of objects
        if iscell(vec_arg)
          for i = 1:1:m
            for j = 1:1:n
              obj(i,j) = feval(class(obj), vec_arg{i,j}, add_arg{:});
            end
          end
        else
          for i = 1:1:m
            for j = 1:1:n
              obj(i,j) = feval(class(obj), vec_arg(i,j), add_arg{:});
            end
          end
        end
      end
    end

    function cp = empty_copy_(obj)
      cp = feval(class(obj));
    end
  end
end
