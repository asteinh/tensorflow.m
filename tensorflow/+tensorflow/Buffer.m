classdef Buffer < util.mixin.Pointer
  %BUFFER Summary of this class goes here
  %   Detailed explanation goes here

  properties (Constant, SetAccess=private)
    % maximum size of Buffer (in bytes) to be handled by Matlab; if exceeded,
    % file I/O will be handled by MEX interface
    MAXSIZE = 1e6;
  end

  properties (SetAccess=private)
    length = [];
  end

  methods
    % TF_CAPI_EXPORT extern TF_Buffer* TF_NewBuffer(void);
    function obj = Buffer()
      % superclass constructor
      obj = obj@util.mixin.Pointer(tensorflow_m_('TF_NewBuffer'));
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
      info = dir(fpath);
      if info.bytes > obj.MAXSIZE
        % handle by MEX interface if exceeding size limit
        obj.debugMsg('tensorflow.Buffer.read_file: %.0d bytes, handled by MEX\n', info.bytes);
        obj.length = tensorflow_m_('TFM_FileToBuffer', obj.ref, fpath);
      else
        obj.debugMsg('tensorflow.Buffer.read_file: %.0d bytes, handled by Matlab\n', info.bytes);
        f = fopen(fpath);
        bytes = fread(f, Inf, 'uint8');
        obj.data(bytes);
      end
    end

    function res = write_file(obj, fpath)
      if obj.length > obj.MAXSIZE
        % handle by MEX interface if exceeding size limit
        obj.debugMsg('tensorflow.Buffer.write_file: %.0d bytes, handled by MEX\n', obj.length);
        tensorflow_m_('TFM_BufferToFile', obj.ref, fpath);
      else
        obj.debugMsg('tensorflow.Buffer.write_file: %.0d bytes, handled by Matlab\n', obj.length);
        bytes = obj.data();
        f = fopen(fpath, 'wb');
        fwrite(f, bytes, 'uint8');
        fclose(f);
      end
    end

    function s = size(obj)
      % overloading size()
      s = obj.length;
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
        obj.length = numel(data);
        tensorflow_m_('TFM_SetBufferData', obj.ref, data);
      end
    end

    function delete(obj)
      if ~obj.isempty()
        tensorflow_m_('TF_DeleteBuffer', obj.ref);
      end
      delete@util.mixin.Pointer(obj);
    end
  end
end
