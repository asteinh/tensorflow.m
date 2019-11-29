function [attr_value] = pb_read_tensorflow__AttrValue(buffer, buffer_start, buffer_end)
%pb_read_tensorflow__AttrValue Reads the protobuf message AttrValue.
%   function [attr_value] = pb_read_tensorflow__AttrValue(buffer, buffer_start, buffer_end)
%
%   INPUTS:
%     buffer       : a buffer of uint8's to parse
%     buffer_start : optional starting index to consider of the buffer
%                    defaults to 1
%     buffer_end   : optional ending index to consider of the buffer
%                    defaults to length(buffer)
%
%   MEMBERS:
%     s              : optional uint8 vector, defaults to uint8('').
%     i              : optional int64, defaults to int64(0).
%     f              : optional single, defaults to single(0).
%     b              : optional uint32, defaults to uint32(0).
%     type           : optional enum, defaults to int32(0).
%     shape          : optional <a href="matlab:help pb_read_tensorflow__TensorShapeProto">tensorflow.TensorShapeProto</a>, defaults to struct([]).
%     tensor         : optional <a href="matlab:help pb_read_tensorflow__TensorProto">tensorflow.TensorProto</a>, defaults to struct([]).
%     list           : optional <a href="matlab:help pb_read_tensorflow__AttrValue__ListValue">tensorflow.AttrValue.ListValue</a>, defaults to struct([]).
%     func           : optional <a href="matlab:help pb_read_tensorflow__NameAttrList">tensorflow.NameAttrList</a>, defaults to struct([]).
%     placeholder    : optional string, defaults to ''.
%
%   See also pb_read_tensorflow__TensorShapeProto, pb_read_tensorflow__TensorProto, pb_read_tensorflow__AttrValue__ListValue, pb_read_tensorflow__NameAttrList.

  if (nargin < 1)
    buffer = uint8([]);
  end
  if (nargin < 2)
    buffer_start = 1;
  end
  if (nargin < 3)
    buffer_end = length(buffer);
  end

  descriptor = util.protobuf.parser.pb_descriptor_tensorflow__AttrValue();
  attr_value = util.protobuf.lib.pblib_generic_parse_from_string(buffer, descriptor, buffer_start, buffer_end);
  attr_value.descriptor_function = @() util.protobuf.parser.pb_descriptor_tensorflow__AttrValue();
