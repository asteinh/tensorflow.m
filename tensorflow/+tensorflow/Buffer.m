classdef Buffer < util.mixin.Pointer
  %BUFFER Summary of this class goes here
  %   Detailed explanation goes here

  properties (Constant, Access=private)
    % maximum size of Buffer (in bytes) to be handled by Matlab; if exceeded,
    % file I/O will be handled by MEX interface
    MAXSIZE = 1e5; % 100kB
  end

  properties (SetAccess=private)
    length_ = [];
    status = [];
  end

  methods
    % TF_CAPI_EXPORT extern TF_Buffer* TF_NewBuffer(void);
    % TF_CAPI_EXPORT extern TF_Buffer* TF_NewBufferFromString(const void* proto, size_t proto_len);
    function obj = Buffer(varargin)
      if nargin == 1 && isa(varargin{1}, 'uint64')
        ref = varargin{1}; % create pointer from given reference
        owned = false;
      else
        if nargin == 1 && ischar(varargin{1})
          data = uint8(varargin{1}(:)');
          owned = true;
        elseif nargin == 0
          data = [];
        else
          error('tensorflow:Buffer:InputArguments', 'Cannot create tensorflow.Buffer with given arguments.');
        end
        ref = tensorflow_m_('TF_NewBuffer');
        owned = true;
      end

      obj = obj@util.mixin.Pointer(ref, owned);
      obj.length_ = tensorflow_m_('TFM_BufferLength', obj.ref);
      obj.status = tensorflow.Status();

      if owned && ~isempty(data)
        obj.data(data); % set data, if given
      end
    end

    % TF_CAPI_EXPORT extern void TF_DeleteBuffer(TF_Buffer*);
    function deleteBuffer(obj)
      obj.delete();
    end

    % TF_CAPI_EXPORT extern TF_Buffer TF_GetBuffer(TF_Buffer* buffer);
    % not supported

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function obj = read_file(obj, fpath)
      info = dir(fpath);
      if info.bytes > obj.MAXSIZE
        % handle by MEX interface if exceeding size limit
        obj.debugMsg('tensorflow.Buffer.read_file: %.0d bytes, handled by MEX\n', info.bytes);
        tensorflow_m_('TFM_FileToBuffer', obj.ref, fpath, obj.status.ref);
        obj.status.maybe_raise();
        obj.length_ = tensorflow_m_('TFM_BufferLength', obj.ref);
      else
        obj.debugMsg('tensorflow.Buffer.read_file: %.0d bytes, handled by Matlab\n', info.bytes);
        f = fopen(fpath);
        bytes = fread(f, Inf, 'uint8');
        obj.data(bytes);
      end
    end

    function write_file(obj, fpath)
      if obj.length_ > obj.MAXSIZE
        % handle by MEX interface if exceeding size limit
        obj.debugMsg('tensorflow.Buffer.write_file: %.0d bytes, handled by MEX\n', obj.length_);
        tensorflow_m_('TFM_BufferToFile', obj.ref, fpath, obj.status.ref);
        obj.status.maybe_raise();
      else
        obj.debugMsg('tensorflow.Buffer.write_file: %.0d bytes, handled by Matlab\n', obj.length_);
        bytes = obj.data();
        f = fopen(fpath, 'wb');
        fwrite(f, bytes, 'uint8');
        fclose(f);
      end
    end

    function s = length(obj)
      s = double(obj.length_);
    end

    function varargout = data(obj, varargin)
      assert(nargin >= 1 && nargin <= 2, 'Wrong number of input arguments.');
      if nargin == 1
        % read data
        data = tensorflow_m_('TFM_GetBufferData', obj.ref);
        varargout{1} = data;
      elseif nargin == 2
        % write data
        varargout = {};
        data = uint8(varargin{1}(:)');
        obj.length_ = numel(data);
        tensorflow_m_('TFM_SetBufferData', obj.ref, data);
      end
    end

    function delete(obj)
      if obj.isdeletable()
        tensorflow_m_('TF_DeleteBuffer', obj.ref);
      end
      delete@util.mixin.Pointer(obj);
    end
  end
end
