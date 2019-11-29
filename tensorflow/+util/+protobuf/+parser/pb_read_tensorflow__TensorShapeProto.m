function [tensor_shape_proto] = pb_read_tensorflow__TensorShapeProto(buffer, buffer_start, buffer_end)
%pb_read_tensorflow__TensorShapeProto Reads the protobuf message TensorShapeProto.
%   function [tensor_shape_proto] = pb_read_tensorflow__TensorShapeProto(buffer, buffer_start, buffer_end)
%
%   INPUTS:
%     buffer       : a buffer of uint8's to parse
%     buffer_start : optional starting index to consider of the buffer
%                    defaults to 1
%     buffer_end   : optional ending index to consider of the buffer
%                    defaults to length(buffer)
%
%   MEMBERS:
%     dim            : repeated <a href="matlab:help pb_read_tensorflow__TensorShapeProto__Dim">tensorflow.TensorShapeProto.Dim</a>, defaults to struct([]).
%     unknown_rank   : optional uint32, defaults to uint32(0).
%
%   See also pb_read_tensorflow__TensorShapeProto__Dim.

  if (nargin < 1)
    buffer = uint8([]);
  end
  if (nargin < 2)
    buffer_start = 1;
  end
  if (nargin < 3)
    buffer_end = length(buffer);
  end

  descriptor = util.protobuf.parser.pb_descriptor_tensorflow__TensorShapeProto();
  tensor_shape_proto = util.protobuf.lib.pblib_generic_parse_from_string(buffer, descriptor, buffer_start, buffer_end);
  tensor_shape_proto.descriptor_function =@() util.protobuf.parser.pb_descriptor_tensorflow__TensorShapeProto();
