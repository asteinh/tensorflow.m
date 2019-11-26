function [op_deprecation] = pb_read_tensorflow__OpDeprecation(buffer, buffer_start, buffer_end)
%pb_read_tensorflow__OpDeprecation Reads the protobuf message OpDeprecation.
%   function [op_deprecation] = pb_read_tensorflow__OpDeprecation(buffer, buffer_start, buffer_end)
%
%   INPUTS:
%     buffer       : a buffer of uint8's to parse
%     buffer_start : optional starting index to consider of the buffer
%                    defaults to 1
%     buffer_end   : optional ending index to consider of the buffer
%                    defaults to length(buffer)
%
%   MEMBERS:
%     version        : optional int32, defaults to int32(0).
%     explanation    : optional string, defaults to ''.
%
%   See also pb_read_tensorflow__OpDef, pb_read_tensorflow__OpList.

  if (nargin < 1)
    buffer = uint8([]);
  end
  if (nargin < 2)
    buffer_start = 1;
  end
  if (nargin < 3)
    buffer_end = length(buffer);
  end

  descriptor = util.protobuf.parser.pb_descriptor_tensorflow__OpDeprecation();
  op_deprecation = pblib_generic_parse_from_string(buffer, descriptor, buffer_start, buffer_end);
  op_deprecation.descriptor_function = @util.protobuf.parser.pb_descriptor_tensorflow__OpDeprecation;
