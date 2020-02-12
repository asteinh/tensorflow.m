/*
 * This file is part of tensorflow.m
 *
 * Copyright 2019-2020 Armin Steinhauser
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#include "tensorflow_m_.h"

mxArray* ptr2arr(const void* ptr) {
  mexLock();
  mxArray* arr = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
  *((uint64_t*) mxGetData(arr)) = (uint64_t) ptr;
  return arr;
}

void* arr2ptr(const mxArray* arr) {
  if(mxGetNumberOfElements(arr) != 1)
    mexErrMsgTxt("Input to \"arr2ptr\" must be a scalar.");
  if(mxGetClassID(arr) != mxUINT64_CLASS)
    mexErrMsgTxt("Input to \"arr2ptr\" must be a uint64.");
  if(mxIsComplex(arr))
    mexErrMsgTxt("Input to \"arr2ptr\" must be real.");

  void* ptr = (void*) *((uint64_t*) mxGetData(arr));
  if(!ptr)
    mexErrMsgTxt("Invalid handle.");
  return ptr;
}

void destroy(void* ptr) {
  ptr = NULL;
  mexUnlock();
}

void bytes_to_buffer(const void* data, const size_t num, TF_Buffer* buffer) {
  if(buffer->data != NULL)
    mexErrMsgTxt("Buffer data cannot be overwritten, create a new buffer instead.\n");

  void* data_cp = mxCalloc(num, sizeof(uint8_t));
  if(!data_cp)
    mexErrMsgTxt("Allocation of memory for buffer failed.\n");

  mexMakeMemoryPersistent(data_cp);
  mexLock();
  memcpy(data_cp, data, num*sizeof(uint8_t));
  buffer->data = data_cp;
  buffer->length = num;
}

void free_buffer(void* data, size_t length) {
  mxFree(data);
  destroy(data);
}

void TFM_Info(MEX_ARGS) {
  mexPrintf("MEX information:\n");
  mexPrintf("\tMEX locked: %s\n", mexIsLocked() ? "true" : "false");
  mexPrintf("\tRunning on TensorFlow v%s\n", TF_Version());
  mexPrintf("\tBuild date: %s @ %s\n", __DATE__, __TIME__);
}

void TFM_NewInput(MEX_ARGS) {
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

void TFM_DeleteInput(MEX_ARGS) {
  TF_Input* input = (TF_Input*) arr2ptr(prhs[0]);
  mxFree(input);
  destroy(input);
}

void TFM_NewOutput(MEX_ARGS) {
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

void TFM_DeleteOutput(MEX_ARGS) {
  TF_Output* output = (TF_Output*) arr2ptr(prhs[0]);
  mxFree(output);
  destroy(output);
}

void TFM_DeleteOperation(MEX_ARGS) {
  TF_Operation* oper = (TF_Operation*) arr2ptr(prhs[0]);
  mxFree(oper);
  destroy(oper);
}

void TFM_DeleteOperationDescription(MEX_ARGS) {
  TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[0]);
  mxFree(desc);
  destroy(desc);
}

void TFM_SetTensorData(MEX_ARGS) {
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

void TFM_GetTensorData(MEX_ARGS) {
  TF_Tensor* tensor = (TF_Tensor*) arr2ptr(prhs[0]);
  TF_DataType dtype = TF_TensorType(tensor);
  if(dtype == TF_STRING) {
    size_t len = TF_TensorByteSize(tensor) - sizeof(uint64_t);
    const char** dst = (const char**) mxCalloc(1, sizeof(char*));
    size_t* dst_len = (size_t*) mxCalloc(1, sizeof(size_t));
    TF_Status* status = TF_NewStatus();
    size_t consumed = TF_StringDecode((char*) (TF_TensorData(tensor) + sizeof(uint64_t)), len, dst, dst_len, status);
    if(TF_GetCode(status) != TF_OK)
      mexErrMsgTxt("Error decoding string from Tensor data.");

    plhs[0] = mxCreateNumericMatrix(1, len, mxUINT8_CLASS, mxREAL);
    memcpy(mxGetData(plhs[0]), dst, *dst_len);
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

void TFM_BufferLength(MEX_ARGS) {
  TF_Buffer* buffer = (TF_Buffer*) arr2ptr(prhs[0]);
  plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
  *((int*) mxGetData(plhs[0])) = (int) buffer->length;
}

void TFM_SetBufferData(MEX_ARGS) {
  TF_Buffer* buffer = (TF_Buffer*) arr2ptr(prhs[0]);
  void* data = (void*) mxGetData(prhs[1]);
  if(mxGetM(prhs[1]) > 1)
    mexErrMsgTxt("Data must be supplied as a single-row, char/uint8 array.");
  size_t length = (size_t) mxGetN(prhs[1]);
  bytes_to_buffer(data, length, buffer);
}

void TFM_GetBufferData(MEX_ARGS) {
  TF_Buffer* buffer = (TF_Buffer*) arr2ptr(prhs[0]);
  size_t length = buffer->length;
  plhs[0] = mxCreateNumericMatrix(1, length, mxUINT8_CLASS, mxREAL);
  memcpy(mxGetData(plhs[0]), buffer->data, length*sizeof(uint8_t));
}

void TFM_FileToBuffer(MEX_ARGS) {
  // MEX implementation of file read for big files
  TF_Buffer* buffer = (TF_Buffer*) arr2ptr(prhs[0]);
  char* fname = mxArrayToString(prhs[1]);

  FILE* f = fopen(fname, "rb");
  mxFree(fname);
  if(!f) mexErrMsgTxt("Failed to open file.\n");

  fseek(f, 0, SEEK_END);
  size_t length = (size_t) ftell(f);
  fseek(f, 0, SEEK_SET);
  void* data = mxCalloc(length, sizeof(uint8_t));
  if(!data) mexErrMsgTxt("Allocation of memory for file reading failed.\n");

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

void TFM_BufferToFile(MEX_ARGS) {
  // MEX implementation of file write for big files
  TF_Buffer* buffer = (TF_Buffer*) arr2ptr(prhs[0]);
  char* fname = mxArrayToString(prhs[1]);
  FILE* f = fopen(fname, "wb");
  mxFree(fname);
  if(!f) mexErrMsgTxt("Failed to open file.\n");

  size_t n_write = fwrite(buffer->data, 1, buffer->length, f);
  fclose(f);
  if(n_write != buffer->length) mexErrMsgTxt("Failed to write the required number of bytes to file.\n");
}

void TFM_DeleteWhile(MEX_ARGS) {
  TF_WhileParams* params = (TF_WhileParams*) arr2ptr(prhs[0]);
  mxFree(params);
  destroy(params);
}
