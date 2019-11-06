function varargout = mex_call(varargin)
  [varargout{1:nargout}] = tensorflowm_api(varargin{:});
end
