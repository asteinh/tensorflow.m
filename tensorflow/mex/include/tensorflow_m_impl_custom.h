#ifndef TENSORFLOW_M_IMPL_CUSTOM_H
#define TENSORFLOW_M_IMPL_CUSTOM_H

#include "tensorflow_m_api.h"

static void TFM_Info(MEX_ARGS) {
  mexPrintf("MEX information:\n");
  mexPrintf("\tMEX locked: %s\n", mexIsLocked() ? "true" : "false");
  mexPrintf("\tRunning on TensorFlow v%s.\n", TF_Version());
  mexPrintf("\tBuild date: %s @ %s\n", __DATE__, __TIME__);
}

static void TFM_NewInput(MEX_ARGS) {
  TF_Operation* oper = (TF_Operation*) arr2ptr(prhs[0]);
  int index = *(int*) mxGetData(prhs[1]);
  TF_Input* input = (TF_Input*) mxCalloc(1, sizeof(TF_Input));
  if(!input)
    mexErrMsgTxt("Allocation of memory for TF_Input failed.\n");

  mexMakeMemoryPersistent(input); // must be freed by call to "TFM_DeleteInput"
  input->oper = oper;
  input->index = index;
  plhs[0] = ptr2arr((void*) input);
}

static void TFM_DeleteInput(MEX_ARGS) {
  TF_Input* input = (TF_Input*) arr2ptr(prhs[0]);
  mxFree(input);
  destroy(input);
}

static void TFM_NewOutput(MEX_ARGS) {
  TF_Operation* oper = (TF_Operation*) arr2ptr(prhs[0]);
  int index = *(int*) mxGetData(prhs[1]);
  TF_Output* output = (TF_Output*) mxCalloc(1, sizeof(TF_Output));
  if(!output)
    mexErrMsgTxt("Allocation of memory for TF_Output failed.\n");

  mexMakeMemoryPersistent(output); // must be freed by call to "TFM_DeleteOutput"
  output->oper = oper;
  output->index = index;
  plhs[0] = ptr2arr((void*) output);
}

static void TFM_DeleteOutput(MEX_ARGS) {
  TF_Output* output = (TF_Output*) arr2ptr(prhs[0]);
  mxFree(output);
  destroy(output);
}

static void TFM_DeleteOperation(MEX_ARGS) {
  TF_Operation* oper = (TF_Operation*) arr2ptr(prhs[0]);
  destroy(oper);
}

static void TFM_DeleteOperationDescription(MEX_ARGS) {
  TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[0]);
  destroy(desc);
}

static void TFM_SetTensorData(MEX_ARGS) {
  TF_Tensor* tensor = (TF_Tensor*) arr2ptr(prhs[0]);
  void* src = (void*) mxGetData(prhs[1]);

  TF_DataType dtype = TF_TensorType(tensor);
  if(dtype == TF_STRING) {
    size_t len = (size_t) mxGetN(prhs[1]);
    void* dst = TF_TensorData(tensor) + sizeof(uint64_t);
    size_t dst_len = TF_StringEncodedSize(len);
    TF_Status* status = TF_NewStatus();
    size_t consumed = TF_StringEncode(src, len, dst, dst_len, status);
    if(TF_GetCode(status) != TF_OK)
      mexErrMsgTxt("Error encoding string to Tensor data.");
  } else {
    size_t len = 1;
    for(int i = 0; i < TF_NumDims(tensor); i++)
      len *= TF_Dim(tensor, i);
    len *= TF_DataTypeSize(TF_TensorType(tensor));
    if(len <= TF_TensorByteSize(tensor))
      memcpy(TF_TensorData(tensor), src, len);
    else
      mexErrMsgTxt("Memory allocated for TF_Tensor cannot hold amount of given data.");
  }
}

