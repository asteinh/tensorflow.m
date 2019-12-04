function test_suite = test_Operation()
  test_functions = localfunctions();
  initTestSuite;

  function test_constructors()
    o = tensorflow.Operation();

    assertExceptionThrown(@() tensorflow.Operation('too', 'many', 'args'), 'tensorflow:Operation:InputArguments');

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
    % assertTrue(isempty(oper.getControlInputs()));
    % numControlOutputs
    assertEqual(0, oper.numControlOutputs());
    % getControlOutputs
    % assertTrue(isempty(oper.getControlOutputs()));
    % getAttrString
    assertEqual(mtype, oper.getAttrString('message_type'));
    % getAttrStringList
    assertEqual(fnames, oper.getAttrStringList('field_names'));
    % getAttrTypeList
    % assertEqual(dtypes, oper.getAttrTypeList('Tinput_types'));
    % inputListLength
    assertEqual(oper.inputListLength('values'), numel(out_));

    %
    desc = g.newOperation('Abort', 'Abort_test');
    desc.setAttrBool('exit_without_error', true);
    oper = desc.finishOperation();

    % getAttrBool
    assertEqual(true, oper.getAttrBool('exit_without_error'));

    %
    desc = g.newOperation('MaxPool', 'MaxPool_test');
    ksize = int32([1 2 2 1]);
    desc.addInput(g.constant(rand([1 2 2 3])));
    desc.setAttrIntList('ksize', ksize);
    desc.setAttrIntList('strides', int32([1 1 1 1]));
    desc.setAttrString('padding', 'VALID');
    op = desc.finishOperation();

    % getAttrIntList
    assertEqual(ksize, int32(op.getAttrIntList('ksize')));

    %
    desc = g.newOperation('Pack', 'Pack_test');
    c(1) = g.constant(rand(3,3));
    c(2) = g.constant(eye(3));
    desc.addInputList(c);
    desc.setAttrInt('axis', int32(1));
    op = desc.finishOperation();

    % getAttrInt
    assertEqual(int64(1), op.getAttrInt('axis'));

    %
    desc = g.newOperation('ApproximateEqual', 'ApproximateEqual_test');
    desc.addInput(g.constant(0.9));
    desc.addInput(g.constant(1.1));
    tol = single(0.5);
    desc.setAttrFloat('tolerance', tol);
    op = desc.finishOperation();

    % getAttrFloat
    assertEqual(tol, op.getAttrFloat('tolerance'));

    %
    desc = g.newOperation('Bucketize', 'Bucketize_test');
    desc.addInput(g.constant(rand(1,10)));
    boundaries = single([0 .5 1]);
    desc.setAttrFloatList('boundaries',boundaries);
    op = desc.finishOperation();

    % getAttrFloatList
    assertEqual(boundaries, op.getAttrFloatList('boundaries'));

    %
    desc = g.newOperation('VariableV2', 'VariableV2_test');
    shape = [3 4 5];
    desc.setAttrShape('shape', shape);
    dtype = tensorflow.DataType('TF_UINT64');
    desc.setAttrType('dtype', dtype);
    op = desc.finishOperation();

    % getAttrType
    assertEqual(dtype, op.getAttrType('dtype'));
    % getAttrShape
    assertEqual(shape, op.getAttrShape('shape'));

    %
    desc = g.newOperation('Const', 'Const_test');
    t = tensorflow.Tensor(rand(10));
    desc.setAttrTensor('value', t);
    desc.setAttrType('dtype', 'TF_DOUBLE');
    op = desc.finishOperation();

    % getAttrTensor
    t_ = op.getAttrTensor('value');
    assertEqual(t.value, t_.value);

    % % missing:
    % getAttrBoolList
    % getAttrShapeList
    % getAttrTensorList
