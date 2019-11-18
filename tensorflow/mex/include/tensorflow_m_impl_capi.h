#ifndef TENSORFLOW_M_IMPL_CAPI_H
#define TENSORFLOW_M_IMPL_CAPI_H

#include "tensorflow_m_api.h"

// TF_CAPI_EXPORT extern const char* TF_Version(void);
static void TF_Version_(MEX_ARGS) {
  plhs[0] = mxCreateString(TF_Version());
}

// TF_CAPI_EXPORT extern size_t TF_DataTypeSize(TF_DataType dt);
static void TF_DataTypeSize_(MEX_ARGS) {
  TF_DataType dt = *((TF_DataType*) arr2ptr(prhs[0]));
  plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
  *((int*) mxGetData(plhs[0])) = (int) TF_DataTypeSize(dt);
}

// TF_CAPI_EXPORT extern TF_Status* TF_NewStatus(void);
static void TF_NewStatus_(MEX_ARGS) {
  TF_Status* status = TF_NewStatus();
  plhs[0] = ptr2arr((void*) status);
}

// TF_CAPI_EXPORT extern void TF_DeleteStatus(TF_Status*);
static void TF_DeleteStatus_(MEX_ARGS) {
  TF_Status* status = (TF_Status*) arr2ptr(prhs[0]);
  TF_DeleteStatus(status);
  destroy(status);
}

// TF_CAPI_EXPORT extern void TF_SetStatus(TF_Status* s, TF_Code code, const char* msg);
static void TF_SetStatus_(MEX_ARGS) {
  TF_Status* status = (TF_Status*) arr2ptr(prhs[0]);
  TF_Code code = *((TF_Code*) mxGetData(prhs[1]));
  char* msg = mxArrayToString(prhs[2]);
  if(!msg)
    mexErrMsgTxt("Could not transform given argument to string.\n");

  TF_SetStatus(status, code, msg);
  mxFree(msg);
}

// TF_CAPI_EXPORT extern TF_Code TF_GetCode(const TF_Status* s);
static void TF_GetCode_(MEX_ARGS) {
  TF_Status* status = (TF_Status*) arr2ptr(prhs[0]);
  plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT32_CLASS, mxREAL);
  *((TF_Code*) mxGetData(plhs[0])) = TF_GetCode(status);
}

// TF_CAPI_EXPORT extern const char* TF_Message(const TF_Status* s);
static void TF_Message_(MEX_ARGS) {
  TF_Status* status = (TF_Status*) arr2ptr(prhs[0]);
  plhs[0] = mxCreateString(TF_Message(status));
}

// TF_CAPI_EXPORT extern TF_Buffer* TF_NewBufferFromString(const void* proto, size_t proto_len);
static void TF_NewBufferFromString_(MEX_ARGS) {
  void* proto = (void*) mxGetData(prhs[0]);
  if(mxGetM(prhs[0]) > 1)
    mexErrMsgTxt("String must be supplied as a single-row, char array.");
  size_t proto_len = (size_t) mxGetN(prhs[0]);
  TF_Buffer* buffer = TF_NewBuffer();
  buffer->data = NULL;
  buffer->length = 0;
  buffer->data_deallocator = free_buffer;
  bytes_to_buffer(proto, proto_len, buffer);
  plhs[0] = ptr2arr((void*) buffer);
}

// TF_CAPI_EXPORT extern TF_Buffer* TF_NewBuffer(void);
static void TF_NewBuffer_(MEX_ARGS) {
  TF_Buffer* buffer = TF_NewBuffer();
  buffer->data = NULL;
  buffer->length = 0;
  buffer->data_deallocator = free_buffer;
  plhs[0] = ptr2arr((void*) buffer);
}

// TF_CAPI_EXPORT extern void  Buffer(TF_Buffer*);
static void TF_DeleteBuffer_(MEX_ARGS) {
  TF_Buffer* buffer = (TF_Buffer*) arr2ptr(prhs[0]);
  TF_DeleteBuffer(buffer);  // automatically frees buffer->data via buffer->data_deallocator
  destroy(buffer);
}

// TF_CAPI_EXPORT extern TF_Buffer TF_GetBuffer(TF_Buffer* buffer);
static void TF_GetBuffer_(MEX_ARGS) {
  NOT_SUPPORTED
}

// TF_CAPI_EXPORT extern TF_Tensor* TF_NewTensor( TF_DataType, const int64_t* dims, int num_dims, void* data, size_t len, void (*deallocator)(void* data, size_t len, void* arg), void* deallocator_arg);
static void TF_NewTensor_(MEX_ARGS) {
  NOT_SUPPORTED
}

// TF_CAPI_EXPORT extern TF_Tensor* TF_AllocateTensor(TF_DataType, const int64_t* dims, int num_dims, size_t len);
static void TF_AllocateTensor_(MEX_ARGS) {
  TF_DataType type = *(TF_DataType*) mxGetData(prhs[0]);
  int64_t* dims = (int64_t*) mxGetData(prhs[1]);
  int num_dims = *(int*) mxGetData(prhs[2]);
  size_t len = 1;
  for(int d = 0; d < num_dims; d++)
    len *= dims[d];
  len *= TF_DataTypeSize(type);
  TF_Tensor* tensor = TF_AllocateTensor(type, dims, num_dims, len);
  plhs[0] = ptr2arr((void*) tensor);
}

// TF_CAPI_EXPORT extern TF_Tensor* TF_TensorMaybeMove(TF_Tensor* tensor);
static void TF_TensorMaybeMove_(MEX_ARGS) {
  NOT_SUPPORTED
}

// TF_CAPI_EXPORT extern void TF_DeleteTensor(TF_Tensor*);
static void TF_DeleteTensor_(MEX_ARGS) {
  TF_Tensor* tensor = (TF_Tensor*) arr2ptr(prhs[0]);
  TF_DeleteTensor(tensor);
  destroy(tensor);
}

// TF_CAPI_EXPORT extern TF_DataType TF_TensorType(const TF_Tensor*);
static void TF_TensorType_(MEX_ARGS) {
  TF_Tensor* tensor = (TF_Tensor*) arr2ptr(prhs[0]);
  plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT32_CLASS, mxREAL);
  *((TF_DataType*) mxGetData(plhs[0])) = TF_TensorType(tensor);
}

// TF_CAPI_EXPORT extern int TF_NumDims(const TF_Tensor*);
static void TF_NumDims_(MEX_ARGS) {
  TF_Tensor* tensor = (TF_Tensor*) arr2ptr(prhs[0]);
  plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
  *((int*) mxGetData(plhs[0])) = TF_NumDims(tensor);
}

// TF_CAPI_EXPORT extern int64_t TF_Dim(const TF_Tensor* tensor, int dim_index);
static void TF_Dim_(MEX_ARGS) {
  TF_Tensor* tensor = (TF_Tensor*) arr2ptr(prhs[0]);
  int dim_index = *(int*) mxGetData(prhs[1]);
  plhs[0] = mxCreateNumericMatrix(1, 1, mxINT64_CLASS, mxREAL);
  *((int64_t*) mxGetData(plhs[0])) = TF_Dim(tensor, dim_index);
}

// TF_CAPI_EXPORT extern size_t TF_TensorByteSize(const TF_Tensor*);
static void TF_TensorByteSize_(MEX_ARGS) {
  TF_Tensor* tensor = (TF_Tensor*) arr2ptr(prhs[0]);
  plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
  *((int*) mxGetData(plhs[0])) = TF_TensorByteSize(tensor);
}

// TF_CAPI_EXPORT extern void* TF_TensorData(const TF_Tensor*);
static void TF_TensorData_(MEX_ARGS) {
  TF_Tensor* tensor = (TF_Tensor*) arr2ptr(prhs[0]);

  // a simple wrapper; NOT owning the data, but referring to it
  TF_Buffer* buffer = TF_NewBuffer();
  buffer->data = TF_TensorData(tensor);
  buffer->length = TF_TensorByteSize(tensor);
  buffer->data_deallocator = NULL;
  plhs[0] = ptr2arr((void*) buffer);
}

