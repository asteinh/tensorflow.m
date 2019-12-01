classdef Code < util.mixin.Enumeration & util.mixin.Vectorize
  properties (Constant, Access=private)
  % CODEMAP collects two columns: TF code | enum value
    CODEMAP = [ ...
      { 'TF_OK', 0 };
      { 'TF_CANCELLED', 1 };
      { 'TF_UNKNOWN', 2 };
      { 'TF_INVALID_ARGUMENT', 3 };
      { 'TF_DEADLINE_EXCEEDED', 4 };
      { 'TF_NOT_FOUND', 5 };
      { 'TF_ALREADY_EXISTS', 6 };
      { 'TF_PERMISSION_DENIED', 7 };
      { 'TF_RESOURCE_EXHAUSTED', 8 };
      { 'TF_FAILED_PRECONDITION', 9 };
      { 'TF_ABORTED', 10 };
      { 'TF_OUT_OF_RANGE', 11 };
      { 'TF_UNIMPLEMENTED', 12 };
      { 'TF_INTERNAL', 13 };
      { 'TF_UNAVAILABLE', 14 };
      { 'TF_DATA_LOSS', 15 };
      { 'TF_UNAUTHENTICATED', 16 };
    ];
  end

  methods
    function obj = Code(varargin)
      obj = vectorize_constructor_(obj, varargin{:});
      if numel(obj) == 1 && nargin ~= 0
        id = varargin{1};
        if isa(id, 'tensorflow.Code')
          obj.set_value_(tensorflow.Code.lookup_fwd(id.value));
        else
          if ischar(id)
            % create from string
            val = tensorflow.Code.lookup_fwd(id);
            assert(~isempty(val), 'tensorflow:Code:InputArguments', ['Cannot map given message ''' id ''' to a known TensorFlow code.']);
          elseif tensorflow.Code.is_int_robust_(id)
            % create from integer
            val = tensorflow.Code.lookup_int(id);
            assert(~isempty(val), 'tensorflow:Code:InputArguments', ['Cannot map given integer ''' id ''' to a known TensorFlow Code.']);
          else
            error('tensorflow:Code:InputArguments', 'Cannot create tensorflow.Code from given arguments.');
          end
          obj.set_value_(val);
        end
      end
    end
  end

  methods (Static, Access=protected)
    function entry = lookup_fwd(msg)
      idx = strcmp(msg, tensorflow.Code.CODEMAP(:,1));
      entry = tensorflow.Code.CODEMAP(idx, :);
    end

    function entry = lookup_int(val_int)
      idx = find([tensorflow.Code.CODEMAP{:,2}] == val_int);
      entry = tensorflow.Code.CODEMAP(idx, :);
    end
  end
end
