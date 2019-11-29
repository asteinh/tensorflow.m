classdef Operation < matlab.unittest.TestCase
  methods (Test)
    function interface(test)
      % Testing interface of Operation and OperationDescription
      g = tensorflow.Graph();

      opname = 'EncodeProto_test';
      optype = 'EncodeProto';
      
      % constructor OperationDescription
      desc = g.newOperation(optype, opname);

      desc.addInput(g.constant(int32(1)));

      o1 = g.constant(rand(5,5));
      o2 = g.constant(int64(randi([-10, 10],[5 5])));
      desc.addInputList([o1, o2]);

      mtype = 'nan';
      desc.setAttrString('message_type', mtype);

      fnames = { 'field1', 'field2', 'field3' }';
      desc.setAttrStringList('field_names', fnames);

      dtypes = [o1.type o2.type];
      desc.setAttrTypeList('Tinput_types', dtypes);

      % (implicit) constructor Operation
      oper = desc.finishOperation();

      % name
      test.verifyEqual(opname, oper.name());
      % opType
      test.verifyEqual(optype, oper.opType());
      % device
      test.verifyEmpty(oper.device);
      % numOutputs
      test.verifyEqual(1, oper.numOutputs());
      % numInputs
      test.verifyEqual(3, oper.numInputs());
      % numControlInputs
      test.verifyEqual(0, oper.numControlInputs());
      % getControlInputs
%       test.verifyEmpty(oper.getControlInputs());
      % numControlOutputs
      test.verifyEqual(0, oper.numControlOutputs());
      % getControlOutputs
%       test.verifyEmpty(oper.getControlOutputs());
      % getAttrString
      test.verifyEqual(mtype, oper.getAttrString('message_type'));
      % getAttrStringList
      test.verifyEqual(fnames, oper.getAttrStringList('field_names'));
      % getAttrTypeList
      test.verifyEqual(dtypes, oper.getAttrTypeList('Tinput_types'));
    end
  end
end