static void TFM_GetTensorData(MEX_ARGS) {
  TF_Tensor* tensor = (TF_Tensor*) arr2ptr(prhs[0]);
  TF_DataType dtype = TF_TensorType(tensor);
  if(dtype == TF_STRING) {
    size_t len = TF_TensorByteSize(tensor) - sizeof(uint64_t);
    char** dst = (char**) mxCalloc(1, sizeof(char*));
    size_t* dst_len = (size_t*) mxCalloc(1, sizeof(size_t));
    TF_Status* status = TF_NewStatus();
    size_t consumed = TF_StringDecode((char*) (TF_TensorData(tensor) + sizeof(uint64_t)), len, dst, dst_len, status);
    if(TF_GetCode(status) != TF_OK)
      mexErrMsgTxt("Error decoding string from Tensor data.");

    plhs[0] = mxCreateNumericMatrix(1, len, mxUINT8_CLASS, mxREAL);
    memcpy(mxGetData(plhs[0]), TF_TensorData(tensor), len);
    mxFree(dst);
    mxFree(dst_len);
  } else {
    size_t len = 1;
    for(int i = 0; i < TF_NumDims(tensor); i++)
      len *= TF_Dim(tensor, i);
    // mxArray depending on data type; cast to correct type in Matlab
    size_t bytes = TF_DataTypeSize(dtype);
    if(bytes == 1)
      plhs[0] = mxCreateNumericMatrix(1, len, mxUINT8_CLASS, mxREAL);
    else if(bytes == 2)
      plhs[0] = mxCreateNumericMatrix(1, len, mxUINT16_CLASS, mxREAL);
    else if(bytes == 4)
      plhs[0] = mxCreateNumericMatrix(1, len, mxUINT32_CLASS, mxREAL);
    else if(bytes == 8)
      plhs[0] = mxCreateNumericMatrix(1, len, mxUINT64_CLASS, mxREAL);
    else
      mexErrMsgTxt("Could not figure out the bitsize of tensor's data type.");

    memcpy(mxGetData(plhs[0]), TF_TensorData(tensor), TF_TensorByteSize(tensor));
  }
}

static void TFM_BufferLength(MEX_ARGS) {
  TF_Buffer* buffer = (TF_Buffer*) arr2ptr(prhs[0]);
  plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
  *((int*) mxGetData(plhs[0])) = (int) buffer->length;
}

static void TFM_SetBufferData(MEX_ARGS) {
  TF_Buffer* buffer = (TF_Buffer*) arr2ptr(prhs[0]);
  void* data = (void*) mxGetData(prhs[1]);
  if(mxGetM(prhs[1]) > 1)
    mexErrMsgTxt("Data must be supplied as a single-row, char/uint8 array.");
  size_t length = (size_t) mxGetN(prhs[1]);
  bytes_to_buffer(data, length, buffer);
}

static void TFM_GetBufferData(MEX_ARGS) {
  TF_Buffer* buffer = (TF_Buffer*) arr2ptr(prhs[0]);
  size_t length = buffer->length;
  plhs[0] = mxCreateNumericMatrix(1, length, mxUINT8_CLASS, mxREAL);
  memcpy(mxGetData(plhs[0]), buffer->data, length*sizeof(uint8_t));
}

static void TFM_FileToBuffer(MEX_ARGS) {
  // MEX implementation of file read for big files
  TF_Buffer* buffer = (TF_Buffer*) arr2ptr(prhs[0]);
  char* fname = mxArrayToString(prhs[1]);

  FILE* f = fopen(fname, "rb");
  mxFree(fname);
  if(!f)
    mexErrMsgTxt("Failed to open file.\n");

  fseek(f, 0, SEEK_END);
  size_t length = (size_t) ftell(f);
  fseek(f, 0, SEEK_SET);
  void* data = mxCalloc(length, sizeof(uint8_t));
  if(!data)
    mexErrMsgTxt("Allocation of memory for file reading failed.\n");

  size_t n_read = fread(data, sizeof(uint8_t), length, f);
  fclose(f);
  if(n_read == sizeof(uint8_t)*length) {
    bytes_to_buffer(data, length, buffer);
    mxFree(data);
  } else {
    mxFree(data);
    mexErrMsgTxt("Failed to read the expected number of bytes from file.\n");
  }
}

static void TFM_BufferToFile(MEX_ARGS) {
  // MEX implementation of file write for big files
  TF_Buffer* buffer = (TF_Buffer*) arr2ptr(prhs[0]);
  char* fname = mxArrayToString(prhs[1]);
  FILE* f = fopen(fname, "wb");
  mxFree(fname);
  if(!f)
    mexErrMsgTxt("Failed to open file.\n");

  size_t n_write = fwrite(buffer->data, 1, buffer->length, f);
  fclose(f);
  if(n_write != buffer->length)
    mexErrMsgTxt("Failed to write the required number of bytes to file.\n");
}

static void TFM_DeleteWhile(MEX_ARGS) {
  TF_WhileParams* params = (TF_WhileParams*) arr2ptr(prhs[0]);
  destroy(params);
}

#endif // TENSORFLOW_M_IMPL_CUSTOM_H
