classdef Tensor < util.mixin.Pointer
  %TENSOR Summary of this class goes here
  %   Detailed explanation goes here

  properties (SetAccess=private)
    dtype = [];
    dims = [];
  end

  methods
    function obj = Tensor(varargin)
      if nargin == 1 && isscalar(varargin{1}) && isa(varargin{1}, 'uint64')
        % Tensor(ref) ... with ref a uint64 value of a pointer's reference;
        %                 untested and not supported
        newly_allocated = false;
        ref_ = varargin{1};
      elseif nargin == 1
        % Tensor(data) ... with data a tensor that will be parsed to
        %                  allocate a TF_Tensor with appropriate type,
        %                  dimension and values
        newly_allocated = true;
        data = varargin{1};
        % retrieve datatype from data
        dtype = tensorflow.DataType.M2TF(class(data));
        assert(ismember(dtype, enumeration('tensorflow.DataType')));
        dtype = tensorflow.DataType(dtype);
        % data dimensions
        dims = size(data);
        ref_ = mex_call('TF_AllocateTensor', int32(dtype), int64(dims), int32(numel(dims)));
      elseif nargin == 2
        % Tensor(type, dims) ... allocate a TF_Tensor without initializing
        %                        the linked data
        newly_allocated = true;
        dtype = varargin{1};
        assert(ismember(dtype, enumeration('tensorflow.DataType')));
        dtype = tensorflow.DataType(dtype);
        dims = varargin{2};
        assert(isvector(dims));
        ref_ = mex_call('TF_AllocateTensor', int32(dtype), int64(dims), int32(numel(dims)));
        data = [];
      else
        error('Unknown combination of input and output arguments.');
      end

      % create pointer
      obj = obj@util.mixin.Pointer(ref_);

      if newly_allocated
        obj.dtype = dtype;
        obj.dims = dims;
        if ~isempty(data)
          obj.data(data); % set data, if given
        end
      else
        obj.dtype = obj.tensorType();
        obj.dims = obj.getDimensions();
      end
    end

    function varargout = data(obj, varargin)
      if nargin == 1
        % read data
        data_ = mex_call('TFM_GetTensorData', obj.ref);
        data_ = typecast(data_, obj.dtype.TF2M());
        data = reshape(data_, obj.dims);
        if nargout == 1
          varargout{1} = data;
        else
          disp(data);
        end
      elseif nargin == 2 && nargout == 0
        % write data
        varargout = {};
        data = varargin{1};
        mex_call('TFM_SetTensorData', obj.ref, data);
      else
        error('Unknown combination of input and output arguments.');
      end
    end

    function dims = getDimensions(obj)
      dims = NaN(1, obj.numDims());
      for i = 1:1:numel(dims)
        dims(i) = obj.dim(i-1);
      end
    end

    % TF_CAPI_EXPORT extern int TF_NumDims(const TF_Tensor*);
    function n = numDims(obj)
      n = mex_call('TF_NumDims', obj.ref);
    end
    % TF_CAPI_EXPORT extern int64_t TF_Dim(const TF_Tensor* tensor, int dim_index);
    function d = dim(obj, idx)
      d = mex_call('TF_Dim', obj.ref, int32(idx));
    end
    % TF_CAPI_EXPORT extern TF_DataType TF_TensorType(const TF_Tensor*);
    function t = tensorType(obj)
      t = tensorflow.DataType(mex_call('TF_TensorType', obj.ref));
    end

    function delete(obj)
      if ~obj.isempty()
        mex_call('TF_DeleteTensor', obj.ref);
      end
      delete@util.mixin.Pointer(obj);
    end
  end
end
