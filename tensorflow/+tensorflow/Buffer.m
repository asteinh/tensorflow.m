classdef Buffer < util.mixin.Pointer
  %BUFFER Summary of this class goes here
  %   Detailed explanation goes here

  methods
    % TF_CAPI_EXPORT extern TF_Buffer* TF_NewBuffer(void);
    function obj = Buffer()
      % superclass constructor
      obj = obj@util.mixin.Pointer(mex_call('TF_NewBuffer'));
    end

    % TF_CAPI_EXPORT extern TF_Buffer* TF_NewBufferFromString(const void* proto, size_t proto_len);
    % TODO

    % TF_CAPI_EXPORT extern TF_Buffer TF_GetBuffer(TF_Buffer* buffer);
    % TODO

    % TF_CAPI_EXPORT extern void TF_DeleteBuffer(TF_Buffer*);
    function deleteBuffer(obj)
      obj.delete();
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function obj = read_file(obj, fpath)
      mex_call('TFM_FileToBuffer', obj.ref, fpath);
    end

    function varargout = data(obj, varargin)
      assert(nargin >= 1 && nargin <= 2, 'Wrong number of input arguments.');
      if nargin == 1
        % read data
        data = mex_call('TFM_GetBufferData', obj.ref);
        varargout{1} = data;
      elseif nargin == 2
        % write data
        varargout = {};
        data = varargin{1}(:)';
        mex_call('TFM_SetBufferData', obj.ref, uint8(data));
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
