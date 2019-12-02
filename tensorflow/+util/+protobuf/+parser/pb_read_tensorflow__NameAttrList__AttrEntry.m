function [attr_entry] = pb_read_tensorflow__NameAttrList__AttrEntry(buffer, buffer_start, buffer_end)
%pb_read_tensorflow__NameAttrList__AttrEntry Reads the protobuf message AttrEntry.
%   function [attr_entry] = pb_read_tensorflow__NameAttrList__AttrEntry(buffer, buffer_start, buffer_end)
%
%   INPUTS:
%     buffer       : a buffer of uint8's to parse
%     buffer_start : optional starting index to consider of the buffer
%                    defaults to 1
%     buffer_end   : optional ending index to consider of the buffer
%                    defaults to length(buffer)
%
%   MEMBERS:
%     key            : optional string, defaults to ''.
%     value          : optional <a href="matlab:help pb_read_tensorflow__AttrValue">tensorflow.AttrValue</a>, defaults to struct([]).
%
%   See also pb_read_tensorflow__NameAttrList, pb_read_tensorflow__AttrValue.

  if (nargin < 1)
    buffer = uint8([]);
  end
  if (nargin < 2)
    buffer_start = 1;
  end
  if (nargin < 3)
    buffer_end = length(buffer);
  end

  descriptor = pb_descriptor_tensorflow__NameAttrList__AttrEntry();
  attr_entry = util.protobuf.lib.pblib_generic_parse_from_string(buffer, descriptor, buffer_start, buffer_end);
  attr_entry.descriptor_function = @pb_descriptor_tensorflow__NameAttrList__AttrEntry;
