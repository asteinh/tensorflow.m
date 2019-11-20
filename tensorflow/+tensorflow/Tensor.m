classdef Tensor < util.mixin.Pointer
  %TENSOR Summary of this class goes here
  %   Detailed explanation goes here

  methods
    % TF_CAPI_EXPORT extern TF_Tensor* TF_NewTensor(TF_DataType, const int64_t* dims, int num_dims, void* data, size_t len, void (*deallocator)(void* data, size_t len, void* arg), void* deallocator_arg);
    % TF_CAPI_EXPORT extern TF_Tensor* TF_AllocateTensor(TF_DataType, const int64_t* dims, int num_dims, size_t len);
    function obj = Tensor(varargin)
      if (nargin == 1 || nargin == 2) && isa(varargin{1}, 'uint64')
        ref = varargin{1}; % create pointer from given reference
        if nargin == 1
          owned = false;
        elseif nargin == 2 && islogical(varargin{2})
          owned = varargin{2};
        else
          error('tensorflow:Tensor:InputArguments', 'Cannot create tensorflow.Tensor with given arguments.');
        end
      else
        if nargin == 1
          data = varargin{1}; % create Tensor from data
          dtype = tensorflow.DataType.m2tf(class(data)); % retrieve datatype from data
          dims = size(data); % data dimensions
        elseif nargin == 2
          dtype = varargin{1}; % create Tensor from dtype and dims
          dims = varargin{2};  % ...
          data = [];
        else
          error('tensorflow:Tensor:InputArguments', 'Cannot create tensorflow.Tensor with given arguments.');
        end
        assert(ismember(dtype, enumeration('tensorflow.DataType')));
        dtype = tensorflow.DataType(dtype);
        assert(isvector(dims));
        ref = tensorflow_m_('TF_AllocateTensor', int32(dtype), int64(dims), int32(numel(dims)));
        owned = true;
      end

      obj = obj@util.mixin.Pointer(ref, owned);

      if owned && ~isempty(data)
        obj.value(data); % set data, if given
      end
    end

    % TF_CAPI_EXPORT extern TF_Tensor* TF_TensorMaybeMove(TF_Tensor* tensor);
    % not supported

    % TF_CAPI_EXPORT extern void TF_DeleteTensor(TF_Tensor*);
    function deleteTensor(obj)
      obj.delete();
    end

    % TF_CAPI_EXPORT extern TF_DataType TF_TensorType(const TF_Tensor*);
    function t = type(obj)
      t = tensorflow.DataType(tensorflow_m_('TF_TensorType', obj.ref));
    end

    % TF_CAPI_EXPORT extern int TF_NumDims(const TF_Tensor*);
    function n = numDims(obj)
      n = tensorflow_m_('TF_NumDims', obj.ref);
    end

    % TF_CAPI_EXPORT extern int64_t TF_Dim(const TF_Tensor* tensor, int dim_index);
    function d = dim(obj, idx)
      d = tensorflow_m_('TF_Dim', obj.ref, int32(idx));
    end

    % TF_CAPI_EXPORT extern size_t TF_TensorByteSize(const TF_Tensor*);
    function bytes = byteSize(obj)
      bytes = double(tensorflow_m_('TF_TensorByteSize', obj.ref));
    end

    % TF_CAPI_EXPORT extern void* TF_TensorData(const TF_Tensor*);
    function buf = data(obj)
      % return Tensor data in a TF_Buffer wrapper
      buf_ref = tensorflow_m_('TF_TensorData', obj.ref);
      buf = tensorflow.Buffer(buf_ref);
    end

    % TF_CAPI_EXPORT extern int64_t TF_TensorElementCount(const TF_Tensor* tensor);
    function elms = elementCount(obj)
      elms = double(tensorflow_m_('TF_TensorElementCount', obj.ref));
    end

    % TF_CAPI_EXPORT extern void TF_TensorBitcastFrom(const TF_Tensor* from, TF_DataType type, TF_Tensor* to, const int64_t* new_dims, int num_new_dims, TF_Status* status);
    function bitcastFrom(obj, varargin)
      % Questionable feasibility due to the following property:
      %   "On success, *status is set to TF_OK and the two tensors share the same data buffer."
      % For the time being - not supported.
      error('tensorflow:Tensor:bitcastFrom:NotImplemented', 'Not supported.');
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function dims = getDimensions(obj)
      dims = NaN(1, obj.numDims());
      for i = 1:1:numel(dims)
        dims(i) = obj.dim(i-1);
      end
    end

    function varargout = value(obj, varargin)
      if nargin == 1
        % read data
        data = tensorflow_m_('TFM_GetTensorData', obj.ref);
        data = typecast(data, tensorflow.DataType.tf2m(obj.type()));

        % permute to obtain column-major representation
        dims = obj.getDimensions();
        data = permute(reshape(data, fliplr(dims)), [numel(dims):-1:1]);

        if nargout == 1
          varargout{1} = data;
        else
          disp(data);
        end
      elseif nargin == 2 && nargout == 0
        % write data
        varargout = {};
        data_cm = varargin{1};
        % permute to obtain row-major representation
        dims = size(data_cm);
        data_rm = reshape(permute(data_cm, [numel(dims):-1:1]), dims);
        tensorflow_m_('TFM_SetTensorData', obj.ref, data_rm);
      else
        error('tensorflow:Tensor:value:InputArguments', 'Unknown combination of input and output arguments.');
      end
    end

    function delete(obj)
      if obj.isdeletable()
        tensorflow_m_('TF_DeleteTensor', obj.ref);
      end
      delete@util.mixin.Pointer(obj);
    end
  end
end
