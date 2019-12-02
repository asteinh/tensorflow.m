function [arg_def] = pb_read_tensorflow__OpDef__ArgDef(buffer, buffer_start, buffer_end)
%pb_read_tensorflow__OpDef__ArgDef Reads the protobuf message ArgDef.
%   function [arg_def] = pb_read_tensorflow__OpDef__ArgDef(buffer, buffer_start, buffer_end)
%
%   INPUTS:
%     buffer       : a buffer of uint8's to parse
%     buffer_start : optional starting index to consider of the buffer
%                    defaults to 1
%     buffer_end   : optional ending index to consider of the buffer
%                    defaults to length(buffer)
%
%   MEMBERS:
%     name           : optional string, defaults to ''.
%     description    : optional string, defaults to ''.
%     type           : optional enum, defaults to int32(0).
%     type_attr      : optional string, defaults to ''.
%     number_attr    : optional string, defaults to ''.
%     type_list_attr : optional string, defaults to ''.
%     is_ref         : optional uint32, defaults to uint32(0).
%
%   See also pb_read_tensorflow__OpDef, pb_read_tensorflow__OpDeprecation, pb_read_tensorflow__OpList.

  if (nargin < 1)
    buffer = uint8([]);
  end
  if (nargin < 2)
    buffer_start = 1;
  end
  if (nargin < 3)
    buffer_end = length(buffer);
  end

  descriptor = util.protobuf.parser.pb_descriptor_tensorflow__OpDef__ArgDef();
  arg_def = util.protobuf.lib.pblib_generic_parse_from_string(buffer, descriptor, buffer_start, buffer_end);
  arg_def.descriptor_function = @() util.protobuf.parser.pb_descriptor_tensorflow__OpDef__ArgDef();
