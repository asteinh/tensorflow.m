function [dim] = pb_read_tensorflow__TensorShapeProto__Dim(buffer, buffer_start, buffer_end)
%pb_read_tensorflow__TensorShapeProto__Dim Reads the protobuf message Dim.
%   function [dim] = pb_read_tensorflow__TensorShapeProto__Dim(buffer, buffer_start, buffer_end)
%
%   INPUTS:
%     buffer       : a buffer of uint8's to parse
%     buffer_start : optional starting index to consider of the buffer
%                    defaults to 1
%     buffer_end   : optional ending index to consider of the buffer
%                    defaults to length(buffer)
%
%   MEMBERS:
%     size           : optional int64, defaults to int64(0).
%     name           : optional string, defaults to ''.
%
%   See also pb_read_tensorflow__TensorShapeProto.

  if (nargin < 1)
    buffer = uint8([]);
  end
  if (nargin < 2)
    buffer_start = 1;
  end
  if (nargin < 3)
    buffer_end = length(buffer);
  end

  descriptor = util.protobuf.parser.pb_descriptor_tensorflow__TensorShapeProto__Dim();
  dim = pblib_generic_parse_from_string(buffer, descriptor, buffer_start, buffer_end);
  dim.descriptor_function = @util.protobuf.parser.pb_descriptor_tensorflow__TensorShapeProto__Dim;