// TF_CAPI_EXPORT extern int64_t TF_TensorElementCount(const TF_Tensor* tensor);
static void TF_TensorElementCount_(MEX_ARGS) {
  TF_Tensor* tensor = (TF_Tensor*) arr2ptr(prhs[0]);
  plhs[0] = mxCreateNumericMatrix(1, 1, mxINT64_CLASS, mxREAL);
  *((int64_t*) mxGetData(plhs[0])) = TF_TensorElementCount(tensor);
}

// TF_CAPI_EXPORT extern void TF_TensorBitcastFrom(const TF_Tensor* from, TF_DataType type, TF_Tensor* to, const int64_t* new_dims, int num_new_dims, TF_Status* status);
static void TF_TensorBitcastFrom_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern size_t TF_StringEncode(const char* src, size_t src_len, char* dst, size_t dst_len, TF_Status* status);
static void TF_StringEncode_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern size_t TF_StringDecode(const char* src, size_t src_len, const char** dst, size_t* dst_len, TF_Status* status);
static void TF_StringDecode_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern size_t TF_StringEncodedSize(size_t len);
static void TF_StringEncodedSize_(MEX_ARGS) {
  size_t len = *((size_t*) mxGetData(prhs[0]));
  plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
  *((int*) mxGetData(plhs[0])) = TF_StringEncodedSize(len);
}

// TF_CAPI_EXPORT extern TF_SessionOptions* TF_NewSessionOptions(void);
static void TF_NewSessionOptions_(MEX_ARGS) {
  TF_SessionOptions* opts = TF_NewSessionOptions();
  plhs[0] = ptr2arr((void*) opts);
}

// TF_CAPI_EXPORT extern void TF_SetTarget(TF_SessionOptions* options, const char* target);
static void TF_SetTarget_(MEX_ARGS) {
  NOT_TESTED

  TF_SessionOptions* opts = (TF_SessionOptions*) arr2ptr(prhs[0]);
  char* target = mxArrayToString(prhs[1]);
  if(!target)
    mexErrMsgTxt("Could not transform given argument to string.\n");

  TF_SetTarget(opts, target);
  mxFree(target);
}

// TF_CAPI_EXPORT extern void TF_SetConfig(TF_SessionOptions* options, const void* proto, size_t proto_len, TF_Status* status);
static void TF_SetConfig_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_DeleteSessionOptions(TF_SessionOptions*);
static void TF_DeleteSessionOptions_(MEX_ARGS) {
  TF_SessionOptions* opts = (TF_SessionOptions*) arr2ptr(prhs[0]);
  TF_DeleteSessionOptions(opts);
  destroy(opts);
}

// TF_CAPI_EXPORT extern TF_Graph* TF_NewGraph(void);
static void TF_NewGraph_(MEX_ARGS) {
  TF_Graph* graph = TF_NewGraph();
  plhs[0] = ptr2arr((void*) graph);
}

// TF_CAPI_EXPORT extern void TF_DeleteGraph(TF_Graph*);
static void TF_DeleteGraph_(MEX_ARGS) {
  TF_Graph* graph = (TF_Graph*) arr2ptr(prhs[0]);
  TF_DeleteGraph(graph);
  destroy(graph);
}

// TF_CAPI_EXPORT extern void TF_GraphSetTensorShape(TF_Graph* graph, TF_Output output, const int64_t* dims, const int num_dims, TF_Status* status);
static void TF_GraphSetTensorShape_(MEX_ARGS) {
  TF_Graph* graph = (TF_Graph*) arr2ptr(prhs[0]);
  TF_Output output = *((TF_Output*) arr2ptr(prhs[1]));
  int64_t* dims = (int64_t*) mxGetData(prhs[2]);
  int num_dims = *((int*) mxGetData(prhs[3]));
  TF_Status* status = (TF_Status*) arr2ptr(prhs[4]);
  TF_GraphSetTensorShape(graph, output, dims, num_dims, status);
}

// TF_CAPI_EXPORT extern int TF_GraphGetTensorNumDims(TF_Graph* graph, TF_Output output, TF_Status* status);
static void TF_GraphGetTensorNumDims_(MEX_ARGS) {
  TF_Graph* graph = (TF_Graph*) arr2ptr(prhs[0]);
  TF_Output output = *((TF_Output*) arr2ptr(prhs[1]));
  TF_Status* status = (TF_Status*) arr2ptr(prhs[2]);
  plhs[0] = mxCreateNumericMatrix(1, 1, mxINT64_CLASS, mxREAL);
  *((int64_t*) mxGetData(plhs[0])) = TF_GraphGetTensorNumDims(graph, output, status);
}

// TF_CAPI_EXPORT extern void TF_GraphGetTensorShape(TF_Graph* graph, TF_Output output, int64_t* dims, int num_dims, TF_Status* status);
static void TF_GraphGetTensorShape_(MEX_ARGS) {
  // mexErrMsgTxt("Check implementation!");
  TF_Graph* graph = (TF_Graph*) arr2ptr(prhs[0]);
  TF_Output output = *((TF_Output*) arr2ptr(prhs[1]));
  TF_Status* status = (TF_Status*) arr2ptr(prhs[2]);
  int64_t num_dims = TF_GraphGetTensorNumDims(graph, output, status);

  int64_t* dims = (int64_t*) mxCalloc(num_dims, sizeof(int64_t));
  if(!dims)
    mexErrMsgTxt("Allocation of memory for dimension array failed.\n");

  TF_GraphGetTensorShape(graph, output, dims, num_dims, status);

  plhs[0] = mxCreateNumericMatrix(1, num_dims, mxDOUBLE_CLASS, mxREAL);
  double* y = (double*) mxGetData(plhs[0]);
  for(int i = 0; i < num_dims; i++)
    y[i] = (double) dims[i];

  mxFree(dims);
}

// TF_CAPI_EXPORT extern TF_OperationDescription* TF_NewOperation(TF_Graph* graph, const char* op_type, const char* oper_name);
static void TF_NewOperation_(MEX_ARGS) {
  TF_Graph* graph = (TF_Graph*) arr2ptr(prhs[0]);
  char* op_type = mxArrayToString(prhs[1]);
  char* oper_name = mxArrayToString(prhs[2]);
  if(!op_type || !oper_name)
    mexErrMsgTxt("Could not transform given argument to string.\n");

  TF_OperationDescription* desc = TF_NewOperation(graph, op_type, oper_name);
  plhs[0] = ptr2arr((void*) desc);
  mxFree(op_type);
  mxFree(oper_name);
}

// TF_CAPI_EXPORT extern void TF_SetDevice(TF_OperationDescription* desc, const char* device);
static void TF_SetDevice_(MEX_ARGS) {
  NOT_TESTED

  TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[0]);
  char* device = mxArrayToString(prhs[1]);
  if(!device)
    mexErrMsgTxt("Could not transform given argument to string.\n");

  TF_SetDevice(desc, device);
  mxFree(device);
}

// TF_CAPI_EXPORT extern void TF_AddInput(TF_OperationDescription* desc, TF_Output input);
static void TF_AddInput_(MEX_ARGS) {
  TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[0]);
  TF_Output input = *((TF_Output*) arr2ptr(prhs[1]));
  TF_AddInput(desc, input);
}

// TF_CAPI_EXPORT extern void TF_AddInputList(TF_OperationDescription* desc, const TF_Output* inputs, int num_inputs);
static void TF_AddInputList_(MEX_ARGS) {
  NOT_TESTED

  TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[0]);
  TF_Output* inputs = (TF_Output*) arr2ptr(prhs[1]);
  int num_inputs = *((int*) mxGetData(prhs[2]));
  TF_AddInputList(desc, inputs, num_inputs);
}

