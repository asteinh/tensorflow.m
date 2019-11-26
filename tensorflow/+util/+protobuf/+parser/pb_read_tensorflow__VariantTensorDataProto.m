function [variant_tensor_data_proto] = pb_read_tensorflow__VariantTensorDataProto(buffer, buffer_start, buffer_end)
%pb_read_tensorflow__VariantTensorDataProto Reads the protobuf message VariantTensorDataProto.
%   function [variant_tensor_data_proto] = pb_read_tensorflow__VariantTensorDataProto(buffer, buffer_start, buffer_end)
%
%   INPUTS:
%     buffer       : a buffer of uint8's to parse
%     buffer_start : optional starting index to consider of the buffer
%                    defaults to 1
%     buffer_end   : optional ending index to consider of the buffer
%                    defaults to length(buffer)
%
%   MEMBERS:
%     type_name      : optional string, defaults to ''.
%     metadata       : optional uint8 vector, defaults to uint8('').
%     tensors        : repeated <a href="matlab:help pb_read_tensorflow__TensorProto">tensorflow.TensorProto</a>, defaults to struct([]).
%
%   See also pb_read_tensorflow__TensorProto.

  if (nargin < 1)
    buffer = uint8([]);
  end
  if (nargin < 2)
    buffer_start = 1;
  end
  if (nargin < 3)
    buffer_end = length(buffer);
  end

  descriptor = util.protobuf.parser.pb_descriptor_tensorflow__VariantTensorDataProto();
  variant_tensor_data_proto = pblib_generic_parse_from_string(buffer, descriptor, buffer_start, buffer_end);
  variant_tensor_data_proto.descriptor_function = @util.protobuf.parser.pb_descriptor_tensorflow__VariantTensorDataProto;
