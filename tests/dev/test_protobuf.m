clear; clc

g = tensorflow.Graph();
s = tensorflow.Session(g);
status = tensorflow.Status();
proto = tensorflow.Buffer(tensorflow_m_('TF_GetAllOpList'), true);

str = char(proto.data());
% in = g.constant(str);
% 
% % set up decode_proto OP
% desc = g.newOperation('DecodeProtoV2', 'DecodeProtoV2_test');
% desc.addInput(in);
% desc.setAttrString('message_type', 'tensorflow.OpDef');
% desc.setAttrStringList('field_names', { 'name', 'summary', 'description' });
% desc.setAttrTypeList('output_types', [ tensorflow.DataType('TF_STRING'), tensorflow.DataType('TF_STRING'), tensorflow.DataType('TF_STRING') ]);
% desc.setAttrString('descriptor_source', './tensorflow/protobuf/descriptor_set_out');
% 
% %
% oper = desc.finishOperation();
% output = tensorflow.Output(oper);
% res = s.run([], [], output);

op_list = util.protobuf.parser.pb_read_tensorflow__OpList(proto.data());

%%
rmdir ops s
mkdir ops
% for op = op_list.op(851) % Add
for op = op_list.op
  gen = util.bob.OpGenerator(op);
  gen.generateFunction('ops');
end