// TF_CAPI_EXPORT extern void TF_AddControlInput(TF_OperationDescription* desc, TF_Operation* input);
static void TF_AddControlInput_(MEX_ARGS) {
  NOT_TESTED

  TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[0]);
  TF_Operation* input = (TF_Operation*) arr2ptr(prhs[1]);
  TF_AddControlInput(desc, input);
}

// TF_CAPI_EXPORT extern void TF_ColocateWith(TF_OperationDescription* desc, TF_Operation* op);
static void TF_ColocateWith_(MEX_ARGS) {
  NOT_TESTED

  TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[0]);
  TF_Operation* op = (TF_Operation*) arr2ptr(prhs[1]);
  TF_ColocateWith(desc, op);
}

// TF_CAPI_EXPORT extern void TF_SetAttrString(TF_OperationDescription* desc, const char* attr_name, const void* value, size_t length);
static void TF_SetAttrString_(MEX_ARGS) {
  NOT_TESTED

  TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[0]);
  char* attr_name = mxArrayToString(prhs[1]);
  if(!attr_name)
    mexErrMsgTxt("Could not transform given argument to string.\n");

  void* value = (void*) mxGetData(prhs[2]);
  size_t length = (size_t) mxGetN(prhs[2]);
  TF_SetAttrString(desc, attr_name, value, length*sizeof(char));
  mxFree(attr_name);
}

// TF_CAPI_EXPORT extern void TF_SetAttrStringList(TF_OperationDescription* desc, const char* attr_name, const void* const* values, const size_t* lengths, int num_values);
static void TF_SetAttrStringList_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_SetAttrInt(TF_OperationDescription* desc, const char* attr_name, int64_t value);
static void TF_SetAttrInt_(MEX_ARGS) {
  NOT_TESTED

  TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[0]);
  char* attr_name = mxArrayToString(prhs[1]);
  if(!attr_name)
    mexErrMsgTxt("Could not transform given argument to string.\n");

  int64_t value = *((int64_t*) mxGetData(prhs[2]));
  TF_SetAttrInt(desc, attr_name, value);
  mxFree(attr_name);
}

// TF_CAPI_EXPORT extern void TF_SetAttrIntList(TF_OperationDescription* desc, const char* attr_name, const int64_t* values, int num_values);
static void TF_SetAttrIntList_(MEX_ARGS) {
  NOT_TESTED

  TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[0]);
  char* attr_name = mxArrayToString(prhs[1]);
  if(!attr_name)
    mexErrMsgTxt("Could not transform given argument to string.\n");

  int64_t* values = (int64_t*) mxGetData(prhs[2]);
  int num_values = *((int*) mxGetData(prhs[3]));
  TF_SetAttrIntList(desc, attr_name, values, num_values);
  mxFree(attr_name);
}

// TF_CAPI_EXPORT extern void TF_SetAttrFloat(TF_OperationDescription* desc, const char* attr_name, float value);
static void TF_SetAttrFloat_(MEX_ARGS) {
  NOT_TESTED

  TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[0]);
  char* attr_name = mxArrayToString(prhs[1]);
  if(!attr_name)
    mexErrMsgTxt("Could not transform given argument to string.\n");

  float value = *((float*) mxGetData(prhs[2]));
  TF_SetAttrFloat(desc, attr_name, value);
  mxFree(attr_name);
}

// TF_CAPI_EXPORT extern void TF_SetAttrFloatList(TF_OperationDescription* desc, const char* attr_name, const float* values, int num_values);
static void TF_SetAttrFloatList_(MEX_ARGS) {
  NOT_TESTED

  TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[0]);
  char* attr_name = mxArrayToString(prhs[1]);
  if(!attr_name)
    mexErrMsgTxt("Could not transform given argument to string.\n");

  float* values = (float*) mxGetData(prhs[2]);
  int num_values = *((int*) mxGetData(prhs[3]));
  TF_SetAttrFloatList(desc, attr_name, values, num_values);
  mxFree(attr_name);
}

// TF_CAPI_EXPORT extern void TF_SetAttrBool(TF_OperationDescription* desc, const char* attr_name, unsigned char value);
static void TF_SetAttrBool_(MEX_ARGS) {
  NOT_TESTED

  TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[0]);
  char* attr_name = mxArrayToString(prhs[1]);
  if(!attr_name)
    mexErrMsgTxt("Could not transform given argument to string.\n");

  unsigned char value = *((unsigned char*) mxGetData(prhs[2]));
  TF_SetAttrBool(desc, attr_name, value);
  mxFree(attr_name);
}

// TF_CAPI_EXPORT extern void TF_SetAttrBoolList(TF_OperationDescription* desc, const char* attr_name, const unsigned char* values,int num_values);
static void TF_SetAttrBoolList_(MEX_ARGS) {
  NOT_TESTED

  TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[0]);
  char* attr_name = mxArrayToString(prhs[1]);
  if(!attr_name)
    mexErrMsgTxt("Could not transform given argument to string.\n");

  unsigned char* values = (unsigned char*) mxGetData(prhs[2]);
  int num_values = *((int*) mxGetData(prhs[3]));
  TF_SetAttrBoolList(desc, attr_name, values, num_values);
  mxFree(attr_name);
}

// TF_CAPI_EXPORT extern void TF_SetAttrType(TF_OperationDescription* desc, const char* attr_name, TF_DataType value);
static void TF_SetAttrType_(MEX_ARGS) {
  TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[0]);
  char* attr_name = mxArrayToString(prhs[1]);
  if(!attr_name)
    mexErrMsgTxt("Could not transform given argument to string.\n");

  TF_DataType value = *((TF_DataType*) mxGetData(prhs[2]));
  TF_SetAttrType(desc, attr_name, value);
  mxFree(attr_name);
}

// TF_CAPI_EXPORT extern void TF_SetAttrTypeList(TF_OperationDescription* desc, const char* attr_name, const TF_DataType* values, int num_values);
static void TF_SetAttrTypeList_(MEX_ARGS) {
  NOT_TESTED

  TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[0]);
  char* attr_name = mxArrayToString(prhs[1]);
  if(!attr_name)
    mexErrMsgTxt("Could not transform given argument to string.\n");

  TF_DataType* values = (TF_DataType*) mxGetData(prhs[2]);
  int num_values = *((int*) mxGetData(prhs[3]));
  TF_SetAttrTypeList(desc, attr_name, values, num_values);
  mxFree(attr_name);
}

// TF_CAPI_EXPORT extern void TF_SetAttrPlaceholder(TF_OperationDescription* desc, const char* attr_name, const char* placeholder);
static void TF_SetAttrPlaceholder_(MEX_ARGS) {
  NOT_TESTED

  TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[0]);
  char* attr_name = mxArrayToString(prhs[1]);
  char* placeholder = mxArrayToString(prhs[2]);
  if(!attr_name || !placeholder)
    mexErrMsgTxt("Could not transform given argument to string.\n");

  TF_SetAttrPlaceholder(desc, attr_name, placeholder);
  mxFree(attr_name);
  mxFree(placeholder);
}

// TF_CAPI_EXPORT extern void TF_SetAttrFuncName(TF_OperationDescription* desc, const char* attr_name, const char* value, size_t length);
static void TF_SetAttrFuncName_(MEX_ARGS) {
  // identical to TF_SetAttrString

  NOT_TESTED

  TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[0]);
  char* attr_name = mxArrayToString(prhs[1]);
  if(!attr_name)
    mexErrMsgTxt("Could not transform given argument to string.\n");

  void* value = (void*) mxGetData(prhs[2]);
  size_t length = (size_t) mxGetN(prhs[2]);
  TF_SetAttrFuncName(desc, attr_name, value, length*sizeof(char));
  mxFree(attr_name);
}

