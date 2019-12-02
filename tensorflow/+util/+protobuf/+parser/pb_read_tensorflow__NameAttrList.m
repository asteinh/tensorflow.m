function [name_attr_list] = pb_read_tensorflow__NameAttrList(buffer, buffer_start, buffer_end)
%pb_read_tensorflow__NameAttrList Reads the protobuf message NameAttrList.
%   function [name_attr_list] = pb_read_tensorflow__NameAttrList(buffer, buffer_start, buffer_end)
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
%     attr           : repeated <a href="matlab:help pb_read_tensorflow__NameAttrList__AttrEntry">tensorflow.NameAttrList.AttrEntry</a>, defaults to struct([]).
%
%   See also pb_read_tensorflow__NameAttrList__AttrEntry, pb_read_tensorflow__AttrValue.

  if (nargin < 1)
    buffer = uint8([]);
  end
  if (nargin < 2)
    buffer_start = 1;
  end
  if (nargin < 3)
    buffer_end = length(buffer);
  end

  descriptor = pb_descriptor_tensorflow__NameAttrList();
  name_attr_list = util.protobuf.lib.pblib_generic_parse_from_string(buffer, descriptor, buffer_start, buffer_end);
  name_attr_list.descriptor_function = @pb_descriptor_tensorflow__NameAttrList;
