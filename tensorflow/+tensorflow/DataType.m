classdef DataType < uint32
  enumeration
    TF_FLOAT (1)
    TF_DOUBLE (2)
    TF_INT32 (3)
    TF_UINT8 (4)
    TF_INT16 (5)
    TF_INT8 (6)
    TF_STRING (7)
    TF_COMPLEX64 (8)
    TF_COMPLEX (8)
    TF_INT64 (9)
    TF_BOOL (10)
    TF_QINT8 (11)
    TF_QUINT8 (12)
    TF_QINT32 (13)
    TF_BFLOAT16 (14)
    TF_QINT16 (15)
    TF_QUINT16 (16)
    TF_UINT16 (17)
    TF_COMPLEX128 (18)
    TF_HALF (19)
    TF_RESOURCE (20)
    TF_VARIANT (21)
    TF_UINT32 (22)
    TF_UINT64 (23)
  end

  methods

    % TF_CAPI_EXPORT extern size_t TF_DataTypeSize(TF_DataType dt);
    % TODO

  end

  methods (Static)
    function m = tf2m(tftype)
      % convert a TensorFlow type to the corresponding Matlab class
      id = lower(char(tftype)); id = id(4:end);
      if any(strcmp(tensorflow.DataType.direct(), id))
        % direct mapping
        m = id;
      elseif any(strcmp(tensorflow.DataType.indirect_tf2m(), id))
        % indirect mapping
        switch(id)
          case 'float'
            m = 'single';
          case 'bool'
            m = 'logical';
          otherwise
            error('tensorflow:DataType:tf2m:Internal', 'No implemented indirect mapping found - please inform the developers.');
        end
      else
        % e = MException('tensorflow:DataType:tf2m', ['No known Matlab equivalent for ' char(tftype) '.']);
        % throw(e);
        error('tensorflow:DataType:tf2m:NoEquivalent', ['No known Matlab equivalent for ' char(tftype) '.']);
      end
    end

    function tf = m2tf(matclass)
      % convert a Matlab class to the corresponding TensorFlow type
      assert(ischar(matclass), 'The supplied argument must be a string identifying a Matlab class.');
      if any(strcmp(tensorflow.DataType.direct(), matclass))
        % direct mapping
        tf = ['TF_' upper(matclass)];
      elseif any(strcmp(tensorflow.DataType.indirect_m2tf(), matclass))
        % indirect mapping
        switch(matclass)
          case 'single'
            tf = tensorflow.DataType.TF_FLOAT;
          case 'logical'
            tf = tensorflow.DataType.TF_DOUBLE;
          otherwise
            error('tensorflow:DataType:m2tf:Internal', 'No implemented indirect mapping found - please inform the developers.');
        end
      else
        % e = MException('tensorflow:DataType:m2tf', ['No known Matlab equivalent for ' matclass '.']);
        % throw(e);
        error('tensorflow:DataType:m2tf:NoEquivalent', ['No known Matlab equivalent for ' matclass '.']);
      end
    end

    function map = direct()
      % Matlab classes with direct equivalent in TensorFlow
      map = { 'double', 'int32', 'uint8', 'int16', 'int8', 'complex', ...
              'int64', 'uint32', 'uint64' };
    end

    function map = indirect_m2tf()
      % indirect mapping from Matlab classes to TensorFlow types
      map = { 'single', 'logical' };
    end

    function map = indirect_tf2m()
      % indirect mapping from TensorFlow types to Matlab classes
      map = { 'float', 'bool' };
    end
  end
end