// TF_CAPI_EXPORT extern void TF_SetAttrShape(TF_OperationDescription* desc, const char* attr_name, const int64_t* dims, int num_dims);
static void TF_SetAttrShape_(MEX_ARGS) {
  TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[0]);
  char* attr_name = mxArrayToString(prhs[1]);
  if(!attr_name)
    mexErrMsgTxt("Could not transform given argument to string.\n");

  int64_t* dims = (int64_t*) mxGetData(prhs[2]);
  int num_dims = *((int*) mxGetData(prhs[3]));
  TF_SetAttrShape(desc, attr_name, dims, num_dims);
  mxFree(attr_name);
}

// TF_CAPI_EXPORT extern void TF_SetAttrShapeList(TF_OperationDescription* desc, const char* attr_name, const int64_t* const* dims, const int* num_dims, int num_shapes);
static void TF_SetAttrShapeList_(MEX_ARGS) {
  NOT_TESTED

  TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[0]);
  char* attr_name = mxArrayToString(prhs[1]);
  if(!attr_name)
    mexErrMsgTxt("Could not transform given argument to string.\n");

  const int64_t* const* dims = (const int64_t* const*) mxGetData(prhs[2]);
  int* num_dims = (int*) mxGetData(prhs[3]);
  int num_shapes = *((int*) mxGetData(prhs[4]));
  TF_SetAttrShapeList(desc, attr_name, dims, num_dims, num_shapes);
  mxFree(attr_name);
}

// TF_CAPI_EXPORT extern void TF_SetAttrTensorShapeProto(TF_OperationDescription* desc, const char* attr_name, const void* proto, size_t proto_len, TF_Status* status);
static void TF_SetAttrTensorShapeProto_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_SetAttrTensorShapeProtoList(TF_OperationDescription* desc, const char* attr_name, const void* const* protos, const size_t* proto_lens, int num_shapes, TF_Status* status);
static void TF_SetAttrTensorShapeProtoList_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_SetAttrTensor(TF_OperationDescription* desc, const char* attr_name, TF_Tensor* value, TF_Status* status);
static void TF_SetAttrTensor_(MEX_ARGS) {
  TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[0]);
  char* attr_name = mxArrayToString(prhs[1]);
  if(!attr_name)
    mexErrMsgTxt("Could not transform given argument to string.\n");

  TF_Tensor* value = (TF_Tensor*) arr2ptr(prhs[2]);
  TF_Status* status = (TF_Status*) arr2ptr(prhs[3]);
  TF_SetAttrTensor(desc, attr_name, value, status);
  mxFree(attr_name);
}

// TF_CAPI_EXPORT extern void TF_SetAttrTensorList(TF_OperationDescription* desc, const char* attr_name, TF_Tensor* const* values, int num_values, TF_Status* status);
static void TF_SetAttrTensorList_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_SetAttrValueProto(TF_OperationDescription* desc, const char* attr_name, const void* proto, size_t proto_len, TF_Status* status);
static void TF_SetAttrValueProto_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern TF_Operation* TF_FinishOperation(TF_OperationDescription* desc, TF_Status* status);
static void TF_FinishOperation_(MEX_ARGS) {
  TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[0]);
  TF_Status* status = (TF_Status*) arr2ptr(prhs[1]);
  TF_Operation* oper = TF_FinishOperation(desc, status);
  plhs[0] = ptr2arr((void*) oper);
}

// TF_CAPI_EXPORT extern const char* TF_OperationName(TF_Operation* oper);
static void TF_OperationName_(MEX_ARGS) {
  NOT_TESTED

  TF_Operation* oper = (TF_Operation*) arr2ptr(prhs[0]);
  plhs[0] = mxCreateString(TF_OperationName(oper));
}

// TF_CAPI_EXPORT extern const char* TF_OperationOpType(TF_Operation* oper);
static void TF_OperationOpType_(MEX_ARGS) {
  NOT_TESTED

  TF_Operation* oper = (TF_Operation*) arr2ptr(prhs[0]);
  plhs[0] = mxCreateString(TF_OperationOpType(oper));
}

// TF_CAPI_EXPORT extern const char* TF_OperationDevice(TF_Operation* oper);
static void TF_OperationDevice_(MEX_ARGS) {
  NOT_TESTED

  TF_Operation* oper = (TF_Operation*) arr2ptr(prhs[0]);
  plhs[0] = mxCreateString(TF_OperationDevice(oper));
}

// TF_CAPI_EXPORT extern int TF_OperationNumOutputs(TF_Operation* oper);
static void TF_OperationNumOutputs_(MEX_ARGS) {
  NOT_TESTED

  TF_Operation* oper = (TF_Operation*) arr2ptr(prhs[0]);
  plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
  *((int*) mxGetData(plhs[0])) = TF_OperationNumOutputs(oper);
}

// TF_CAPI_EXPORT extern TF_DataType TF_OperationOutputType(TF_Output oper_out);
static void TF_OperationOutputType_(MEX_ARGS) {
  TF_Output output = *((TF_Output*) arr2ptr(prhs[0]));
  TF_DataType dtype = TF_OperationOutputType(output);
  plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT32_CLASS, mxREAL);
  *((TF_DataType*) mxGetData(plhs[0])) = dtype;
}

// TF_CAPI_EXPORT extern int TF_OperationOutputListLength(TF_Operation* oper, const char* arg_name, TF_Status* status);
static void TF_OperationOutputListLength_(MEX_ARGS) {
  NOT_TESTED

  TF_Operation* oper = (TF_Operation*) arr2ptr(prhs[0]);
  char* arg_name = mxArrayToString(prhs[1]);
  if(!attr_name)
    mexErrMsgTxt("Could not transform given argument to string.\n");

  TF_Status* status = (TF_Status*) arr2ptr(prhs[2]);
  plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
  *((int*) mxGetData(plhs[0])) = TF_OperationOutputListLength(oper, arg_name, status);
  mxFree(arg_name);
}

// TF_CAPI_EXPORT extern int TF_OperationNumInputs(TF_Operation* oper);
static void TF_OperationNumInputs_(MEX_ARGS) {
  NOT_TESTED

  TF_Operation* oper = (TF_Operation*) arr2ptr(prhs[0]);
  plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
  *((int*) mxGetData(plhs[0])) = TF_OperationNumInputs(oper);
}

// TF_CAPI_EXPORT extern TF_DataType TF_OperationInputType(TF_Input oper_in);
static void TF_OperationInputType_(MEX_ARGS) {
  NOT_TESTED

  TF_Input input = *((TF_Input*) arr2ptr(prhs[0]));
  TF_DataType dtype = TF_OperationInputType(input);
  plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT32_CLASS, mxREAL);
  *((TF_DataType*) mxGetData(plhs[0])) = dtype;
}

// TF_CAPI_EXPORT extern int TF_OperationInputListLength(TF_Operation* oper, const char* arg_name, TF_Status* status);
static void TF_OperationInputListLength_(MEX_ARGS) {
  NOT_TESTED

  TF_Operation* oper = (TF_Operation*) arr2ptr(prhs[0]);
  char* arg_name = mxArrayToString(prhs[1]);
  if(!attr_name)
    mexErrMsgTxt("Could not transform given argument to string.\n");

  TF_Status* status = (TF_Status*) arr2ptr(prhs[2]);
  plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
  *((int*) mxGetData(plhs[0])) = TF_OperationInputListLength(oper, arg_name, status);
  mxFree(arg_name);
}

// TF_CAPI_EXPORT extern TF_Output TF_OperationInput(TF_Input oper_in);
static void TF_OperationInput_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern int TF_OperationOutputNumConsumers(TF_Output oper_out);
static void TF_OperationOutputNumConsumers_(MEX_ARGS) {
  NOT_TESTED

  TF_Output oper_out = *((TF_Output*) arr2ptr(prhs[0]));
  plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
  *((int*) mxGetData(plhs[0])) = TF_OperationOutputNumConsumers(oper_out);
}

