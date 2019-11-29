function [op_def] = pb_read_tensorflow__OpDef(buffer, buffer_start, buffer_end)
%pb_read_tensorflow__OpDef Reads the protobuf message OpDef.
%   function [op_def] = pb_read_tensorflow__OpDef(buffer, buffer_start, buffer_end)
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
%     input_arg      : repeated <a href="matlab:help pb_read_tensorflow__OpDef__ArgDef">tensorflow.OpDef.ArgDef</a>, defaults to struct([]).
%     output_arg     : repeated <a href="matlab:help pb_read_tensorflow__OpDef__ArgDef">tensorflow.OpDef.ArgDef</a>, defaults to struct([]).
%     control_output : repeated string, defaults to char([]).
%     attr           : repeated <a href="matlab:help pb_read_tensorflow__OpDef__AttrDef">tensorflow.OpDef.AttrDef</a>, defaults to struct([]).
%     deprecation    : optional <a href="matlab:help pb_read_tensorflow__OpDeprecation">tensorflow.OpDeprecation</a>, defaults to struct([]).
%     summary        : optional string, defaults to ''.
%     description    : optional string, defaults to ''.
%     is_commutative : optional uint32, defaults to uint32(0).
%     is_aggregate   : optional uint32, defaults to uint32(0).
%     is_stateful    : optional uint32, defaults to uint32(0).
%     allows_uninitialized_input: optional uint32, defaults to uint32(0).
%
%   See also pb_read_tensorflow__OpDef__ArgDef, pb_read_tensorflow__OpDef__AttrDef, pb_read_tensorflow__OpDeprecation, pb_read_tensorflow__OpList.

  if (nargin < 1)
    buffer = uint8([]);
  end
  if (nargin < 2)
    buffer_start = 1;
  end
  if (nargin < 3)
    buffer_end = length(buffer);
  end

  descriptor = util.protobuf.parser.pb_descriptor_tensorflow__OpDef();
  op_def = util.protobuf.lib.pblib_generic_parse_from_string(buffer, descriptor, buffer_start, buffer_end);
  op_def.descriptor_function = @() pb_descriptor_tensorflow__OpDef();
