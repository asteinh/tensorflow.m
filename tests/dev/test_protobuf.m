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

%
oper = desc.finishOperation();
output = tensorflow.Output(oper);

% apidef = tensorflow.ApiDefMap(proto);




% proto.deleteBuffer();