// TF_CAPI_EXPORT extern int TF_OperationOutputConsumers(TF_Output oper_out, TF_Input* consumers, int max_consumers);
static void TF_OperationOutputConsumers_(MEX_ARGS) {
  NOT_TESTED

  TF_Output oper_out = *((TF_Output*) arr2ptr(prhs[0]));
  TF_Input* consumers = (TF_Input*) arr2ptr(prhs[1]);
  int max_consumers = *((int*) mxGetData(prhs[2]));
  plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
  *((int*) mxGetData(plhs[0])) = TF_OperationOutputConsumers(oper_out, consumers, max_consumers);
}

// TF_CAPI_EXPORT extern int TF_OperationNumControlInputs(TF_Operation* oper);
static void TF_OperationNumControlInputs_(MEX_ARGS) {
  TF_Operation* oper = (TF_Operation*) arr2ptr(prhs[0]);
  plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
  *((int*) mxGetData(plhs[0])) = TF_OperationNumControlInputs(oper);
}

// TF_CAPI_EXPORT extern int TF_OperationGetControlInputs(TF_Operation* oper, TF_Operation** control_inputs, int max_control_inputs);
static void TF_OperationGetControlInputs_(MEX_ARGS) {
  NOT_TESTED

  TF_Operation* oper = (TF_Operation*) arr2ptr(prhs[0]);
  TF_Operation** control_inputs = (TF_Operation**) arr2ptr(prhs[1]);
  int max_control_inputs = *((int*) mxGetData(prhs[2]));
  plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
  *((int*) mxGetData(plhs[0])) = TF_OperationGetControlInputs(oper, control_inputs, max_control_inputs);
}

// TF_CAPI_EXPORT extern int TF_OperationNumControlOutputs(TF_Operation* oper);
static void TF_OperationNumControlOutputs_(MEX_ARGS) {
  NOT_TESTED

  TF_Operation* oper = (TF_Operation*) arr2ptr(prhs[0]);
  plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
  *((int*) mxGetData(plhs[0])) = TF_OperationNumControlOutputs(oper);
}

// TF_CAPI_EXPORT extern int TF_OperationGetControlOutputs(TF_Operation* oper, TF_Operation** control_outputs, int max_control_outputs);
static void TF_OperationGetControlOutputs_(MEX_ARGS) {
  NOT_TESTED

  TF_Operation* oper = (TF_Operation*) arr2ptr(prhs[0]);
  TF_Operation** control_outputs = (TF_Operation**) arr2ptr(prhs[1]);
  int max_control_inputs = *((int*) mxGetData(prhs[2]));
  plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
  *((int*) mxGetData(plhs[0])) = TF_OperationGetControlOutputs(oper, control_outputs, max_control_inputs);
}

// TF_CAPI_EXPORT extern TF_AttrMetadata TF_OperationGetAttrMetadata(TF_Operation* oper, const char* attr_name, TF_Status* status);
static void TF_OperationGetAttrMetadata_(MEX_ARGS) {
  NOT_IMPLEMENTED
  // requires TF_AttrMetadata object in Matlab
}

// TF_CAPI_EXPORT extern void TF_OperationGetAttrString(TF_Operation* oper, const char* attr_name, void* value, size_t max_length, TF_Status* status);
static void TF_OperationGetAttrString_(MEX_ARGS) {
  NOT_IMPLEMENTED

  TF_Operation* oper = (TF_Operation*) arr2ptr(prhs[0]);
  char* attr_name = mxArrayToString(prhs[1]);
  TF_Status* status = (TF_Status*) arr2ptr(prhs[2]);

  TF_AttrMetadata meta = TF_OperationGetAttrMetadata(oper, attr_name, status);
  if(TF_GetCode(status) == TF_OK) {
    size_t max_length = meta.total_size;
    void* value = mxCalloc(max_length, sizeof(char));
    if(!value)
      mexErrMsgTxt("Allocation of memory for string failed.\n");

    TF_OperationGetAttrString(oper, attr_name, value, max_length, status);

    plhs[0] = mxCreateString(value);
    mxFree(value);
  }
}

// TF_CAPI_EXPORT extern void TF_OperationGetAttrStringList(TF_Operation* oper, const char* attr_name, void** values, size_t* lengths, int max_values, void* storage, size_t storage_size, TF_Status* status);
static void TF_OperationGetAttrStringList_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_OperationGetAttrInt(TF_Operation* oper, const char* attr_name, int64_t* value, TF_Status* status);
static void TF_OperationGetAttrInt_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_OperationGetAttrIntList(TF_Operation* oper, const char* attr_name, int64_t* values, int max_values, TF_Status* status);
static void TF_OperationGetAttrIntList_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_OperationGetAttrFloat(TF_Operation* oper, const char* attr_name, float* value, TF_Status* status);
static void TF_OperationGetAttrFloat_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_OperationGetAttrFloatList(TF_Operation* oper, const char* attr_name, float* values, int max_values, TF_Status* status);
static void TF_OperationGetAttrFloatList_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_OperationGetAttrBool(TF_Operation* oper, const char* attr_name, unsigned char* value, TF_Status* status);
static void TF_OperationGetAttrBool_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_OperationGetAttrBoolList(TF_Operation* oper, const char* attr_name, unsigned char* values, int max_values, TF_Status* status);
static void TF_OperationGetAttrBoolList_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_OperationGetAttrType(TF_Operation* oper, const char* attr_name, TF_DataType* value, TF_Status* status);
static void TF_OperationGetAttrType_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_OperationGetAttrTypeList(TF_Operation* oper, const char* attr_name, TF_DataType* values, int max_values, TF_Status* status);
static void TF_OperationGetAttrTypeList_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_OperationGetAttrShape(TF_Operation* oper, const char* attr_name, int64_t* value, int num_dims, TF_Status* status);
static void TF_OperationGetAttrShape_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_OperationGetAttrShapeList(TF_Operation* oper, const char* attr_name, int64_t** dims, int* num_dims, int num_shapes, int64_t* storage, int storage_size, TF_Status* status);
static void TF_OperationGetAttrShapeList_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_OperationGetAttrTensorShapeProto(TF_Operation* oper, const char* attr_name, TF_Buffer* value, TF_Status* status);
static void TF_OperationGetAttrTensorShapeProto_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_OperationGetAttrTensorShapeProtoList(TF_Operation* oper, const char* attr_name, TF_Buffer** values, int max_values, TF_Status* status);
static void TF_OperationGetAttrTensorShapeProtoList_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_OperationGetAttrTensor(TF_Operation* oper, const char* attr_name, TF_Tensor** value, TF_Status* status);
static void TF_OperationGetAttrTensor_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_OperationGetAttrTensorList(TF_Operation* oper, const char* attr_name, TF_Tensor** values, int max_values, TF_Status* status);
static void TF_OperationGetAttrTensorList_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_OperationGetAttrValueProto(TF_Operation* oper, const char* attr_name, TF_Buffer* output_attr_value, TF_Status* status);
static void TF_OperationGetAttrValueProto_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern TF_Operation* TF_GraphOperationByName(TF_Graph* graph, const char* oper_name);
static void TF_GraphOperationByName_(MEX_ARGS) {
  TF_Graph* graph = (TF_Graph*) arr2ptr(prhs[0]);
  char* oper_name = mxArrayToString(prhs[1]);
  if(!oper_name)
    mexErrMsgTxt("Could not transform given argument to string.\n");

  TF_Operation* oper = TF_GraphOperationByName(graph, oper_name);
  plhs[0] = ptr2arr((void*) oper);
  mxFree(oper_name);
}

