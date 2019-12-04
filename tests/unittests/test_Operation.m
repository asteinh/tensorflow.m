function test_suite = test_Operation()
  test_functions = localfunctions();
  initTestSuite;

function test_interface()
  % Testing interface of Operation and OperationDescription
  g = tensorflow.Graph();

  opname = 'EncodeProto_test';
  optype = 'EncodeProto';

  % constructor OperationDescription
  desc = g.newOperation(optype, opname);

  desc.addInput(g.constant(int32(1)));

  out_(1) = g.constant(rand(5,5));
  out_(2) = g.constant(int64(randi([-10, 10],[5 5])));
  desc.addInputList(out_);

  mtype = 'nan';
  desc.setAttrString('message_type', mtype);

  fnames = { 'field1', 'field2', 'field3' }';
  desc.setAttrStringList('field_names', fnames);

  dtypes(1) = out_(1).type;
  dtypes(2) = out_(2).type;
  desc.setAttrTypeList('Tinput_types', dtypes);

  % (implicit) constructor Operation
  oper = desc.finishOperation();

  % name
  assertEqual(opname, oper.name());
  % opType
  assertEqual(optype, oper.opType());
  % device
  assertTrue(isempty(oper.device));
  % numOutputs
  assertEqual(1, oper.numOutputs());
  % numInputs
  assertEqual(3, oper.numInputs());
  % numControlInputs
  assertEqual(0, oper.numControlInputs());
  % getControlInputs
%       assertTrue(isempty(oper.getControlInputs()));
  % numControlOutputs
  assertEqual(0, oper.numControlOutputs());
  % getControlOutputs
%       assertTrue(isempty(oper.getControlOutputs()));
  % getAttrString
  assertEqual(mtype, oper.getAttrString('message_type'));
  % getAttrStringList
  assertEqual(fnames, oper.getAttrStringList('field_names'));
  % getAttrTypeList
  % assertEqual(dtypes, oper.getAttrTypeList('Tinput_types'));
