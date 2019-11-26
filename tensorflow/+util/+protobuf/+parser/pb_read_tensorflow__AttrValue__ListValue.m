function [list_value] = pb_read_tensorflow__AttrValue__ListValue(buffer, buffer_start, buffer_end)
%pb_read_tensorflow__AttrValue__ListValue Reads the protobuf message ListValue.
%   function [list_value] = pb_read_tensorflow__AttrValue__ListValue(buffer, buffer_start, buffer_end)
%
%   INPUTS:
%     buffer       : a buffer of uint8's to parse
%     buffer_start : optional starting index to consider of the buffer
%                    defaults to 1
%     buffer_end   : optional ending index to consider of the buffer
%                    defaults to length(buffer)
%
%   MEMBERS:
%     s              : repeated uint8 vector, defaults to uint8([]).
%     i              : repeated int64, defaults to int64([]).
%     f              : repeated single, defaults to single([]).
%     b              : repeated uint32, defaults to uint32([]).
%     type           : repeated enum, defaults to int32([]).
%     shape          : repeated <a href="matlab:help pb_read_tensorflow__TensorShapeProto">tensorflow.TensorShapeProto</a>, defaults to struct([]).
%     tensor         : repeated <a href="matlab:help pb_read_tensorflow__TensorProto">tensorflow.TensorProto</a>, defaults to struct([]).
%     func           : repeated <a href="matlab:help pb_read_tensorflow__NameAttrList">tensorflow.NameAttrList</a>, defaults to struct([]).
%
%   See also pb_read_tensorflow__AttrValue, pb_read_tensorflow__TensorShapeProto, pb_read_tensorflow__TensorProto, pb_read_tensorflow__NameAttrList.

  if (nargin < 1)
    buffer = uint8([]);
  end
  if (nargin < 2)
    buffer_start = 1;
  end
  if (nargin < 3)
    buffer_end = length(buffer);
  end

  descriptor = util.protobuf.parser.pb_descriptor_tensorflow__AttrValue__ListValue();
  list_value = pblib_generic_parse_from_string(buffer, descriptor, buffer_start, buffer_end);
  list_value.descriptor_function = @util.protobuf.parser.pb_descriptor_tensorflow__AttrValue__ListValue;