// TF_CAPI_EXPORT extern TF_Operation* TF_GraphNextOperation(TF_Graph* graph, size_t* pos);
static void TF_GraphNextOperation_(MEX_ARGS) {
  TF_Graph* graph = (TF_Graph*) arr2ptr(prhs[0]);
  size_t* pos = (size_t*) mxGetData(prhs[1]);
  TF_Operation* oper = TF_GraphNextOperation(graph, pos);
  plhs[0] = ptr2arr((void*) oper);
}

// TF_CAPI_EXPORT extern void TF_GraphToGraphDef(TF_Graph* graph, TF_Buffer* output_graph_def, TF_Status* status);
static void TF_GraphToGraphDef_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_GraphGetOpDef(TF_Graph* graph, const char* op_name, TF_Buffer* output_op_def, TF_Status* status);
static void TF_GraphGetOpDef_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_GraphVersions(TF_Graph* graph, TF_Buffer* output_version_def, TF_Status* status);
static void TF_GraphVersions_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern TF_ImportGraphDefOptions* TF_NewImportGraphDefOptions(void);
static void TF_NewImportGraphDefOptions_(MEX_ARGS) {
  TF_ImportGraphDefOptions* opts = TF_NewImportGraphDefOptions();
  plhs[0] = ptr2arr((void*) opts);
}

// TF_CAPI_EXPORT extern void TF_DeleteImportGraphDefOptions(TF_ImportGraphDefOptions* opts);
static void TF_DeleteImportGraphDefOptions_(MEX_ARGS) {
  TF_ImportGraphDefOptions* opts = (TF_ImportGraphDefOptions*) arr2ptr(prhs[0]);
  TF_DeleteImportGraphDefOptions(opts);
  destroy(opts);
}

// TF_CAPI_EXPORT extern void TF_ImportGraphDefOptionsSetPrefix(TF_ImportGraphDefOptions* opts, const char* prefix);
static void TF_ImportGraphDefOptionsSetPrefix_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_ImportGraphDefOptionsSetDefaultDevice(TF_ImportGraphDefOptions* opts, const char* device);
static void TF_ImportGraphDefOptionsSetDefaultDevice_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_ImportGraphDefOptionsSetUniquifyNames(TF_ImportGraphDefOptions* opts, unsigned char uniquify_names);
static void TF_ImportGraphDefOptionsSetUniquifyNames_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_ImportGraphDefOptionsSetUniquifyPrefix(TF_ImportGraphDefOptions* opts, unsigned char uniquify_prefix);
static void TF_ImportGraphDefOptionsSetUniquifyPrefix_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_ImportGraphDefOptionsAddInputMapping(TF_ImportGraphDefOptions* opts, const char* src_name, int src_index, TF_Output dst);
static void TF_ImportGraphDefOptionsAddInputMapping_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_ImportGraphDefOptionsRemapControlDependency(TF_ImportGraphDefOptions* opts, const char* src_name, TF_Operation* dst);
static void TF_ImportGraphDefOptionsRemapControlDependency_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_ImportGraphDefOptionsAddControlDependency(TF_ImportGraphDefOptions* opts, TF_Operation* oper);
static void TF_ImportGraphDefOptionsAddControlDependency_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_ImportGraphDefOptionsAddReturnOutput(TF_ImportGraphDefOptions* opts, const char* oper_name, int index);
static void TF_ImportGraphDefOptionsAddReturnOutput_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern int TF_ImportGraphDefOptionsNumReturnOutputs(const TF_ImportGraphDefOptions* opts);
static void TF_ImportGraphDefOptionsNumReturnOutputs_(MEX_ARGS) {
  TF_ImportGraphDefOptions* opts = (TF_ImportGraphDefOptions*) arr2ptr(prhs[0]);
  plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
  *((int*) mxGetData(plhs[0])) = TF_ImportGraphDefOptionsNumReturnOutputs(opts);
}

// TF_CAPI_EXPORT extern void TF_ImportGraphDefOptionsAddReturnOperation(TF_ImportGraphDefOptions* opts, const char* oper_name);
static void TF_ImportGraphDefOptionsAddReturnOperation_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern int TF_ImportGraphDefOptionsNumReturnOperations(const TF_ImportGraphDefOptions* opts);
static void TF_ImportGraphDefOptionsNumReturnOperations_(MEX_ARGS) {
  TF_ImportGraphDefOptions* opts = (TF_ImportGraphDefOptions*) arr2ptr(prhs[0]);
  plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
  *((int*) mxGetData(plhs[0])) = TF_ImportGraphDefOptionsNumReturnOperations(opts);
}

// TF_CAPI_EXPORT extern void TF_ImportGraphDefResultsReturnOutputs(TF_ImportGraphDefResults* results, int* num_outputs, TF_Output** outputs);
static void TF_ImportGraphDefResultsReturnOutputs_(MEX_ARGS) {
  NOT_IMPLEMENTED

  // TF_ImportGraphDefResults* results = (TF_ImportGraphDefResults*) arr2ptr(prhs[0]);
  // int* num_outputs;
  // TF_Output** outputs;
  // TF_ImportGraphDefResultsReturnOutputs(results, num_outputs, outputs);
  //
  // plhs[0] = mxCreateNumericMatrix(1, num_outputs, mxUINT64_CLASS, mxREAL);
  // uint64_t* y = (uint64_t*) mxGetData(plhs[0]);
  // for(int i = 0; i < *num_outputs; i++)
  //   y[i] = (uint64_t) (outputs[i]);
}

// TF_CAPI_EXPORT extern void TF_ImportGraphDefResultsReturnOperations(TF_ImportGraphDefResults* results, int* num_opers, TF_Operation*** opers);
static void TF_ImportGraphDefResultsReturnOperations_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_ImportGraphDefResultsMissingUnusedInputMappings(TF_ImportGraphDefResults* results, int* num_missing_unused_input_mappings, const char*** src_names, int** src_indexes);
static void TF_ImportGraphDefResultsMissingUnusedInputMappings_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_DeleteImportGraphDefResults(TF_ImportGraphDefResults* results);
static void TF_DeleteImportGraphDefResults_(MEX_ARGS) {
  TF_ImportGraphDefResults* results = (TF_ImportGraphDefResults*) arr2ptr(prhs[0]);
  TF_DeleteImportGraphDefResults(results);
  destroy(results);
}

// TF_CAPI_EXPORT extern TF_ImportGraphDefResults* TF_GraphImportGraphDefWithResults(TF_Graph* graph, const TF_Buffer* graph_def, const TF_ImportGraphDefOptions* options, TF_Status* status);
static void TF_GraphImportGraphDefWithResults_(MEX_ARGS) {
  TF_Graph* graph = (TF_Graph*) arr2ptr(prhs[0]);
  TF_Buffer* graph_def = (TF_Buffer*) arr2ptr(prhs[1]);
  TF_ImportGraphDefOptions* options = (TF_ImportGraphDefOptions*) arr2ptr(prhs[2]);
  TF_Status* status = (TF_Status*) arr2ptr(prhs[3]);
  TF_ImportGraphDefResults* results = TF_GraphImportGraphDefWithResults(graph, graph_def, options, status);
  plhs[0] = ptr2arr((void*) results);
}

// TF_CAPI_EXPORT extern void TF_GraphImportGraphDefWithReturnOutputs(TF_Graph* graph, const TF_Buffer* graph_def, const TF_ImportGraphDefOptions* options, TF_Output* return_outputs, int num_return_outputs, TF_Status* status);
static void TF_GraphImportGraphDefWithReturnOutputs_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_GraphImportGraphDef(TF_Graph* graph, const TF_Buffer* graph_def, const TF_ImportGraphDefOptions* options, TF_Status* status);
static void TF_GraphImportGraphDef_(MEX_ARGS) {
  TF_Graph* graph = (TF_Graph*) arr2ptr(prhs[0]);
  TF_Buffer* graph_def = (TF_Buffer*) arr2ptr(prhs[1]);
  TF_ImportGraphDefOptions* options = (TF_ImportGraphDefOptions*) arr2ptr(prhs[2]);
  TF_Status* status = (TF_Status*) arr2ptr(prhs[3]);
  TF_GraphImportGraphDef(graph, graph_def, options, status);
}

