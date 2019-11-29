classdef MultiConstructor
% MULTICONSTRUCTOR Adds capability to vectorize constructors.
%   Vectorization is based on the first input argument. The remaining arguments
%   are copied to the element-wise constructor.

  methods
    function obj = MultiConstructor(varargin)
      if nargin ~= 0
        inp = varargin{1};
        if nargin > 1
          add_arg = varargin(2:end);
        else
          add_arg = {};
        end

        if ischar(inp)
          % catch character arrays
          obj = element_constructor(obj, varargin{:});
        else
          % create matrix of elements
          m = size(inp, 1);
          n = size(inp, 2);
          obj(m,n) = obj; % automatic allocation
          for i = 1:1:m
            for j = 1:1:n
              obj(i,j) = element_constructor(obj(i,j), inp(i,j), add_arg{:});
            end
          end
        end
      end
    end
  end

  methods (Abstract, Access=protected)
    obj = element_constructor(obj, el, varargin)
  end
end
