function [attr_def] = pb_read_tensorflow__OpDef__AttrDef(buffer, buffer_start, buffer_end)
%pb_read_tensorflow__OpDef__AttrDef Reads the protobuf message AttrDef.
%   function [attr_def] = pb_read_tensorflow__OpDef__AttrDef(buffer, buffer_start, buffer_end)
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
%     type           : optional string, defaults to ''.
%     default_value  : optional <a href="matlab:help pb_read_tensorflow__AttrValue">tensorflow.AttrValue</a>, defaults to struct([]).
%     description    : optional string, defaults to ''.
%     has_minimum    : optional uint32, defaults to uint32(0).
%     minimum        : optional int64, defaults to int64(0).
%     allowed_values : optional <a href="matlab:help pb_read_tensorflow__AttrValue">tensorflow.AttrValue</a>, defaults to struct([]).
%
%   See also pb_read_tensorflow__OpDef, pb_read_tensorflow__AttrValue, pb_read_tensorflow__OpDeprecation, pb_read_tensorflow__OpList.

  if (nargin < 1)
    buffer = uint8([]);
  end
  if (nargin < 2)
    buffer_start = 1;
  end
  if (nargin < 3)
    buffer_end = length(buffer);
  end

  descriptor = util.protobuf.parser.pb_descriptor_tensorflow__OpDef__AttrDef();
  attr_def = pblib_generic_parse_from_string(buffer, descriptor, buffer_start, buffer_end);
  attr_def.descriptor_function = @util.protobuf.parser.pb_descriptor_tensorflow__OpDef__AttrDef;
