/*
 * This file is part of tensorflow.m
 *
 * Copyright 2019 Armin Steinhauser
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

#include "mex.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <inttypes.h>
#include "tensorflow/c/c_api.h"

#include "tensorflowm_api.h"

void mexFunction(int nlhs, mxArray* plhs [], int nrhs, const mxArray* prhs []) {

  if(nrhs == 0) {
    mexPrintf("This is TensorFlow.m - the TensorFlow API for MATLAB. Have a goofy day!\n");
  } else {
    // first argument is command string, representing the C API functions
    char* cmd = mxArrayToString(prhs[0]);
    if(cmd == NULL)
      mexErrMsgTxt("Could not convert input to string.");

    // Information on MEX function's state, build, etc.
    if(STRCMP(cmd, "INFO")) {
      mexPrintf("MEX information:\n");
      mexPrintf("\tMEX locked: %s\n", mexIsLocked() ? "true" : "false");
      mexPrintf("\tRunning on TensorFlow v%s.\n", TF_Version());
      mexPrintf("\tBuild date: %s @ %s\n", __DATE__, __TIME__);
      // TODO the following is segfaulting ...
      // #if defined __clang__
      // mexPrintf("\tBuilt with clang %s.\n", __clang_version__);
      // #elif defined(__GNUC__) && defined(__GNUC_MINOR__) && defined(__GNUC_PATCHLEVEL__)
      // mexPrintf("\tBuilt with gcc %s.%s.%s.\n", __GNUC__, __GNUC_MINOR__, __GNUC_PATCHLEVEL__);
      // #elif defined(_MSC_VER)
      // mexPrintf("\tBuilt with Visual Studio %d.\n", _MSC_VER);
      // #endif
    }
    //
    /***************************************************************************
     * Custom functions
     */
    else if(STRCMP(cmd, "TFM_NewInput")) {
      TF_Operation* oper = (TF_Operation*) arr2ptr(prhs[1]);
      int index = *(int*) mxGetData(prhs[2]);
      TF_Input* input = (TF_Input*) mxCalloc(1, sizeof(TF_Input));
      mexMakeMemoryPersistent(input); // must be freed by call to "TFM_DeleteInput"
      input->oper = oper;
      input->index = index;
      plhs[0] = ptr2arr((void*) input);
    }
    else if(STRCMP(cmd, "TFM_DeleteInput")) {
      TF_Input* input = (TF_Input*) arr2ptr(prhs[1]);
      mxFree(input);
      destroy(input);
    }
    else if(STRCMP(cmd, "TFM_NewOutput")) {
      TF_Operation* oper = (TF_Operation*) arr2ptr(prhs[1]);
      int index = *(int*) mxGetData(prhs[2]);
      TF_Output* output = (TF_Output*) mxCalloc(1, sizeof(TF_Output));
      mexMakeMemoryPersistent(output); // must be freed by call to "TFM_DeleteOutput"
      output->oper = oper;
      output->index = index;
      plhs[0] = ptr2arr((void*) output);
    }
    else if(STRCMP(cmd, "TFM_DeleteOutput")) {
      TF_Output* output = (TF_Output*) arr2ptr(prhs[1]);
      mxFree(output);
      destroy(output);
    }
    else if(STRCMP(cmd, "TFM_DeleteOperation")) {
      TF_Operation* oper = (TF_Operation*) arr2ptr(prhs[1]);
      destroy(oper);
    }
    else if(STRCMP(cmd, "TFM_DeleteOperationDescription")) {
      TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[1]);
      destroy(desc);
    }
    else if(STRCMP(cmd, "TFM_SetTensorData")) {
      TF_Tensor* tensor = (TF_Tensor*) arr2ptr(prhs[1]);
      void* input = (void*) mxGetData(prhs[2]);
      size_t len = 1;
      for(int i = 0; i < TF_NumDims(tensor); i++)
        len *= TF_Dim(tensor, i);
      len *= TF_DataTypeSize(TF_TensorType(tensor));
      memcpy(TF_TensorData(tensor), input, MIN(len, TF_TensorByteSize(tensor)));
    }
    else if(STRCMP(cmd, "TFM_GetTensorData")) {
      TF_Tensor* tensor = (TF_Tensor*) arr2ptr(prhs[1]);
      size_t len = 1;
      for(int i = 0; i < TF_NumDims(tensor); i++)
        len *= TF_Dim(tensor, i);

      // create mxArray depending on the tensor's data type, then casting to
      // correct type in Matlab
      size_t bytes = TF_DataTypeSize(TF_TensorType(tensor));
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
    else if(STRCMP(cmd, "TFM_SetBufferData")) {
      TF_Buffer* buffer = (TF_Buffer*) arr2ptr(prhs[1]);
      void* data = (void*) mxGetData(prhs[2]);
      size_t length = (size_t) mxGetN(prhs[2]);
      bytes_to_buffer(data, length, buffer);
    }
    else if(STRCMP(cmd, "TFM_FileToBuffer")) {
      TF_Buffer* buffer = (TF_Buffer*) arr2ptr(prhs[1]);
      char* fname = mxArrayToString(prhs[2]);

      FILE* f = fopen(fname, "rb");
      fseek(f, 0, SEEK_END);
      size_t length = (size_t) ftell(f);
      fseek(f, 0, SEEK_SET);
      void* data = mxCalloc(length, sizeof(uint8_t));
      fread(data, sizeof(uint8_t), length, f);
      fclose(f);
      bytes_to_buffer(data, length, buffer);
      mxFree(data);
    }
    else if(STRCMP(cmd, "TFM_GetBufferData")) {
      TF_Buffer* buffer = (TF_Buffer*) arr2ptr(prhs[1]);
      size_t length = buffer->length;
      plhs[0] = mxCreateNumericMatrix(1, length, mxUINT8_CLASS, mxREAL);
      memcpy(mxGetData(plhs[0]), buffer->data, length*sizeof(uint8_t));
    }
    else if(STRCMP(cmd, "TFM_DeleteWhile")) {
      TF_WhileParams* params = (TF_WhileParams*) arr2ptr(prhs[1]);
      destroy(params);
    }
    else if(STRCMP(cmd, "TFM_DeleteLibrary")) {
      TF_Library* lib_handle = (TF_Library*) arr2ptr(prhs[1]);
      TF_DeleteLibraryHandle(lib_handle);
      destroy(lib_handle);
    }
    //
    /***************************************************************************
     * Library interface
     */
    // TF_CAPI_EXPORT extern const char* TF_Version(void);
    else if(STRCMP(cmd, "TF_Version")) {
      plhs[0] = mxCreateString(TF_Version());
    }
    // TF_CAPI_EXPORT extern size_t TF_DataTypeSize(TF_DataType dt);
    else if(STRCMP(cmd, "TF_DataTypeSize")) {
      TF_DataType* dt = (TF_DataType*) arr2ptr(prhs[1]);
      plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
      *((int*) mxGetData(plhs[0])) = (int) TF_DataTypeSize(*dt);
    }
    // TF_CAPI_EXPORT extern TF_Status* TF_NewStatus(void);
    else if(STRCMP(cmd, "TF_NewStatus")) {
      TF_Status* status = TF_NewStatus();
      plhs[0] = ptr2arr((void*) status);
    }
    // TF_CAPI_EXPORT extern void TF_DeleteStatus(TF_Status*);
    else if(STRCMP(cmd, "TF_DeleteStatus")) {
      TF_Status* status = (TF_Status*) arr2ptr(prhs[1]);
      TF_DeleteStatus(status);
      destroy(status);
    }
    // TF_CAPI_EXPORT extern void TF_SetStatus(TF_Status* s, TF_Code code, const char* msg);
    else if(STRCMP(cmd, "TF_SetStatus")) {
      // TF_Status* status = (TF_Status*) arr2ptr(prhs[1]);
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern TF_Code TF_GetCode(const TF_Status* s);
    else if(STRCMP(cmd, "TF_GetCode")) {
      TF_Status* status = (TF_Status*) arr2ptr(prhs[1]);
      plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT32_CLASS, mxREAL);
      *((TF_Code*) mxGetData(plhs[0])) = TF_GetCode(status);
    }
    // TF_CAPI_EXPORT extern const char* TF_Message(const TF_Status* s);
    else if(STRCMP(cmd, "TF_Message")) {
      TF_Status* status = (TF_Status*) arr2ptr(prhs[1]);
      plhs[0] = mxCreateString(TF_Message(status));
    }
    // TF_CAPI_EXPORT extern TF_Buffer* TF_NewBufferFromString(const void* proto, size_t proto_len);
    else if(STRCMP(cmd, "TF_NewBufferFromString")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern TF_Buffer* TF_NewBuffer(void);
    else if(STRCMP(cmd, "TF_NewBuffer")) {
      TF_Buffer* buffer = TF_NewBuffer();
      buffer->data = NULL;
      buffer->length = 0;
      buffer->data_deallocator = free_buffer;
      plhs[0] = ptr2arr((void*) buffer);
    }
    // TF_CAPI_EXPORT extern void  Buffer(TF_Buffer*);
    else if(STRCMP(cmd, "TF_DeleteBuffer")) {
      TF_Buffer* buffer = (TF_Buffer*) arr2ptr(prhs[1]);
      TF_DeleteBuffer(buffer);  // automatically frees buffer->data via buffer->data_deallocator
      destroy(buffer);
    }
    // TF_CAPI_EXPORT extern TF_Buffer TF_GetBuffer(TF_Buffer* buffer);
    else if(STRCMP(cmd, "TF_GetBuffer")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern TF_Tensor* TF_NewTensor( TF_DataType, const int64_t* dims, int num_dims, void* data, size_t len, void (*deallocator)(void* data, size_t len, void* arg), void* deallocator_arg);
    else if(STRCMP(cmd, "TF_NewTensor")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern TF_Tensor* TF_AllocateTensor(TF_DataType, const int64_t* dims, int num_dims, size_t len);
    else if(STRCMP(cmd, "TF_AllocateTensor")) {
      TF_DataType type = *(TF_DataType*) mxGetData(prhs[1]);
      int64_t* dims = (int64_t*) mxGetData(prhs[2]);
      int num_dims = *(int*) mxGetData(prhs[3]);
      size_t len = 1;
      for(int d = 0; d < num_dims; d++)
        len *= dims[d];
      len *= TF_DataTypeSize(type);
      TF_Tensor* tensor = TF_AllocateTensor(type, dims, num_dims, len);
      plhs[0] = ptr2arr((void*) tensor);
    }
    // TF_CAPI_EXPORT extern TF_Tensor* TF_TensorMaybeMove(TF_Tensor* tensor);
    else if(STRCMP(cmd, "TF_TensorMaybeMove")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_DeleteTensor(TF_Tensor*);
    else if(STRCMP(cmd, "TF_DeleteTensor")) {
      TF_Tensor* tensor = (TF_Tensor*) arr2ptr(prhs[1]);
      TF_DeleteTensor(tensor);
      destroy(tensor);
    }
    // TF_CAPI_EXPORT extern TF_DataType TF_TensorType(const TF_Tensor*);
    else if(STRCMP(cmd, "TF_TensorType")) {
      TF_Tensor* tensor = (TF_Tensor*) arr2ptr(prhs[1]);
      plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT32_CLASS, mxREAL);
      *((TF_DataType*) mxGetData(plhs[0])) = TF_TensorType(tensor);
    }
    // TF_CAPI_EXPORT extern int TF_NumDims(const TF_Tensor*);
    else if(STRCMP(cmd, "TF_NumDims")) {
      TF_Tensor* tensor = (TF_Tensor*) arr2ptr(prhs[1]);
      plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
      *((int*) mxGetData(plhs[0])) = TF_NumDims(tensor);
    }
    // TF_CAPI_EXPORT extern int64_t TF_Dim(const TF_Tensor* tensor, int dim_index);
    else if(STRCMP(cmd, "TF_Dim")) {
      TF_Tensor* tensor = (TF_Tensor*) arr2ptr(prhs[1]);
      int dim_index = *(int*) mxGetData(prhs[2]);
      plhs[0] = mxCreateNumericMatrix(1, 1, mxINT64_CLASS, mxREAL);
      *((int64_t*) mxGetData(plhs[0])) = TF_Dim(tensor, dim_index);
    }
    // TF_CAPI_EXPORT extern size_t TF_TensorByteSize(const TF_Tensor*);
    else if(STRCMP(cmd, "TF_TensorByteSize")) {
      NOT_TESTED()

      TF_Tensor* tensor = (TF_Tensor*) arr2ptr(prhs[1]);
      plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
      *((int*) mxGetData(plhs[0])) = TF_TensorByteSize(tensor);
    }
    // TF_CAPI_EXPORT extern void* TF_TensorData(const TF_Tensor*);
    else if(STRCMP(cmd, "TF_TensorData")) {
      NOT_IMPLEMENTED()
      // this function should probably not be exposed
    }
    // TF_CAPI_EXPORT extern int64_t TF_TensorElementCount(const TF_Tensor* tensor);
    else if(STRCMP(cmd, "TF_TensorElementCount")) {
      TF_Tensor* tensor = (TF_Tensor*) arr2ptr(prhs[1]);
      plhs[0] = mxCreateNumericMatrix(1, 1, mxINT64_CLASS, mxREAL);
      *((int64_t*) mxGetData(plhs[0])) = TF_TensorElementCount(tensor);
    }
    // TF_CAPI_EXPORT extern void TF_TensorBitcastFrom(const TF_Tensor* from, TF_DataType type, TF_Tensor* to, const int64_t* new_dims, int num_new_dims, TF_Status* status);
    else if(STRCMP(cmd, "TF_TensorBitcastFrom")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern size_t TF_StringEncode(const char* src, size_t src_len, char* dst, size_t dst_len, TF_Status* status);
    else if(STRCMP(cmd, "TF_StringEncode")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern size_t TF_StringDecode(const char* src, size_t src_len, const char** dst, size_t* dst_len, TF_Status* status);
    else if(STRCMP(cmd, "TF_StringDecode")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern size_t TF_StringEncodedSize(size_t len);
    else if(STRCMP(cmd, "TF_StringEncodedSize")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern TF_SessionOptions* TF_NewSessionOptions(void);
    else if(STRCMP(cmd, "TF_NewSessionOptions")) {
      TF_SessionOptions* opts = TF_NewSessionOptions();
      plhs[0] = ptr2arr((void*) opts);
    }
    // TF_CAPI_EXPORT extern void TF_SetTarget(TF_SessionOptions* options, const char* target);
    else if(STRCMP(cmd, "TF_SetTarget")) {
      NOT_TESTED()

      TF_SessionOptions* opts = (TF_SessionOptions*) arr2ptr(prhs[1]);
      char* target = mxArrayToString(prhs[2]);
      TF_SetTarget(opts, target);
    }
    // TF_CAPI_EXPORT extern void TF_SetConfig(TF_SessionOptions* options, const void* proto, size_t proto_len, TF_Status* status);
    else if(STRCMP(cmd, "TF_SetConfig")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_DeleteSessionOptions(TF_SessionOptions*);
    else if(STRCMP(cmd, "TF_DeleteSessionOptions")) {
      TF_SessionOptions* opts = (TF_SessionOptions*) arr2ptr(prhs[1]);
      TF_DeleteSessionOptions(opts);
      destroy(opts);
    }
    // TF_CAPI_EXPORT extern TF_Graph* TF_NewGraph(void);
    else if(STRCMP(cmd, "TF_NewGraph")) {
      TF_Graph* graph = TF_NewGraph();
      plhs[0] = ptr2arr((void*) graph);
    }
    // TF_CAPI_EXPORT extern void TF_DeleteGraph(TF_Graph*);
    else if(STRCMP(cmd, "TF_DeleteGraph")) {
      TF_Graph* graph = (TF_Graph*) arr2ptr(prhs[1]);
      TF_DeleteGraph(graph);
      destroy(graph);
    }
    // TF_CAPI_EXPORT extern void TF_GraphSetTensorShape(TF_Graph* graph, TF_Output output, const int64_t* dims, const int num_dims, TF_Status* status);
    else if(STRCMP(cmd, "TF_GraphSetTensorShape")) {
      NOT_TESTED()

      TF_Graph* graph = (TF_Graph*) arr2ptr(prhs[1]);
      TF_Output* output = (TF_Output*) arr2ptr(prhs[2]);
      int64_t* dims = (int64_t*) mxGetData(prhs[3]);
      int* num_dims = (int*) mxGetData(prhs[4]);
      TF_Status* status = (TF_Status*) arr2ptr(prhs[5]);
      TF_GraphSetTensorShape(graph, *output, dims, *num_dims, status);
    }
    // TF_CAPI_EXPORT extern int TF_GraphGetTensorNumDims(TF_Graph* graph, TF_Output output, TF_Status* status);
    else if(STRCMP(cmd, "TF_GraphGetTensorNumDims")) {
      TF_Graph* graph = (TF_Graph*) arr2ptr(prhs[1]);
      TF_Output* output = (TF_Output*) arr2ptr(prhs[2]);
      TF_Status* status = (TF_Status*) arr2ptr(prhs[3]);
      plhs[0] = mxCreateNumericMatrix(1, 1, mxINT64_CLASS, mxREAL);
      *((int64_t*) mxGetData(plhs[0])) = TF_GraphGetTensorNumDims(graph, *output, status);
    }
    // TF_CAPI_EXPORT extern void TF_GraphGetTensorShape(TF_Graph* graph, TF_Output output, int64_t* dims, int num_dims, TF_Status* status);
    else if(STRCMP(cmd, "TF_GraphGetTensorShape")) {
      // mexErrMsgTxt("Check implementation!");
      TF_Graph* graph = (TF_Graph*) arr2ptr(prhs[1]);
      TF_Output* output = (TF_Output*) arr2ptr(prhs[2]);
      TF_Status* status = (TF_Status*) arr2ptr(prhs[3]);
      int64_t num_dims = TF_GraphGetTensorNumDims(graph, *output, status);

      int64_t* dims = (int64_t*) mxCalloc(num_dims, sizeof(int64_t));
      TF_GraphGetTensorShape(graph, *output, dims, num_dims, status);

      plhs[0] = mxCreateNumericMatrix(1, num_dims, mxDOUBLE_CLASS, mxREAL);
      double* y = (double*) mxGetData(plhs[0]);
      for(int i = 0; i < num_dims; i++)
        y[i] = (double) dims[i];

      mxFree(dims);
    }
    // TF_CAPI_EXPORT extern TF_OperationDescription* TF_NewOperation(TF_Graph* graph, const char* op_type, const char* oper_name);
    else if(STRCMP(cmd, "TF_NewOperation")) {
      TF_Graph* graph = (TF_Graph*) arr2ptr(prhs[1]);
      char* op_type = mxArrayToString(prhs[2]);
      char* oper_name = mxArrayToString(prhs[3]);
      TF_OperationDescription* desc = TF_NewOperation(graph, op_type, oper_name);
      plhs[0] = ptr2arr((void*) desc);
    }
    // TF_CAPI_EXPORT extern void TF_SetDevice(TF_OperationDescription* desc, const char* device);
    else if(STRCMP(cmd, "TF_SetDevice")) {
      NOT_TESTED()

      TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[1]);
      char* device = mxArrayToString(prhs[2]);
      TF_SetDevice(desc, device);
    }
    // TF_CAPI_EXPORT extern void TF_AddInput(TF_OperationDescription* desc, TF_Output input);
    else if(STRCMP(cmd, "TF_AddInput")) {
      TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[1]);
      TF_Output input = *((TF_Output*) arr2ptr(prhs[2]));
      TF_AddInput(desc, input);
    }
    // TF_CAPI_EXPORT extern void TF_AddInputList(TF_OperationDescription* desc, const TF_Output* inputs, int num_inputs);
    else if(STRCMP(cmd, "TF_AddInputList")) {
      NOT_TESTED()

      TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[1]);
      TF_Output* inputs = (TF_Output*) arr2ptr(prhs[2]);
      int* num_inputs = (int*) mxGetData(prhs[3]);
      TF_AddInputList(desc, inputs, *num_inputs);
    }
    // TF_CAPI_EXPORT extern void TF_AddControlInput(TF_OperationDescription* desc, TF_Operation* input);
    else if(STRCMP(cmd, "TF_AddControlInput")) {
      NOT_TESTED()

      TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[1]);
      TF_Operation* input = (TF_Operation*) arr2ptr(prhs[2]);
      TF_AddControlInput(desc, input);
    }
    // TF_CAPI_EXPORT extern void TF_ColocateWith(TF_OperationDescription* desc, TF_Operation* op);
    else if(STRCMP(cmd, "TF_ColocateWith")) {
      NOT_TESTED()

      TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[1]);
      TF_Operation* op = (TF_Operation*) arr2ptr(prhs[2]);
      TF_ColocateWith(desc, op);
    }
    // TF_CAPI_EXPORT extern void TF_SetAttrString(TF_OperationDescription* desc, const char* attr_name, const void* value, size_t length);
    else if(STRCMP(cmd, "TF_SetAttrString")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_SetAttrStringList(TF_OperationDescription* desc, const char* attr_name, const void* const* values, const size_t* lengths, int num_values);
    else if(STRCMP(cmd, "TF_SetAttrStringList")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_SetAttrInt(TF_OperationDescription* desc, const char* attr_name, int64_t value);
    else if(STRCMP(cmd, "TF_SetAttrInt")) {
      NOT_TESTED()

      TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[1]);
      char* attr_name = mxArrayToString(prhs[2]);
      int64_t* value = (int64_t*) mxGetData(prhs[3]);
      TF_SetAttrInt(desc, attr_name, *value);
    }
    // TF_CAPI_EXPORT extern void TF_SetAttrIntList(TF_OperationDescription* desc, const char* attr_name, const int64_t* values, int num_values);
    else if(STRCMP(cmd, "TF_SetAttrIntList")) {
      NOT_TESTED()

      TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[1]);
      char* attr_name = mxArrayToString(prhs[2]);
      int64_t* values = (int64_t*) mxGetData(prhs[3]);
      int* num_values = (int*) mxGetData(prhs[4]);
      TF_SetAttrIntList(desc, attr_name, values, *num_values);
    }
    // TF_CAPI_EXPORT extern void TF_SetAttrFloat(TF_OperationDescription* desc, const char* attr_name, float value);
    else if(STRCMP(cmd, "TF_SetAttrFloat")) {
      NOT_TESTED()

      TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[1]);
      char* attr_name = mxArrayToString(prhs[2]);
      float* value = (float*) mxGetData(prhs[3]);
      TF_SetAttrFloat(desc, attr_name, *value);
    }
    // TF_CAPI_EXPORT extern void TF_SetAttrFloatList(TF_OperationDescription* desc, const char* attr_name, const float* values, int num_values);
    else if(STRCMP(cmd, "TF_SetAttrFloatList")) {
      NOT_TESTED()

      TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[1]);
      char* attr_name = mxArrayToString(prhs[2]);
      float* values = (float*) mxGetData(prhs[3]);
      int* num_values = (int*) mxGetData(prhs[4]);
      TF_SetAttrFloatList(desc, attr_name, values, *num_values);
    }
    // TF_CAPI_EXPORT extern void TF_SetAttrBool(TF_OperationDescription* desc, const char* attr_name, unsigned char value);
    else if(STRCMP(cmd, "TF_SetAttrBool")) {
      NOT_TESTED()

      TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[1]);
      char* attr_name = mxArrayToString(prhs[2]);
      unsigned char* value = (unsigned char*) mxGetData(prhs[3]);
      TF_SetAttrBool(desc, attr_name, *value);
    }
    // TF_CAPI_EXPORT extern void TF_SetAttrBoolList(TF_OperationDescription* desc, const char* attr_name, const unsigned char* values,int num_values);
    else if(STRCMP(cmd, "TF_SetAttrBoolList")) {
      NOT_TESTED()

      TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[1]);
      char* attr_name = mxArrayToString(prhs[2]);
      unsigned char* values = (unsigned char*) mxGetData(prhs[3]);
      int* num_values = (int*) mxGetData(prhs[4]);
      TF_SetAttrBoolList(desc, attr_name, values, *num_values);
    }
    // TF_CAPI_EXPORT extern void TF_SetAttrType(TF_OperationDescription* desc, const char* attr_name, TF_DataType value);
    else if(STRCMP(cmd, "TF_SetAttrType")) {
      TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[1]);
      char* attr_name = mxArrayToString(prhs[2]);
      TF_DataType* value = (TF_DataType*) mxGetData(prhs[3]);
      TF_SetAttrType(desc, attr_name, *value);
    }
    // TF_CAPI_EXPORT extern void TF_SetAttrTypeList(TF_OperationDescription* desc, const char* attr_name, const TF_DataType* values, int num_values);
    else if(STRCMP(cmd, "TF_SetAttrTypeList")) {
      NOT_TESTED()

      TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[1]);
      char* attr_name = mxArrayToString(prhs[2]);
      TF_DataType* values = (TF_DataType*) mxGetData(prhs[3]);
      int* num_values = (int*) mxGetData(prhs[4]);
      TF_SetAttrTypeList(desc, attr_name, values, *num_values);
    }
    // TF_CAPI_EXPORT extern void TF_SetAttrPlaceholder(TF_OperationDescription* desc, const char* attr_name, const char* placeholder);
    else if(STRCMP(cmd, "TF_SetAttrPlaceholder")) {
      NOT_TESTED()

      TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[1]);
      char* attr_name = mxArrayToString(prhs[2]);
      char* placeholder = mxArrayToString(prhs[3]);
      TF_SetAttrPlaceholder(desc, attr_name, placeholder);
    }
    // TF_CAPI_EXPORT extern void TF_SetAttrFuncName(TF_OperationDescription* desc, const char* attr_name, const char* value, size_t length);
    else if(STRCMP(cmd, "TF_SetAttrFuncName")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_SetAttrShape(TF_OperationDescription* desc, const char* attr_name, const int64_t* dims, int num_dims);
    else if(STRCMP(cmd, "TF_SetAttrShape")) {
      NOT_TESTED()

      TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[1]);
      char* attr_name = mxArrayToString(prhs[2]);
      int64_t* dims = (int64_t*) mxGetData(prhs[3]);
      int* num_dims = (int*) mxGetData(prhs[4]);
      TF_SetAttrShape(desc, attr_name, dims, *num_dims);
    }
    // TF_CAPI_EXPORT extern void TF_SetAttrShapeList(TF_OperationDescription* desc, const char* attr_name, const int64_t* const* dims, const int* num_dims, int num_shapes);
    else if(STRCMP(cmd, "TF_SetAttrShapeList")) {
      NOT_TESTED()

      TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[1]);
      char* attr_name = mxArrayToString(prhs[2]);
      const int64_t* const* dims = (const int64_t* const*) mxGetData(prhs[3]);
      int* num_dims = (int*) mxGetData(prhs[4]);
      int* num_shapes = (int*) mxGetData(prhs[5]);
      TF_SetAttrShapeList(desc, attr_name, dims, num_dims, *num_shapes);
    }
    // TF_CAPI_EXPORT extern void TF_SetAttrTensorShapeProto(TF_OperationDescription* desc, const char* attr_name, const void* proto, size_t proto_len, TF_Status* status);
    else if(STRCMP(cmd, "TF_SetAttrTensorShapeProto")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_SetAttrTensorShapeProtoList(TF_OperationDescription* desc, const char* attr_name, const void* const* protos, const size_t* proto_lens, int num_shapes, TF_Status* status);
    else if(STRCMP(cmd, "TF_SetAttrTensorShapeProtoList")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_SetAttrTensor(TF_OperationDescription* desc, const char* attr_name, TF_Tensor* value, TF_Status* status);
    else if(STRCMP(cmd, "TF_SetAttrTensor")) {
      TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[1]);
      char* attr_name = mxArrayToString(prhs[2]);
      TF_Tensor* value = (TF_Tensor*) arr2ptr(prhs[3]);
      TF_Status* status = (TF_Status*) arr2ptr(prhs[4]);
      TF_SetAttrTensor(desc, attr_name, value, status);
    }
    // TF_CAPI_EXPORT extern void TF_SetAttrTensorList(TF_OperationDescription* desc, const char* attr_name, TF_Tensor* const* values, int num_values, TF_Status* status);
    else if(STRCMP(cmd, "TF_SetAttrTensorList")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_SetAttrValueProto(TF_OperationDescription* desc, const char* attr_name, const void* proto, size_t proto_len, TF_Status* status);
    else if(STRCMP(cmd, "TF_SetAttrValueProto")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern TF_Operation* TF_FinishOperation(TF_OperationDescription* desc, TF_Status* status);
    else if(STRCMP(cmd, "TF_FinishOperation")) {
      TF_OperationDescription* desc = (TF_OperationDescription*) arr2ptr(prhs[1]);
      TF_Status* status = (TF_Status*) arr2ptr(prhs[2]);
      TF_Operation* oper = TF_FinishOperation(desc, status);
      plhs[0] = ptr2arr((void*) oper);
    }
    // TF_CAPI_EXPORT extern const char* TF_OperationName(TF_Operation* oper);
    else if(STRCMP(cmd, "TF_OperationName")) {
      NOT_TESTED()

      TF_Operation* oper = (TF_Operation*) arr2ptr(prhs[1]);
      plhs[0] = mxCreateString(TF_OperationName(oper));
    }
    // TF_CAPI_EXPORT extern const char* TF_OperationOpType(TF_Operation* oper);
    else if(STRCMP(cmd, "TF_OperationOpType")) {
      NOT_TESTED()

      TF_Operation* oper = (TF_Operation*) arr2ptr(prhs[1]);
      plhs[0] = mxCreateString(TF_OperationOpType(oper));
    }
    // TF_CAPI_EXPORT extern const char* TF_OperationDevice(TF_Operation* oper);
    else if(STRCMP(cmd, "TF_OperationDevice")) {
      NOT_TESTED()

      TF_Operation* oper = (TF_Operation*) arr2ptr(prhs[1]);
      plhs[0] = mxCreateString(TF_OperationDevice(oper));
    }
    // TF_CAPI_EXPORT extern int TF_OperationNumOutputs(TF_Operation* oper);
    else if(STRCMP(cmd, "TF_OperationNumOutputs")) {
      NOT_TESTED()

      TF_Operation* oper = (TF_Operation*) arr2ptr(prhs[1]);
      plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
      *((int*) mxGetData(plhs[0])) = TF_OperationNumOutputs(oper);
    }
    // TF_CAPI_EXPORT extern TF_DataType TF_OperationOutputType(TF_Output oper_out);
    else if(STRCMP(cmd, "TF_OperationOutputType")) {
      TF_Output* output = (TF_Output*) arr2ptr(prhs[1]);
      TF_DataType dtype = TF_OperationOutputType(*output);
      plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT32_CLASS, mxREAL);
      *((TF_DataType*) mxGetData(plhs[0])) = dtype;
    }
    // TF_CAPI_EXPORT extern int TF_OperationOutputListLength(TF_Operation* oper, const char* arg_name, TF_Status* status);
    else if(STRCMP(cmd, "TF_OperationOutputListLength")) {
      NOT_TESTED()

      TF_Operation* oper = (TF_Operation*) arr2ptr(prhs[1]);
      char* arg_name = mxArrayToString(prhs[2]);
      TF_Status* status = (TF_Status*) arr2ptr(prhs[3]);
      plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
      *((int*) mxGetData(plhs[0])) = TF_OperationOutputListLength(oper, arg_name, status);
    }
    // TF_CAPI_EXPORT extern int TF_OperationNumInputs(TF_Operation* oper);
    else if(STRCMP(cmd, "TF_OperationNumInputs")) {
      NOT_TESTED()

      TF_Operation* oper = (TF_Operation*) arr2ptr(prhs[1]);
      plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
      *((int*) mxGetData(plhs[0])) = TF_OperationNumInputs(oper);
    }
    // TF_CAPI_EXPORT extern TF_DataType TF_OperationInputType(TF_Input oper_in);
    else if(STRCMP(cmd, "TF_OperationInputType")) {
      NOT_TESTED()

      TF_Input* input = (TF_Input*) arr2ptr(prhs[1]);
      TF_DataType dtype = TF_OperationInputType(*input);
      plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT32_CLASS, mxREAL);
      *((TF_DataType*) mxGetData(plhs[0])) = dtype;
    }
    // TF_CAPI_EXPORT extern int TF_OperationInputListLength(TF_Operation* oper, const char* arg_name, TF_Status* status);
    else if(STRCMP(cmd, "TF_OperationInputListLength")) {
      NOT_TESTED()

      TF_Operation* oper = (TF_Operation*) arr2ptr(prhs[1]);
      char* arg_name = mxArrayToString(prhs[2]);
      TF_Status* status = (TF_Status*) arr2ptr(prhs[3]);
      plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
      *((int*) mxGetData(plhs[0])) = TF_OperationInputListLength(oper, arg_name, status);
    }
    // TF_CAPI_EXPORT extern TF_Output TF_OperationInput(TF_Input oper_in);
    else if(STRCMP(cmd, "TF_OperationInput")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern int TF_OperationOutputNumConsumers(TF_Output oper_out);
    else if(STRCMP(cmd, "TF_OperationOutputNumConsumers")) {
      NOT_TESTED()

      TF_Output* oper_out = (TF_Output*) arr2ptr(prhs[1]);
      plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
      *((int*) mxGetData(plhs[0])) = TF_OperationOutputNumConsumers(*oper_out);
    }
    // TF_CAPI_EXPORT extern int TF_OperationOutputConsumers(TF_Output oper_out, TF_Input* consumers, int max_consumers);
    else if(STRCMP(cmd, "TF_OperationOutputConsumers")) {
      NOT_TESTED()

      TF_Output* oper_out = (TF_Output*) arr2ptr(prhs[1]);
      TF_Input* consumers = (TF_Input*) arr2ptr(prhs[2]);
      int* max_consumers = (int*) mxGetData(prhs[3]);
      plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
      *((int*) mxGetData(plhs[0])) = TF_OperationOutputConsumers(*oper_out, consumers, *max_consumers);
    }
    // TF_CAPI_EXPORT extern int TF_OperationNumControlInputs(TF_Operation* oper);
    else if(STRCMP(cmd, "TF_OperationNumControlInputs")) {
      NOT_TESTED()

      TF_Operation* oper = (TF_Operation*) arr2ptr(prhs[1]);
      plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
      *((int*) mxGetData(plhs[0])) = TF_OperationNumControlInputs(oper);
    }
    // TF_CAPI_EXPORT extern int TF_OperationGetControlInputs(TF_Operation* oper, TF_Operation** control_inputs, int max_control_inputs);
    else if(STRCMP(cmd, "TF_OperationGetControlInputs")) {
      NOT_TESTED()

      TF_Operation* oper = (TF_Operation*) arr2ptr(prhs[1]);
      TF_Operation** control_inputs = (TF_Operation**) arr2ptr(prhs[2]);
      int* max_control_inputs = (int*) mxGetData(prhs[3]);
      plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
      *((int*) mxGetData(plhs[0])) = TF_OperationGetControlInputs(oper, control_inputs, *max_control_inputs);
    }
    // TF_CAPI_EXPORT extern int TF_OperationNumControlOutputs(TF_Operation* oper);
    else if(STRCMP(cmd, "TF_OperationNumControlOutputs")) {
      NOT_TESTED()

      TF_Operation* oper = (TF_Operation*) arr2ptr(prhs[1]);
      plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
      *((int*) mxGetData(plhs[0])) = TF_OperationNumControlOutputs(oper);
    }
    // TF_CAPI_EXPORT extern int TF_OperationGetControlOutputs(TF_Operation* oper, TF_Operation** control_outputs, int max_control_outputs);
    else if(STRCMP(cmd, "TF_OperationGetControlOutputs")) {
      NOT_TESTED()

      TF_Operation* oper = (TF_Operation*) arr2ptr(prhs[1]);
      TF_Operation** control_outputs = (TF_Operation**) arr2ptr(prhs[2]);
      int* max_control_inputs = (int*) mxGetData(prhs[3]);
      plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
      *((int*) mxGetData(plhs[0])) = TF_OperationGetControlOutputs(oper, control_outputs, *max_control_inputs);
    }
    // TF_CAPI_EXPORT extern TF_AttrMetadata TF_OperationGetAttrMetadata(TF_Operation* oper, const char* attr_name, TF_Status* status);
    else if(STRCMP(cmd, "TF_OperationGetAttrMetadata")) {
      NOT_IMPLEMENTED()
      // requires TF_AttrMetadata object in Matlab
    }
    // TF_CAPI_EXPORT extern void TF_OperationGetAttrString(TF_Operation* oper, const char* attr_name, void* value, size_t max_length, TF_Status* status);
    else if(STRCMP(cmd, "TF_OperationGetAttrString")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_OperationGetAttrStringList(TF_Operation* oper, const char* attr_name, void** values, size_t* lengths, int max_values, void* storage, size_t storage_size, TF_Status* status);
    else if(STRCMP(cmd, "TF_OperationGetAttrStringList")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_OperationGetAttrInt(TF_Operation* oper, const char* attr_name, int64_t* value, TF_Status* status);
    else if(STRCMP(cmd, "TF_OperationGetAttrInt")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_OperationGetAttrIntList(TF_Operation* oper, const char* attr_name, int64_t* values, int max_values, TF_Status* status);
    else if(STRCMP(cmd, "TF_OperationGetAttrIntList")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_OperationGetAttrFloat(TF_Operation* oper, const char* attr_name, float* value, TF_Status* status);
    else if(STRCMP(cmd, "TF_OperationGetAttrFloat")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_OperationGetAttrFloatList(TF_Operation* oper, const char* attr_name, float* values, int max_values, TF_Status* status);
    else if(STRCMP(cmd, "TF_OperationGetAttrFloatList")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_OperationGetAttrBool(TF_Operation* oper, const char* attr_name, unsigned char* value, TF_Status* status);
    else if(STRCMP(cmd, "TF_OperationGetAttrBool")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_OperationGetAttrBoolList(TF_Operation* oper, const char* attr_name, unsigned char* values, int max_values, TF_Status* status);
    else if(STRCMP(cmd, "TF_OperationGetAttrBoolList")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_OperationGetAttrType(TF_Operation* oper, const char* attr_name, TF_DataType* value, TF_Status* status);
    else if(STRCMP(cmd, "TF_OperationGetAttrType")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_OperationGetAttrTypeList(TF_Operation* oper, const char* attr_name, TF_DataType* values, int max_values, TF_Status* status);
    else if(STRCMP(cmd, "TF_OperationGetAttrTypeList")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_OperationGetAttrShape(TF_Operation* oper, const char* attr_name, int64_t* value, int num_dims, TF_Status* status);
    else if(STRCMP(cmd, "TF_OperationGetAttrShape")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_OperationGetAttrShapeList(TF_Operation* oper, const char* attr_name, int64_t** dims, int* num_dims, int num_shapes, int64_t* storage, int storage_size, TF_Status* status);
    else if(STRCMP(cmd, "TF_OperationGetAttrShapeList")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_OperationGetAttrTensorShapeProto(TF_Operation* oper, const char* attr_name, TF_Buffer* value, TF_Status* status);
    else if(STRCMP(cmd, "TF_OperationGetAttrTensorShapeProto")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_OperationGetAttrTensorShapeProtoList(TF_Operation* oper, const char* attr_name, TF_Buffer** values, int max_values, TF_Status* status);
    else if(STRCMP(cmd, "TF_OperationGetAttrTensorShapeProtoList")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_OperationGetAttrTensor(TF_Operation* oper, const char* attr_name, TF_Tensor** value, TF_Status* status);
    else if(STRCMP(cmd, "TF_OperationGetAttrTensor")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_OperationGetAttrTensorList(TF_Operation* oper, const char* attr_name, TF_Tensor** values, int max_values, TF_Status* status);
    else if(STRCMP(cmd, "TF_OperationGetAttrTensorList")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_OperationGetAttrValueProto(TF_Operation* oper, const char* attr_name, TF_Buffer* output_attr_value, TF_Status* status);
    else if(STRCMP(cmd, "TF_OperationGetAttrValueProto")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern TF_Operation* TF_GraphOperationByName(TF_Graph* graph, const char* oper_name);
    else if(STRCMP(cmd, "TF_GraphOperationByName")) {
      TF_Graph* graph = (TF_Graph*) arr2ptr(prhs[1]);
      char* oper_name = mxArrayToString(prhs[2]);
      TF_Operation* oper = TF_GraphOperationByName(graph, oper_name);
      plhs[0] = ptr2arr((void*) oper);
    }
    // TF_CAPI_EXPORT extern TF_Operation* TF_GraphNextOperation(TF_Graph* graph, size_t* pos);
    else if(STRCMP(cmd, "TF_GraphNextOperation")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_GraphToGraphDef(TF_Graph* graph, TF_Buffer* output_graph_def, TF_Status* status);
    else if(STRCMP(cmd, "TF_GraphToGraphDef")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_GraphGetOpDef(TF_Graph* graph, const char* op_name, TF_Buffer* output_op_def, TF_Status* status);
    else if(STRCMP(cmd, "TF_GraphGetOpDef")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_GraphVersions(TF_Graph* graph, TF_Buffer* output_version_def, TF_Status* status);
    else if(STRCMP(cmd, "TF_GraphVersions")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern TF_ImportGraphDefOptions* TF_NewImportGraphDefOptions(void);
    else if(STRCMP(cmd, "TF_NewImportGraphDefOptions")) {
      TF_ImportGraphDefOptions* opts = TF_NewImportGraphDefOptions();
      plhs[0] = ptr2arr((void*) opts);
    }
    // TF_CAPI_EXPORT extern void TF_DeleteImportGraphDefOptions(TF_ImportGraphDefOptions* opts);
    else if(STRCMP(cmd, "TF_DeleteImportGraphDefOptions")) {
      TF_ImportGraphDefOptions* opts = (TF_ImportGraphDefOptions*) arr2ptr(prhs[1]);
      TF_DeleteImportGraphDefOptions(opts);
      destroy(opts);
    }
    // TF_CAPI_EXPORT extern void TF_ImportGraphDefOptionsSetPrefix(TF_ImportGraphDefOptions* opts, const char* prefix);
    else if(STRCMP(cmd, "TF_ImportGraphDefOptionsSetPrefix")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_ImportGraphDefOptionsSetDefaultDevice(TF_ImportGraphDefOptions* opts, const char* device);
    else if(STRCMP(cmd, "TF_ImportGraphDefOptionsSetDefaultDevice")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_ImportGraphDefOptionsSetUniquifyNames(TF_ImportGraphDefOptions* opts, unsigned char uniquify_names);
    else if(STRCMP(cmd, "TF_ImportGraphDefOptionsSetUniquifyNames")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_ImportGraphDefOptionsSetUniquifyPrefix(TF_ImportGraphDefOptions* opts, unsigned char uniquify_prefix);
    else if(STRCMP(cmd, "TF_ImportGraphDefOptionsSetUniquifyPrefix")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_ImportGraphDefOptionsAddInputMapping(TF_ImportGraphDefOptions* opts, const char* src_name, int src_index, TF_Output dst);
    else if(STRCMP(cmd, "TF_ImportGraphDefOptionsAddInputMapping")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_ImportGraphDefOptionsRemapControlDependency(TF_ImportGraphDefOptions* opts, const char* src_name, TF_Operation* dst);
    else if(STRCMP(cmd, "TF_ImportGraphDefOptionsRemapControlDependency")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_ImportGraphDefOptionsAddControlDependency(TF_ImportGraphDefOptions* opts, TF_Operation* oper);
    else if(STRCMP(cmd, "TF_ImportGraphDefOptionsAddControlDependency")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_ImportGraphDefOptionsAddReturnOutput(TF_ImportGraphDefOptions* opts, const char* oper_name, int index);
    else if(STRCMP(cmd, "TF_ImportGraphDefOptionsAddReturnOutput")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern int TF_ImportGraphDefOptionsNumReturnOutputs(const TF_ImportGraphDefOptions* opts);
    else if(STRCMP(cmd, "TF_ImportGraphDefOptionsNumReturnOutputs")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_ImportGraphDefOptionsAddReturnOperation(TF_ImportGraphDefOptions* opts, const char* oper_name);
    else if(STRCMP(cmd, "TF_ImportGraphDefOptionsAddReturnOperation")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern int TF_ImportGraphDefOptionsNumReturnOperations(const TF_ImportGraphDefOptions* opts);
    else if(STRCMP(cmd, "TF_ImportGraphDefOptionsNumReturnOperations")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_ImportGraphDefResultsReturnOutputs(TF_ImportGraphDefResults* results, int* num_outputs, TF_Output** outputs);
    else if(STRCMP(cmd, "TF_ImportGraphDefResultsReturnOutputs")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_ImportGraphDefResultsReturnOperations(TF_ImportGraphDefResults* results, int* num_opers, TF_Operation*** opers);
    else if(STRCMP(cmd, "TF_ImportGraphDefResultsReturnOperations")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_ImportGraphDefResultsMissingUnusedInputMappings(TF_ImportGraphDefResults* results, int* num_missing_unused_input_mappings, const char*** src_names, int** src_indexes);
    else if(STRCMP(cmd, "TF_ImportGraphDefResultsMissingUnusedInputMappings")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_DeleteImportGraphDefResults(TF_ImportGraphDefResults* results);
    else if(STRCMP(cmd, "TF_DeleteImportGraphDefResults")) {
      TF_ImportGraphDefResults* results = (TF_ImportGraphDefResults*) arr2ptr(prhs[1]);
      TF_DeleteImportGraphDefResults(results);
      destroy(results);
    }
    // TF_CAPI_EXPORT extern TF_ImportGraphDefResults* TF_GraphImportGraphDefWithResults(TF_Graph* graph, const TF_Buffer* graph_def, const TF_ImportGraphDefOptions* options, TF_Status* status);
    else if(STRCMP(cmd, "TF_GraphImportGraphDefWithResults")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_GraphImportGraphDefWithReturnOutputs(TF_Graph* graph, const TF_Buffer* graph_def, const TF_ImportGraphDefOptions* options, TF_Output* return_outputs, int num_return_outputs, TF_Status* status);
    else if(STRCMP(cmd, "TF_GraphImportGraphDefWithReturnOutputs")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_GraphImportGraphDef(TF_Graph* graph, const TF_Buffer* graph_def, const TF_ImportGraphDefOptions* options, TF_Status* status);
    else if(STRCMP(cmd, "TF_GraphImportGraphDef")) {
      TF_Graph* graph = (TF_Graph*) arr2ptr(prhs[1]);
      TF_Buffer* graph_def = (TF_Buffer*) arr2ptr(prhs[2]);
      TF_ImportGraphDefOptions* options = (TF_ImportGraphDefOptions*) arr2ptr(prhs[3]);
      TF_Status* status = (TF_Status*) arr2ptr(prhs[4]);
      TF_GraphImportGraphDef(graph, graph_def, options, status);
    }
    // TF_CAPI_EXPORT extern void TF_GraphCopyFunction(TF_Graph* g, const TF_Function* func, const TF_Function* grad, TF_Status* status);
    else if(STRCMP(cmd, "TF_GraphCopyFunction")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern int TF_GraphNumFunctions(TF_Graph* g);
    else if(STRCMP(cmd, "TF_GraphNumFunctions")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern int TF_GraphGetFunctions(TF_Graph* g, TF_Function** funcs, int max_func, TF_Status* status);
    else if(STRCMP(cmd, "TF_GraphGetFunctions")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_OperationToNodeDef(TF_Operation* oper, TF_Buffer* output_node_def, TF_Status* status);
    else if(STRCMP(cmd, "TF_OperationToNodeDef")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern TF_WhileParams TF_NewWhile(TF_Graph* g, TF_Output* inputs, int ninputs, TF_Status* status);
    else if(STRCMP(cmd, "TF_NewWhile")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_FinishWhile(const TF_WhileParams* params, TF_Status* status, TF_Output* outputs);
    else if(STRCMP(cmd, "TF_FinishWhile")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_AbortWhile(const TF_WhileParams* params);
    else if(STRCMP(cmd, "TF_AbortWhile")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern TF_Function* TF_GraphToFunction(const TF_Graph* fn_body, const char* fn_name, unsigned char append_hash_to_fn_name, int num_opers, const TF_Operation* const* opers, int ninputs, const TF_Output* inputs, int noutputs, const TF_Output* outputs, const char* const* output_names, const TF_FunctionOptions* opts, const char* description, TF_Status* status);
    else if(STRCMP(cmd, "TF_GraphToFunction")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern TF_Function* TF_GraphToFunctionWithControlOutputs(const TF_Graph* fn_body, const char* fn_name, unsigned char append_hash_to_fn_name, int num_opers, const TF_Operation* const* opers, int ninputs, const TF_Output* inputs, int noutputs, const TF_Output* outputs, const char* const* output_names, int ncontrol_outputs, const TF_Operation* const* control_outputs, const char* const* control_output_names, const TF_FunctionOptions* opts, const char* description, TF_Status* st atus);
    else if(STRCMP(cmd,"TF_GraphToFunctionWithControlOutputs")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern const char* TF_FunctionName(TF_Function* func);
    else if(STRCMP(cmd, "TF_FunctionName")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_FunctionToFunctionDef(TF_Function* func, TF_Buffer* output_func_def, TF_Status* status);
    else if(STRCMP(cmd, "TF_FunctionToFunctionDef")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern TF_Function* TF_FunctionImportFunctionDef(const void* proto, size_t proto_len, TF_Status* status);
    else if(STRCMP(cmd, "TF_FunctionImportFunctionDef")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_FunctionSetAttrValueProto(TF_Function* func, const char* attr_name, const void* proto, size_t proto_len, TF_Status* status);
    else if(STRCMP(cmd, "TF_FunctionSetAttrValueProto")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_FunctionGetAttrValueProto(TF_Function* func, const char* attr_name, TF_Buffer* output_attr_value, TF_Status* status);
    else if(STRCMP(cmd, "TF_FunctionGetAttrValueProto")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_DeleteFunction(TF_Function* func);
    else if(STRCMP(cmd, "TF_DeleteFunction")) {
      TF_Function* func = (TF_Function*) arr2ptr(prhs[1]);
      TF_DeleteFunction(func);
      destroy(func);
    }
    // TF_CAPI_EXPORT extern unsigned char TF_TryEvaluateConstant(TF_Graph* graph, TF_Output output, TF_Tensor** result, TF_Status* status);
    else if(STRCMP(cmd, "TF_TryEvaluateConstant")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern TF_Session* TF_NewSession(TF_Graph* graph, const TF_SessionOptions* opts, TF_Status* status);
    else if(STRCMP(cmd, "TF_NewSession")) {
      TF_Graph* graph = (TF_Graph*) arr2ptr(prhs[1]);
      TF_SessionOptions* opts = (TF_SessionOptions*) arr2ptr(prhs[2]);
      TF_Status* status = (TF_Status*) arr2ptr(prhs[3]);
      TF_Session* session = TF_NewSession(graph, opts, status);
      plhs[0] = ptr2arr((void*) session);
    }
    // TF_CAPI_EXPORT extern TF_Session* TF_LoadSessionFromSavedModel(const TF_SessionOptions* session_options, const TF_Buffer* run_options, const char* export_dir, const char* const* tags, int tags_len, TF_Graph* graph, TF_Buffer* meta_graph_def, TF_Status* status);
    else if(STRCMP(cmd, "TF_LoadSessionFromSavedModel")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_CloseSession(TF_Session*, TF_Status* status);
    else if(STRCMP(cmd, "TF_CloseSession")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_DeleteSession(TF_Session*, TF_Status* status);
    else if(STRCMP(cmd, "TF_DeleteSession")) {
      TF_Session* session = (TF_Session*) arr2ptr(prhs[1]);
      TF_Status* status = (TF_Status*) arr2ptr(prhs[2]);
      TF_DeleteSession(session, status);
      destroy(session);
    }
    // TF_CAPI_EXPORT extern void TF_SessionRun(TF_Session* session, const TF_Buffer* run_options, const TF_Output* inputs, TF_Tensor* const* input_values, int ninputs, const TF_Output* outputs, TF_Tensor** output_values, int noutputs, const TF_Operation* const* target_opers, int ntargets, TF_Buffer* run_metadata, TF_Status*);
    else if(STRCMP(cmd, "TF_SessionRun")) {
      TF_Session* session = (TF_Session*) arr2ptr(prhs[1]);
      TF_Buffer* run_options = NULL;
      if(!mxIsEmpty(prhs[2]))
        run_options = (TF_Buffer*) arr2ptr(prhs[2]);

      // prepare inputs
      uint64_t* inputs_ref = (uint64_t*) mxGetData(prhs[3]);
      uint64_t* input_values_ref = (uint64_t*) mxGetData(prhs[4]);
      int ninputs = *(int*) mxGetData(prhs[5]);
      TF_Output* inputs = (TF_Output*) mxCalloc(ninputs, sizeof(TF_Output));
      TF_Tensor** input_values = (TF_Tensor**) mxCalloc(ninputs, sizeof(TF_Tensor*));
      for(int i = 0; i < ninputs; i++) {
        inputs[i] = *((TF_Output*) inputs_ref[i]);
        input_values[i] = (TF_Tensor*) input_values_ref[i];
      }

      // prepare outputs
      uint64_t* outputs_ref = (uint64_t*) mxGetData(prhs[6]);
      int noutputs = *(int*) mxGetData(prhs[7]);
      TF_Output* outputs = (TF_Output*) mxCalloc(noutputs, sizeof(TF_Output));
      TF_Tensor** output_values = (TF_Tensor**) mxCalloc(noutputs, sizeof(TF_Tensor*));
      for(int i = 0; i < noutputs; i++) {
        outputs[i] = *((TF_Output*) outputs_ref[i]);
        output_values[i] = NULL;
      }

      // prepare targets
      const TF_Operation* target_opers = NULL;
      if(!mxIsEmpty(prhs[8]))
        target_opers = (TF_Operation*) arr2ptr(prhs[8]);
      int ntargets = *(int*) mxGetData(prhs[9]);
      TF_Buffer* run_metadata = NULL;
      if(!mxIsEmpty(prhs[10]))
        run_metadata = (TF_Buffer*) arr2ptr(prhs[10]);
      TF_Status* status = (TF_Status*) arr2ptr(prhs[11]);

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
    else if(STRCMP(cmd, "TF_SessionPRunSetup")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_SessionPRun(TF_Session*, const char* handle, const TF_Output* inputs, TF_Tensor* const* input_values, int ninputs, const TF_Output* outputs, TF_Tensor** output_values, int noutputs, const TF_Operation* const* target_opers, int ntargets, TF_Status*);
    else if(STRCMP(cmd, "TF_SessionPRun")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_DeletePRunHandle(const char* handle);
    else if(STRCMP(cmd, "TF_DeletePRunHandle")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern TF_DeprecatedSession* TF_NewDeprecatedSession(const TF_SessionOptions*, TF_Status* status);
    else if(STRCMP(cmd, "TF_NewDeprecatedSession")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_CloseDeprecatedSession(TF_DeprecatedSession*, TF_Status* status);
    else if(STRCMP(cmd, "TF_CloseDeprecatedSession")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_DeleteDeprecatedSession(TF_DeprecatedSession*, TF_Status* status);
    else if(STRCMP(cmd, "TF_DeleteDeprecatedSession")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_Reset(const TF_SessionOptions* opt, const char** containers, int ncontainers, TF_Status* status);
    else if(STRCMP(cmd, "TF_Reset")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_ExtendGraph(TF_DeprecatedSession*, const void* proto, size_t proto_len, TF_Status*);
    else if(STRCMP(cmd, "TF_ExtendGraph")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_Run(TF_DeprecatedSession*, const TF_Buffer* run_options, const char** input_names, TF_Tensor** inputs, int ninputs, const char** output_names, TF_Tensor** outputs, int noutputs, const char** target_oper_names, int ntargets, TF_Buffer* run_metadata, TF_Status*);
    else if(STRCMP(cmd, "TF_Run")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_PRunSetup(TF_DeprecatedSession*, const char** input_names, int ninputs, const char** output_names, int noutputs, const char** target_oper_names, int ntargets, const char** handle, TF_Status*);
    else if(STRCMP(cmd, "TF_PRunSetup")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_PRun(TF_DeprecatedSession*, const char* handle, const char** input_names, TF_Tensor** inputs, int ninputs, const char** output_names, TF_Tensor** outputs, int noutputs, const char** target_oper_names, int ntargets, TF_Status*);
    else if(STRCMP(cmd, "TF_PRun")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern TF_DeviceList* TF_SessionListDevices(TF_Session* session,  TF_Status* status);
    else if(STRCMP(cmd, "TF_SessionListDevices")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern TF_DeviceList* TF_DeprecatedSessionListDevices(TF_DeprecatedSession* session, TF_Status* status);
    else if(STRCMP(cmd, "TF_DeprecatedSessionListDevices")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_DeleteDeviceList(TF_DeviceList* list);
    else if(STRCMP(cmd, "TF_DeleteDeviceList")) {
      TF_DeviceList* list = (TF_DeviceList*) arr2ptr(prhs[1]);
      TF_DeleteDeviceList(list);
      destroy(list);
    }
    // TF_CAPI_EXPORT extern int TF_DeviceListCount(const TF_DeviceList* list);
    else if(STRCMP(cmd, "TF_DeviceListCount")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern const char* TF_DeviceListName(const TF_DeviceList* list, int index, TF_Status* status);
    else if(STRCMP(cmd, "TF_DeviceListName")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern const char* TF_DeviceListType(const TF_DeviceList* list, int index, TF_Status* status);
    else if(STRCMP(cmd, "TF_DeviceListType")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern int64_t TF_DeviceListMemoryBytes(const TF_DeviceList* list, int index, TF_Status* status);
    else if(STRCMP(cmd, "TF_DeviceListMemoryBytes")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern uint64_t TF_DeviceListIncarnation(const TF_DeviceList* list, int index, TF_Status* status);
    else if(STRCMP(cmd, "TF_DeviceListIncarnation")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern TF_Library* TF_LoadLibrary(const char* library_filename, TF_Status* status);
    else if(STRCMP(cmd, "TF_LoadLibrary")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern TF_Buffer TF_GetOpList(TF_Library* lib_handle);
    else if(STRCMP(cmd, "TF_GetOpList")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_DeleteLibraryHandle(TF_Library* lib_handle);
    else if(STRCMP(cmd, "TF_DeleteLibraryHandle")) {
      TF_Library* lib_handle = (TF_Library*) arr2ptr(prhs[1]);
      TF_DeleteLibraryHandle(func);
      destroy(func);
    }
    // TF_CAPI_EXPORT extern TF_Buffer* TF_GetAllOpList(void);
    else if(STRCMP(cmd, "TF_GetAllOpList")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern TF_ApiDefMap* TF_NewApiDefMap(TF_Buffer* op_list_buffer, TF_Status* status);
    else if(STRCMP(cmd, "TF_NewApiDefMap")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_DeleteApiDefMap(TF_ApiDefMap* apimap);
    else if(STRCMP(cmd, "TF_DeleteApiDefMap")) {
      TF_ApiDefMap* apimap = (TF_ApiDefMap*) arr2ptr(prhs[1]);
      TF_DeleteApiDefMap(apimap);
      destroy(apimap);
    }
    // TF_CAPI_EXPORT extern void TF_ApiDefMapPut(TF_ApiDefMap* api_def_map, const char* text, size_t text_len, TF_Status* status);
    else if(STRCMP(cmd, "TF_ApiDefMapPut")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern TF_Buffer* TF_ApiDefMapGet(TF_ApiDefMap* api_def_map, const char* name, size_t name_len, TF_Status* status);
    else if(STRCMP(cmd, "TF_ApiDefMapGet")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern TF_Buffer* TF_GetAllRegisteredKernels(TF_Status* status);
    else if(STRCMP(cmd, "TF_GetAllRegisteredKernels")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern TF_Buffer* TF_GetRegisteredKernelsForOp(const char* name, TF_Status* status);
    else if(STRCMP(cmd, "TF_GetRegisteredKernelsForOp")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern TF_Server* TF_NewServer(const void* proto, size_t proto_len, TF_Status* status);
    else if(STRCMP(cmd, "TF_NewServer")) {
      NOT_IMPLEMENTED()
      TF_Buffer* buffer = (TF_Buffer*) arr2ptr(prhs[1]);
      TF_Status* status = (TF_Status*) arr2ptr(prhs[2]);
      TF_Server* server = TF_NewServer(buffer->data, buffer->length, status);
      plhs[0] = ptr2arr((void*) server);
    }
    // TF_CAPI_EXPORT extern void TF_ServerStart(TF_Server* server, TF_Status* status);
    else if(STRCMP(cmd, "TF_ServerStart")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_ServerStop(TF_Server* server, TF_Status* status);
    else if(STRCMP(cmd, "TF_ServerStop")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_ServerJoin(TF_Server* server, TF_Status* status);
    else if(STRCMP(cmd, "TF_ServerJoin")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern const char* TF_ServerTarget(TF_Server* server);
    else if(STRCMP(cmd, "TF_ServerTarget")) {
      NOT_IMPLEMENTED()
    }
    // TF_CAPI_EXPORT extern void TF_DeleteServer(TF_Server* server);
    else if(STRCMP(cmd, "TF_DeleteServer")) {
      TF_Server* server = (TF_Server*) arr2ptr(prhs[1]);
      TF_DeleteServer(server);
      destroy(server);
    }
    // TF_CAPI_EXPORT extern void TF_RegisterLogListener(void (*listener)(const char*));
    else if(STRCMP(cmd, "TF_RegisterLogListener")) {
      NOT_IMPLEMENTED()
    }
    // couldn't find function
    else {
      mexErrMsgTxt("Command string could not be interpreted.");
    }

    mxFree(cmd);
  }

  return;
}
