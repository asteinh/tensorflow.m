classdef Tensor < util.mixin.Pointer & util.mixin.Vectorize
  %TENSOR Summary of this class goes here
  %   Detailed explanation goes here

  methods
    % TF_CAPI_EXPORT extern TF_Tensor* TF_NewTensor(TF_DataType, const int64_t* dims, int num_dims, void* data, size_t len, void (*deallocator)(void* data, size_t len, void* arg), void* deallocator_arg);
    % TF_CAPI_EXPORT extern TF_Tensor* TF_AllocateTensor(TF_DataType, const int64_t* dims, int num_dims, size_t len);
    function obj = Tensor(varargin)

      % input arguments for:
      %   - construction by reference (vectorized)
      %     1) ref [uint64]
      %        ... an array of reference values
      %     2) owned [logical]
      %        ... an array of boolean values if the underlying memory is owned
      %            (true); size has to match size of reference value array
      %
      %   - construction by data
      %     1) data [...]
      %        ... data of arbitrary dimensions and data type
      %
      %   - construction by data type & dimensions
      %     1) datatype [tensorflow.DataType]
      %        ... the data type the Tensor represents
      %     2) dims [numeric]
      %        ... the dimensions of the resulting Tensor, must be a vector

      if nargin == 0
        % dummy, for copying
        return;
      elseif nargin == 1
        % construction by data
        data = varargin{1};
        if iscell(data)
          obj = vectorize_constructor_(obj, varargin{:});
          return;
        else
          dtype = tensorflow.DataType(tensorflow.DataType.m2tf(class(data))); % retrieve datatype from data
          dims = size(data); % data dimensions
          ref = tensorflow_m_('TF_AllocateTensor', int32(dtype), int64(dims), int32(numel(dims)));
          obj.set_reference_(ref, true);
          obj.value(data); % set data
        end
      elseif nargin == 2 && isa(varargin{1}, 'uint64') && islogical(varargin{2})
        % construction by reference
        ref = varargin{1};
        owned = varargin{2};
        assert(numel(owned) == 1, 'tensorflow:Tensor:InputArguments', '(Vectorized) Construction by reference has to have a single ownership flag.');
        if numel(ref) > 1
          obj = vectorize_constructor_(obj, varargin{:});
          return;
        else
          obj.set_reference_(ref, owned);
        end
      elseif nargin == 2
        % construction by data type & dimensions
        dtype = varargin{1};
        assert(tensorflow.DataType.ismember(dtype), 'tensorflow:Tensor:InputArguments', 'Construction by data type and dimension requires the first input to represent a data type, being either of class tensorflow.DataType or interpretable as such.');
        dtype = tensorflow.DataType(dtype);
        dims = varargin{2};
        assert(isvector(dims), 'tensorflow:Tensor:InputArguments', 'Construction by data type and dimension requires the second input to be a numeric array of dimensions.');
        ref = tensorflow_m_('TF_AllocateTensor', int32(dtype), int64(dims), int32(numel(dims)));
        obj.set_reference_(ref, true);
      else
        error('tensorflow:Tensor:InputArguments', 'Cannot create tensorflow.Tensor with given arguments.');
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
        if strcmp(obj.type, 'TF_STRING')
          data = char(data);
        else
          data = typecast(data, tensorflow.DataType.tf2m(obj.type()));
          % permute to obtain column-major representation
          dims = obj.getDimensions();
          data = permute(reshape(data, fliplr(dims)), [numel(dims):-1:1]);
        end

        if nargout == 1
          varargout{1} = data;
        else
          disp(data);
        end
      elseif nargin == 2 && nargout == 0
        % write data
        varargout = {};
        if strcmp(obj.type, 'TF_STRING')
          data = uint8(varargin{1});
        else
          data_cm = varargin{1};
          % permute to obtain row-major representation
          dims = size(data_cm);
          data = reshape(permute(data_cm, [numel(dims):-1:1]), dims);
        end
        tensorflow_m_('TFM_SetTensorData', obj.ref, data(:)');
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
