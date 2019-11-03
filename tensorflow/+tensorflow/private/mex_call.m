function varargout = mex_call(varargin)
  [varargout{1:nargout}] = tfm_api(varargin{:});
end
