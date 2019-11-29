function [tensor_proto] = pb_read_tensorflow__TensorProto(buffer, buffer_start, buffer_end)
%pb_read_tensorflow__TensorProto Reads the protobuf message TensorProto.
%   function [tensor_proto] = pb_read_tensorflow__TensorProto(buffer, buffer_start, buffer_end)
%
%   INPUTS:
%     buffer       : a buffer of uint8's to parse
%     buffer_start : optional starting index to consider of the buffer
%                    defaults to 1
%     buffer_end   : optional ending index to consider of the buffer
%                    defaults to length(buffer)
%
%   MEMBERS:
%     dtype          : optional enum, defaults to int32(0).
%     tensor_shape   : optional <a href="matlab:help pb_read_tensorflow__TensorShapeProto">tensorflow.TensorShapeProto</a>, defaults to struct([]).
%     version_number : optional int32, defaults to int32(0).
%     tensor_content : optional uint8 vector, defaults to uint8('').
%     half_val       : repeated int32, defaults to int32([]).
%     float_val      : repeated single, defaults to single([]).
%     double_val     : repeated double, defaults to double([]).
%     int_val        : repeated int32, defaults to int32([]).
%     string_val     : repeated uint8 vector, defaults to uint8([]).
%     scomplex_val   : repeated single, defaults to single([]).
%     int64_val      : repeated int64, defaults to int64([]).
%     bool_val       : repeated uint32, defaults to uint32([]).
%     dcomplex_val   : repeated double, defaults to double([]).
%     resource_handle_val: repeated <a href="matlab:help pb_read_tensorflow__ResourceHandleProto">tensorflow.ResourceHandleProto</a>, defaults to struct([]).
%     variant_val    : repeated <a href="matlab:help pb_read_tensorflow__VariantTensorDataProto">tensorflow.VariantTensorDataProto</a>, defaults to struct([]).
%     uint32_val     : repeated uint32, defaults to uint32([]).
%     uint64_val     : repeated uint64, defaults to uint64([]).
%
%   See also pb_read_tensorflow__TensorShapeProto, pb_read_tensorflow__ResourceHandleProto, pb_read_tensorflow__VariantTensorDataProto.

  if (nargin < 1)
    buffer = uint8([]);
  end
  if (nargin < 2)
    buffer_start = 1;
  end
  if (nargin < 3)
    buffer_end = length(buffer);
  end

  descriptor = util.protobuf.parser.pb_descriptor_tensorflow__TensorProto();
  tensor_proto = util.protobuf.lib.pblib_generic_parse_from_string(buffer, descriptor, buffer_start, buffer_end);
  tensor_proto.descriptor_function =@() util.protobuf.parser.pb_descriptor_tensorflow__TensorProto();
