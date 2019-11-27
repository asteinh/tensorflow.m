clear; clc

g = tensorflow.Graph();
s = tensorflow.Session(g);
status = tensorflow.Status();
proto = tensorflow.Buffer(tensorflow_m_('TF_GetAllOpList'), true);

str = char(proto.data());
bytes = g.constant(str);

% % set up decode_proto OP
% desc = g.newOperation('DecodeProtoV2', 'DecodeProtoV2_test');
% desc.addInput(bytes);
% desc.setAttrString('message_type', 'tensorflow.OpDef');
% desc.setAttrStringList('field_names', { 'name', 'summary', 'description' });
% desc.setAttrTypeList('output_types', [ tensorflow.DataType('TF_STRING'), tensorflow.DataType('TF_STRING'), tensorflow.DataType('TF_STRING') ]);
% desc.setAttrString('descriptor_source', './tensorflow/protobuf/descriptor_set_out');
% 
% oper = desc.finishOperation();
% output = tensorflow.Output(oper);
output = g.decodeprotov2(...
  bytes, ...
  'tensorflow.OpDef', ...
  { 'name', 'summary', 'description' }, ...
  [ tensorflow.DataType('TF_STRING'), tensorflow.DataType('TF_STRING'), tensorflow.DataType('TF_STRING') ], ...
  'descriptor_source', './tensorflow/protobuf/descriptor_set_out' ...
 );

res = s.run([], [], output);

