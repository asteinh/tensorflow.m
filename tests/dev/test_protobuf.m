clear; clc

g = tensorflow.Graph();
s = tensorflow.Session(g);
status = tensorflow.Status();
proto = tensorflow.Buffer(tensorflow_m_('TF_GetAllOpList'), true);

str = char(proto.data());
in = g.constant(str);

% set up decode_proto OP
desc = g.newOperation('DecodeProtoV2', 'DecodeProtoV2_test');
desc.addInput(in);
desc.setAttrString('message_type', 'OpDef');
desc.setAttrStringList('field_names', {});
desc.setAttrTypeList('output_types', []);
desc.setAttrString('descriptor_source', 'local://');

%
oper = desc.finishOperation();
output = tensorflow.Output(oper);

%
% apidef = tensorflow.ApiDefMap(proto);
res = s.run([],[],output);
