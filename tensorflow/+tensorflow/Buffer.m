classdef Buffer < util.mixin.Pointer
  %BUFFER Summary of this class goes here
  %   Detailed explanation goes here

  methods
    function obj = Buffer()
      % superclass constructor
      obj = obj@util.mixin.Pointer(mex_call('TF_NewBuffer'));
    end

    function obj = read_file(obj, fpath)
      mex_call('TFM_FileToBuffer', obj.ref, fpath);
    end

    function varargout = data(obj, varargin)
      if nargin == 1
        % read data
        data = mex_call('TFM_GetBufferData', obj.ref);
        varargout{1} = data;
      elseif nargin == 2 && nargout == 0
        % write data
        varargout = {};
        data = varargin{1}(:)';
        mex_call('TFM_SetBufferData', obj.ref, uint8(data));
      else
        error('Unknown combination of input and output arguments.');
      end
    end

    function delete(obj)
      if ~obj.isempty()
        mex_call('TF_DeleteBuffer', obj.ref);
      end
      delete@util.mixin.Pointer(obj);
    end
  end
end