// TF_CAPI_EXPORT extern void TF_GraphCopyFunction(TF_Graph* g, const TF_Function* func, const TF_Function* grad, TF_Status* status);
static void TF_GraphCopyFunction_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern int TF_GraphNumFunctions(TF_Graph* g);
static void TF_GraphNumFunctions_(MEX_ARGS) {
  TF_Graph* graph = (TF_Graph*) arr2ptr(prhs[0]);
  plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
  *((int*) mxGetData(plhs[0])) = TF_GraphNumFunctions(graph);
}

// TF_CAPI_EXPORT extern int TF_GraphGetFunctions(TF_Graph* g, TF_Function** funcs, int max_func, TF_Status* status);
static void TF_GraphGetFunctions_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_OperationToNodeDef(TF_Operation* oper, TF_Buffer* output_node_def, TF_Status* status);
static void TF_OperationToNodeDef_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern TF_WhileParams TF_NewWhile(TF_Graph* g, TF_Output* inputs, int ninputs, TF_Status* status);
static void TF_NewWhile_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_FinishWhile(const TF_WhileParams* params, TF_Status* status, TF_Output* outputs);
static void TF_FinishWhile_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_AbortWhile(const TF_WhileParams* params);
static void TF_AbortWhile_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern TF_Function* TF_GraphToFunction(const TF_Graph* fn_body, const char* fn_name, unsigned char append_hash_to_fn_name, int num_opers, const TF_Operation* const* opers, int ninputs, const TF_Output* inputs, int noutputs, const TF_Output* outputs, const char* const* output_names, const TF_FunctionOptions* opts, const char* description, TF_Status* status);
static void TF_GraphToFunction_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern TF_Function* TF_GraphToFunctionWithControlOutputs(const TF_Graph* fn_body, const char* fn_name, unsigned char append_hash_to_fn_name, int num_opers, const TF_Operation* const* opers, int ninputs, const TF_Output* inputs, int noutputs, const TF_Output* outputs, const char* const* output_names, int ncontrol_outputs, const TF_Operation* const* control_outputs, const char* const* control_output_names, const TF_FunctionOptions* opts, const char* description, TF_Status* st atus);
static void TF_GraphToFunctionWithControlOutputs_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern const char* TF_FunctionName(TF_Function* func);
static void TF_FunctionName_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_FunctionToFunctionDef(TF_Function* func, TF_Buffer* output_func_def, TF_Status* status);
static void TF_FunctionToFunctionDef_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern TF_Function* TF_FunctionImportFunctionDef(const void* proto, size_t proto_len, TF_Status* status);
static void TF_FunctionImportFunctionDef_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_FunctionSetAttrValueProto(TF_Function* func, const char* attr_name, const void* proto, size_t proto_len, TF_Status* status);
static void TF_FunctionSetAttrValueProto_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_FunctionGetAttrValueProto(TF_Function* func, const char* attr_name, TF_Buffer* output_attr_value, TF_Status* status);
static void TF_FunctionGetAttrValueProto_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_DeleteFunction(TF_Function* func);
static void TF_DeleteFunction_(MEX_ARGS) {
  TF_Function* func = (TF_Function*) arr2ptr(prhs[0]);
  TF_DeleteFunction(func);
  destroy(func);
}

// TF_CAPI_EXPORT extern unsigned char TF_TryEvaluateConstant(TF_Graph* graph, TF_Output output, TF_Tensor** result, TF_Status* status);
static void TF_TryEvaluateConstant_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern TF_Session* TF_NewSession(TF_Graph* graph, const TF_SessionOptions* opts, TF_Status* status);
static void TF_NewSession_(MEX_ARGS) {
  TF_Graph* graph = (TF_Graph*) arr2ptr(prhs[0]);
  TF_SessionOptions* opts = (TF_SessionOptions*) arr2ptr(prhs[1]);
  TF_Status* status = (TF_Status*) arr2ptr(prhs[2]);
  TF_Session* session = TF_NewSession(graph, opts, status);
  plhs[0] = ptr2arr((void*) session);
}

// TF_CAPI_EXPORT extern TF_Session* TF_LoadSessionFromSavedModel(const TF_SessionOptions* session_options, const TF_Buffer* run_options, const char* export_dir, const char* const* tags, int tags_len, TF_Graph* graph, TF_Buffer* meta_graph_def, TF_Status* status);
static void TF_LoadSessionFromSavedModel_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_CloseSession(TF_Session*, TF_Status* status);
static void TF_CloseSession_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_DeleteSession(TF_Session*, TF_Status* status);
static void TF_DeleteSession_(MEX_ARGS) {
  TF_Session* session = (TF_Session*) arr2ptr(prhs[0]);
  TF_Status* status = (TF_Status*) arr2ptr(prhs[1]);
  TF_DeleteSession(session, status);
  destroy(session);
}

// TF_CAPI_EXPORT extern void TF_SessionRun(TF_Session* session, const TF_Buffer* run_options, const TF_Output* inputs, TF_Tensor* const* input_values, int ninputs, const TF_Output* outputs, TF_Tensor** output_values, int noutputs, const TF_Operation* const* target_opers, int ntargets, TF_Buffer* run_metadata, TF_Status*);
static void TF_SessionRun_(MEX_ARGS) {
  TF_Session* session = (TF_Session*) arr2ptr(prhs[0]);
  TF_Buffer* run_options = NULL;
  if(!mxIsEmpty(prhs[1]))
    run_options = (TF_Buffer*) arr2ptr(prhs[1]);

  // prepare inputs
  uint64_t* inputs_ref = (uint64_t*) mxGetData(prhs[2]);
  uint64_t* input_values_ref = (uint64_t*) mxGetData(prhs[3]);
  int ninputs = *(int*) mxGetData(prhs[4]);
  TF_Output* inputs = (TF_Output*) mxCalloc(ninputs, sizeof(TF_Output));
  if(!inputs)
    mexErrMsgTxt("Allocation of memory for inputs failed.\n");

  TF_Tensor** input_values = (TF_Tensor**) mxCalloc(ninputs, sizeof(TF_Tensor*));
  if(!input_values)
    mexErrMsgTxt("Allocation of memory for input values failed.\n");

  for(int i = 0; i < ninputs; i++) {
    inputs[i] = *((TF_Output*) inputs_ref[i]);
    input_values[i] = (TF_Tensor*) input_values_ref[i];
  }

  // prepare outputs
  uint64_t* outputs_ref = (uint64_t*) mxGetData(prhs[5]);
  int noutputs = *(int*) mxGetData(prhs[6]);
  TF_Output* outputs = (TF_Output*) mxCalloc(noutputs, sizeof(TF_Output));
  if(!outputs)
    mexErrMsgTxt("Allocation of memory for outputs failed.\n");

  TF_Tensor** output_values = (TF_Tensor**) mxCalloc(noutputs, sizeof(TF_Tensor*));
  if(!output_values)
    mexErrMsgTxt("Allocation of memory for output values failed.\n");

  for(int i = 0; i < noutputs; i++) {
    outputs[i] = *((TF_Output*) outputs_ref[i]);
    output_values[i] = NULL;
  }

  // prepare targets
  const TF_Operation* target_opers = NULL;
  if(!mxIsEmpty(prhs[7]))
    target_opers = (TF_Operation*) arr2ptr(prhs[7]);
  int ntargets = *(int*) mxGetData(prhs[8]);
  TF_Buffer* run_metadata = NULL;
  if(!mxIsEmpty(prhs[9]))
    run_metadata = (TF_Buffer*) arr2ptr(prhs[9]);
  TF_Status* status = (TF_Status*) arr2ptr(prhs[10]);

  TF_SessionRun(session, run_options, inputs, input_values, ninputs,
                outputs, output_values, noutputs, &target_opers, ntargets,
                run_metadata, status);

  plhs[0] = mxCreateNumericMatrix(1, noutputs, mxUINT64_CLASS, mxREAL);
  uint64_t* y = (uint64_t*) mxGetData(plhs[0]);
  for(int i = 0; i < noutputs; i++)
    y[i] = (uint64_t) (output_values[i]);

  // cleanup
  mxFree(inputs);
  mxFree(input_values);
  mxFree(outputs);
  mxFree(output_values);
}

