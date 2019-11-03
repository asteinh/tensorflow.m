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
    function m = TF2M(obj)
      id = lower(char(obj)); id = id(4:end);
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
            error('No implemented indirect mapping found - please inform the developers.');
        end
      else
        e = MException('tensorflow:DataType:TF2M', ['No known Matlab equivalent for ' char(obj) '.']);
        throw(e);
      end
    end
  end

  methods (Static)
    function tf = M2TF(matclass)
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
            error('No implemented indirect mapping found - please inform the developers.');
        end
      else
        e = MException('tensorflow:DataType:M2TF', ['No known Matlab equivalent for ' matclass '.']);
        throw(e);
      end
    end
    
    function map = direct()
      map = { 'double', 'int32', 'uint8', 'int16', 'int8', 'complex', ...
              'int64', 'uint32', 'uint64' };
    end
    
    function map = indirect_m2tf()
      map = { 'single', 'logical' };
    end
    
    function map = indirect_tf2m()
      map = { 'float', 'bool' };
    end
  end
end
