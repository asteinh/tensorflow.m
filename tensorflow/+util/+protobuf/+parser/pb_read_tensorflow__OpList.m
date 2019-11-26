function [op_list] = pb_read_tensorflow__OpList(buffer, buffer_start, buffer_end)
%pb_read_tensorflow__OpList Reads the protobuf message OpList.
%   function [op_list] = pb_read_tensorflow__OpList(buffer, buffer_start, buffer_end)
%
%   INPUTS:
%     buffer       : a buffer of uint8's to parse
%     buffer_start : optional starting index to consider of the buffer
%                    defaults to 1
%     buffer_end   : optional ending index to consider of the buffer
%                    defaults to length(buffer)
%
%   MEMBERS:
%     op             : repeated <a href="matlab:help pb_read_tensorflow__OpDef">tensorflow.OpDef</a>, defaults to struct([]).
%
%   See also pb_read_tensorflow__OpDef, pb_read_tensorflow__OpDeprecation.

  if (nargin < 1)
    buffer = uint8([]);
  end
  if (nargin < 2)
    buffer_start = 1;
  end
  if (nargin < 3)
    buffer_end = length(buffer);
  end

  descriptor = util.protobuf.parser.pb_descriptor_tensorflow__OpList();
  op_list = pblib_generic_parse_from_string(buffer, descriptor, buffer_start, buffer_end);
  op_list.descriptor_function = @util.protobuf.parser.pb_descriptor_tensorflow__OpList;