// TF_CAPI_EXPORT extern void TF_SessionPRunSetup(TF_Session*, const TF_Output* inputs, int ninputs, const TF_Output* outputs, int noutputs, const TF_Operation* const* target_opers, int ntargets, const char** handle, TF_Status*);
static void TF_SessionPRunSetup_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_SessionPRun(TF_Session*, const char* handle, const TF_Output* inputs, TF_Tensor* const* input_values, int ninputs, const TF_Output* outputs, TF_Tensor** output_values, int noutputs, const TF_Operation* const* target_opers, int ntargets, TF_Status*);
static void TF_SessionPRun_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_DeletePRunHandle(const char* handle);
static void TF_DeletePRunHandle_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern TF_DeprecatedSession* TF_NewDeprecatedSession(const TF_SessionOptions*, TF_Status* status);
static void TF_NewDeprecatedSession_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_CloseDeprecatedSession(TF_DeprecatedSession*, TF_Status* status);
static void TF_CloseDeprecatedSession_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_DeleteDeprecatedSession(TF_DeprecatedSession*, TF_Status* status);
static void TF_DeleteDeprecatedSession_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_Reset(const TF_SessionOptions* opt, const char** containers, int ncontainers, TF_Status* status);
static void TF_Reset_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_ExtendGraph(TF_DeprecatedSession*, const void* proto, size_t proto_len, TF_Status*);
static void TF_ExtendGraph_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_Run(TF_DeprecatedSession*, const TF_Buffer* run_options, const char** input_names, TF_Tensor** inputs, int ninputs, const char** output_names, TF_Tensor** outputs, int noutputs, const char** target_oper_names, int ntargets, TF_Buffer* run_metadata, TF_Status*);
static void TF_Run_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_PRunSetup(TF_DeprecatedSession*, const char** input_names, int ninputs, const char** output_names, int noutputs, const char** target_oper_names, int ntargets, const char** handle, TF_Status*);
static void TF_PRunSetup_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_PRun(TF_DeprecatedSession*, const char* handle, const char** input_names, TF_Tensor** inputs, int ninputs, const char** output_names, TF_Tensor** outputs, int noutputs, const char** target_oper_names, int ntargets, TF_Status*);
static void TF_PRun_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern TF_DeviceList* TF_SessionListDevices(TF_Session* session,  TF_Status* status);
static void TF_SessionListDevices_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern TF_DeviceList* TF_DeprecatedSessionListDevices(TF_DeprecatedSession* session, TF_Status* status);
static void TF_DeprecatedSessionListDevices_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_DeleteDeviceList(TF_DeviceList* list);
static void TF_DeleteDeviceList_(MEX_ARGS) {
  TF_DeviceList* list = (TF_DeviceList*) arr2ptr(prhs[0]);
  TF_DeleteDeviceList(list);
  destroy(list);
}

// TF_CAPI_EXPORT extern int TF_DeviceListCount(const TF_DeviceList* list);
static void TF_DeviceListCount_(MEX_ARGS) {
  TF_DeviceList* list = (TF_DeviceList*) arr2ptr(prhs[0]);
  plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
  *((int*) mxGetData(plhs[0])) = TF_DeviceListCount(list);
}

// TF_CAPI_EXPORT extern const char* TF_DeviceListName(const TF_DeviceList* list, int index, TF_Status* status);
static void TF_DeviceListName_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern const char* TF_DeviceListType(const TF_DeviceList* list, int index, TF_Status* status);
static void TF_DeviceListType_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern int64_t TF_DeviceListMemoryBytes(const TF_DeviceList* list, int index, TF_Status* status);
static void TF_DeviceListMemoryBytes_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern uint64_t TF_DeviceListIncarnation(const TF_DeviceList* list, int index, TF_Status* status);
static void TF_DeviceListIncarnation_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern TF_Library* TF_LoadLibrary(const char* library_filename, TF_Status* status);
static void TF_LoadLibrary_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern TF_Buffer TF_GetOpList(TF_Library* lib_handle);
static void TF_GetOpList_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_DeleteLibraryHandle(TF_Library* lib_handle);
static void TF_DeleteLibraryHandle_(MEX_ARGS) {
  TF_Library* lib_handle = (TF_Library*) arr2ptr(prhs[0]);
  TF_DeleteLibraryHandle(lib_handle);
  destroy(lib_handle);
}

// TF_CAPI_EXPORT extern TF_Buffer* TF_GetAllOpList(void);
static void TF_GetAllOpList_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern TF_ApiDefMap* TF_NewApiDefMap(TF_Buffer* op_list_buffer, TF_Status* status);
static void TF_NewApiDefMap_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_DeleteApiDefMap(TF_ApiDefMap* apimap);
static void TF_DeleteApiDefMap_(MEX_ARGS) {
  TF_ApiDefMap* apimap = (TF_ApiDefMap*) arr2ptr(prhs[0]);
  TF_DeleteApiDefMap(apimap);
  destroy(apimap);
}

// TF_CAPI_EXPORT extern void TF_ApiDefMapPut(TF_ApiDefMap* api_def_map, const char* text, size_t text_len, TF_Status* status);
static void TF_ApiDefMapPut_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern TF_Buffer* TF_ApiDefMapGet(TF_ApiDefMap* api_def_map, const char* name, size_t name_len, TF_Status* status);
static void TF_ApiDefMapGet_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern TF_Buffer* TF_GetAllRegisteredKernels(TF_Status* status);
static void TF_GetAllRegisteredKernels_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern TF_Buffer* TF_GetRegisteredKernelsForOp(const char* name, TF_Status* status);
static void TF_GetRegisteredKernelsForOp_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern TF_Server* TF_NewServer(const void* proto, size_t proto_len, TF_Status* status);
static void TF_NewServer_(MEX_ARGS) {
  NOT_IMPLEMENTED
  TF_Buffer* buffer = (TF_Buffer*) arr2ptr(prhs[0]);
  TF_Status* status = (TF_Status*) arr2ptr(prhs[1]);
  TF_Server* server = TF_NewServer(buffer->data, buffer->length, status);
  plhs[0] = ptr2arr((void*) server);
}

// TF_CAPI_EXPORT extern void TF_ServerStart(TF_Server* server, TF_Status* status);
static void TF_ServerStart_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_ServerStop(TF_Server* server, TF_Status* status);
static void TF_ServerStop_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_ServerJoin(TF_Server* server, TF_Status* status);
static void TF_ServerJoin_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern const char* TF_ServerTarget(TF_Server* server);
static void TF_ServerTarget_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

// TF_CAPI_EXPORT extern void TF_DeleteServer(TF_Server* server);
static void TF_DeleteServer_(MEX_ARGS) {
  TF_Server* server = (TF_Server*) arr2ptr(prhs[0]);
  TF_DeleteServer(server);
  destroy(server);
}

// TF_CAPI_EXPORT extern void TF_RegisterLogListener(void (*listener)(const char*));
static void TF_RegisterLogListener_(MEX_ARGS) {
  NOT_IMPLEMENTED
}

#endif // TENSORFLOW_M_IMPL_CAPI_H
