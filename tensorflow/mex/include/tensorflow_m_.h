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

#ifndef TENSORFLOW_M_H
#define TENSORFLOW_M_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <inttypes.h>

#include "mex.h"
#include "tensorflow/c/c_api.h"

// dev tools
#define NOT_IMPLEMENTED mexErrMsgTxt("Not implemented.");
#define NOT_SUPPORTED   mexErrMsgTxt("Not supported.");
#define NOT_TESTED      mexWarnMsgTxt("Implementation untested!");

// shorthand for input arguments
#define MEX_ARGS int nlhs, mxArray** plhs, int nrhs, const mxArray** prhs

// convenience functions
mxArray* ptr2arr(const void* ptr);
void* arr2ptr(const mxArray* arr);
void destroy(void* ptr);
void bytes_to_buffer(const void* data, const size_t num, TF_Buffer* buffer);
void free_buffer(void* data, size_t length);

// custom TF interface functions
void TFM_Info(MEX_ARGS);
void TFM_NewInput(MEX_ARGS);
void TFM_DeleteInput(MEX_ARGS);
void TFM_NewOutput(MEX_ARGS);
void TFM_DeleteOutput(MEX_ARGS);
void TFM_DeleteOperation(MEX_ARGS);
void TFM_DeleteOperationDescription(MEX_ARGS);
void TFM_SetTensorData(MEX_ARGS);
void TFM_GetTensorData(MEX_ARGS);
void TFM_BufferLength(MEX_ARGS);
void TFM_SetBufferData(MEX_ARGS);
void TFM_GetBufferData(MEX_ARGS);
void TFM_FileToBuffer(MEX_ARGS);
void TFM_BufferToFile(MEX_ARGS);
void TFM_DeleteWhile(MEX_ARGS);

// TF interface functions
void TF_Version_(MEX_ARGS);
void TF_DataTypeSize_(MEX_ARGS);
void TF_NewStatus_(MEX_ARGS);
void TF_DeleteStatus_(MEX_ARGS);
void TF_SetStatus_(MEX_ARGS);
void TF_GetCode_(MEX_ARGS);
void TF_Message_(MEX_ARGS);
void TF_NewBufferFromString_(MEX_ARGS);
void TF_NewBuffer_(MEX_ARGS);
void TF_DeleteBuffer_(MEX_ARGS);
void TF_GetBuffer_(MEX_ARGS);
void TF_NewTensor_(MEX_ARGS);
void TF_AllocateTensor_(MEX_ARGS);
void TF_TensorMaybeMove_(MEX_ARGS);
void TF_DeleteTensor_(MEX_ARGS);
void TF_TensorType_(MEX_ARGS);
void TF_NumDims_(MEX_ARGS);
void TF_Dim_(MEX_ARGS);
void TF_TensorByteSize_(MEX_ARGS);
void TF_TensorData_(MEX_ARGS);
void TF_TensorElementCount_(MEX_ARGS);
void TF_TensorBitcastFrom_(MEX_ARGS);
void TF_StringEncode_(MEX_ARGS);
void TF_StringDecode_(MEX_ARGS);
void TF_StringEncodedSize_(MEX_ARGS);
void TF_NewSessionOptions_(MEX_ARGS);
void TF_SetTarget_(MEX_ARGS);
void TF_SetConfig_(MEX_ARGS);
void TF_DeleteSessionOptions_(MEX_ARGS);
void TF_NewGraph_(MEX_ARGS);
void TF_DeleteGraph_(MEX_ARGS);
void TF_GraphSetTensorShape_(MEX_ARGS);
void TF_GraphGetTensorNumDims_(MEX_ARGS);
void TF_GraphGetTensorShape_(MEX_ARGS);
void TF_NewOperation_(MEX_ARGS);
void TF_SetDevice_(MEX_ARGS);
void TF_AddInput_(MEX_ARGS);
void TF_AddInputList_(MEX_ARGS);
void TF_AddControlInput_(MEX_ARGS);
void TF_ColocateWith_(MEX_ARGS);
void TF_SetAttrString_(MEX_ARGS);
void TF_SetAttrStringList_(MEX_ARGS);
void TF_SetAttrInt_(MEX_ARGS);
void TF_SetAttrIntList_(MEX_ARGS);
void TF_SetAttrFloat_(MEX_ARGS);
void TF_SetAttrFloatList_(MEX_ARGS);
void TF_SetAttrBool_(MEX_ARGS);
void TF_SetAttrBoolList_(MEX_ARGS);
void TF_SetAttrType_(MEX_ARGS);
void TF_SetAttrTypeList_(MEX_ARGS);
void TF_SetAttrPlaceholder_(MEX_ARGS);
void TF_SetAttrFuncName_(MEX_ARGS);
void TF_SetAttrShape_(MEX_ARGS);
void TF_SetAttrShapeList_(MEX_ARGS);
void TF_SetAttrTensorShapeProto_(MEX_ARGS);
void TF_SetAttrTensorShapeProtoList_(MEX_ARGS);
void TF_SetAttrTensor_(MEX_ARGS);
void TF_SetAttrTensorList_(MEX_ARGS);
void TF_SetAttrValueProto_(MEX_ARGS);
void TF_FinishOperation_(MEX_ARGS);
void TF_OperationName_(MEX_ARGS);
void TF_OperationOpType_(MEX_ARGS);
void TF_OperationDevice_(MEX_ARGS);
void TF_OperationNumOutputs_(MEX_ARGS);
void TF_OperationOutputType_(MEX_ARGS);
void TF_OperationOutputListLength_(MEX_ARGS);
void TF_OperationNumInputs_(MEX_ARGS);
void TF_OperationInputType_(MEX_ARGS);
void TF_OperationInputListLength_(MEX_ARGS);
void TF_OperationInput_(MEX_ARGS);
void TF_OperationOutputNumConsumers_(MEX_ARGS);
void TF_OperationOutputConsumers_(MEX_ARGS);
void TF_OperationNumControlInputs_(MEX_ARGS);
void TF_OperationGetControlInputs_(MEX_ARGS);
void TF_OperationNumControlOutputs_(MEX_ARGS);
void TF_OperationGetControlOutputs_(MEX_ARGS);
void TF_OperationGetAttrMetadata_(MEX_ARGS);
void TF_OperationGetAttrString_(MEX_ARGS);
void TF_OperationGetAttrStringList_(MEX_ARGS);
void TF_OperationGetAttrInt_(MEX_ARGS);
void TF_OperationGetAttrIntList_(MEX_ARGS);
void TF_OperationGetAttrFloat_(MEX_ARGS);
void TF_OperationGetAttrFloatList_(MEX_ARGS);
void TF_OperationGetAttrBool_(MEX_ARGS);
void TF_OperationGetAttrBoolList_(MEX_ARGS);
void TF_OperationGetAttrType_(MEX_ARGS);
void TF_OperationGetAttrTypeList_(MEX_ARGS);
void TF_OperationGetAttrShape_(MEX_ARGS);
void TF_OperationGetAttrShapeList_(MEX_ARGS);
void TF_OperationGetAttrTensorShapeProto_(MEX_ARGS);
void TF_OperationGetAttrTensorShapeProtoList_(MEX_ARGS);
void TF_OperationGetAttrTensor_(MEX_ARGS);
void TF_OperationGetAttrTensorList_(MEX_ARGS);
void TF_OperationGetAttrValueProto_(MEX_ARGS);
void TF_GraphOperationByName_(MEX_ARGS);
void TF_GraphNextOperation_(MEX_ARGS);
void TF_GraphToGraphDef_(MEX_ARGS);
void TF_GraphGetOpDef_(MEX_ARGS);
void TF_GraphVersions_(MEX_ARGS);
void TF_NewImportGraphDefOptions_(MEX_ARGS);
void TF_DeleteImportGraphDefOptions_(MEX_ARGS);
void TF_ImportGraphDefOptionsSetPrefix_(MEX_ARGS);
void TF_ImportGraphDefOptionsSetDefaultDevice_(MEX_ARGS);
void TF_ImportGraphDefOptionsSetUniquifyNames_(MEX_ARGS);
void TF_ImportGraphDefOptionsSetUniquifyPrefix_(MEX_ARGS);
void TF_ImportGraphDefOptionsAddInputMapping_(MEX_ARGS);
void TF_ImportGraphDefOptionsRemapControlDependency_(MEX_ARGS);
void TF_ImportGraphDefOptionsAddControlDependency_(MEX_ARGS);
void TF_ImportGraphDefOptionsAddReturnOutput_(MEX_ARGS);
void TF_ImportGraphDefOptionsNumReturnOutputs_(MEX_ARGS);
void TF_ImportGraphDefOptionsAddReturnOperation_(MEX_ARGS);
void TF_ImportGraphDefOptionsNumReturnOperations_(MEX_ARGS);
void TF_ImportGraphDefResultsReturnOutputs_(MEX_ARGS);
void TF_ImportGraphDefResultsReturnOperations_(MEX_ARGS);
void TF_ImportGraphDefResultsMissingUnusedInputMappings_(MEX_ARGS);
void TF_DeleteImportGraphDefResults_(MEX_ARGS);
void TF_GraphImportGraphDefWithResults_(MEX_ARGS);
void TF_GraphImportGraphDefWithReturnOutputs_(MEX_ARGS);
void TF_GraphImportGraphDef_(MEX_ARGS);
void TF_GraphCopyFunction_(MEX_ARGS);
void TF_GraphNumFunctions_(MEX_ARGS);
void TF_GraphGetFunctions_(MEX_ARGS);
void TF_OperationToNodeDef_(MEX_ARGS);
void TF_NewWhile_(MEX_ARGS);
void TF_FinishWhile_(MEX_ARGS);
void TF_AbortWhile_(MEX_ARGS);
void TF_AddGradients_(MEX_ARGS);
void TF_AddGradientsWithPrefix_(MEX_ARGS);
void TF_GraphToFunction_(MEX_ARGS);
void TF_FunctionName_(MEX_ARGS);
void TF_FunctionToFunctionDef_(MEX_ARGS);
void TF_FunctionImportFunctionDef_(MEX_ARGS);
void TF_FunctionSetAttrValueProto_(MEX_ARGS);
void TF_FunctionGetAttrValueProto_(MEX_ARGS);
void TF_DeleteFunction_(MEX_ARGS);
void TF_TryEvaluateConstant_(MEX_ARGS);
void TF_NewSession_(MEX_ARGS);
void TF_LoadSessionFromSavedModel_(MEX_ARGS);
void TF_CloseSession_(MEX_ARGS);
void TF_DeleteSession_(MEX_ARGS);
void TF_SessionRun_(MEX_ARGS);
void TF_SessionPRunSetup_(MEX_ARGS);
void TF_SessionPRun_(MEX_ARGS);
void TF_DeletePRunHandle_(MEX_ARGS);
void TF_NewDeprecatedSession_(MEX_ARGS);
void TF_CloseDeprecatedSession_(MEX_ARGS);
void TF_DeleteDeprecatedSession_(MEX_ARGS);
void TF_Reset_(MEX_ARGS);
void TF_ExtendGraph_(MEX_ARGS);
void TF_Run_(MEX_ARGS);
void TF_PRunSetup_(MEX_ARGS);
void TF_PRun_(MEX_ARGS);
void TF_SessionListDevices_(MEX_ARGS);
void TF_DeprecatedSessionListDevices_(MEX_ARGS);
void TF_DeleteDeviceList_(MEX_ARGS);
void TF_DeviceListCount_(MEX_ARGS);
void TF_DeviceListName_(MEX_ARGS);
void TF_DeviceListType_(MEX_ARGS);
void TF_DeviceListMemoryBytes_(MEX_ARGS);
void TF_DeviceListIncarnation_(MEX_ARGS);
void TF_LoadLibrary_(MEX_ARGS);
void TF_GetOpList_(MEX_ARGS);
void TF_DeleteLibraryHandle_(MEX_ARGS);
void TF_GetAllOpList_(MEX_ARGS);
void TF_NewApiDefMap_(MEX_ARGS);
void TF_DeleteApiDefMap_(MEX_ARGS);
void TF_ApiDefMapPut_(MEX_ARGS);
void TF_ApiDefMapGet_(MEX_ARGS);
void TF_GetAllRegisteredKernels_(MEX_ARGS);
void TF_GetRegisteredKernelsForOp_(MEX_ARGS);
void TF_NewServer_(MEX_ARGS);
void TF_ServerStart_(MEX_ARGS);
void TF_ServerStop_(MEX_ARGS);
void TF_ServerJoin_(MEX_ARGS);
void TF_ServerTarget_(MEX_ARGS);
void TF_DeleteServer_(MEX_ARGS);
void TF_RegisterLogListener_(MEX_ARGS);

// struct for wrapping interface redirects
typedef struct {
  char* cmd;
  void (*func)(MEX_ARGS);
} command_handle;

// publicly available API functions
static command_handle handles[] = {
  // custom implementations
  { "TFM_Info", TFM_Info },
  { "TFM_NewInput", TFM_NewInput },
  { "TFM_DeleteInput", TFM_DeleteInput },
  { "TFM_NewOutput", TFM_NewOutput },
  { "TFM_DeleteOutput", TFM_DeleteOutput },
  { "TFM_DeleteOperation", TFM_DeleteOperation },
  { "TFM_DeleteOperationDescription", TFM_DeleteOperationDescription },
  { "TFM_SetTensorData", TFM_SetTensorData },
  { "TFM_GetTensorData", TFM_GetTensorData },
  { "TFM_BufferLength", TFM_BufferLength },
  { "TFM_SetBufferData", TFM_SetBufferData },
  { "TFM_GetBufferData", TFM_GetBufferData },
  { "TFM_FileToBuffer", TFM_FileToBuffer },
  { "TFM_BufferToFile", TFM_BufferToFile },
  { "TFM_DeleteWhile", TFM_DeleteWhile },
  // C API functions
  { "TF_Version", TF_Version_ },
  { "TF_DataTypeSize", TF_DataTypeSize_ },
  { "TF_NewStatus", TF_NewStatus_ },
  { "TF_DeleteStatus", TF_DeleteStatus_ },
  { "TF_SetStatus", TF_SetStatus_ },
  { "TF_GetCode", TF_GetCode_ },
  { "TF_Message", TF_Message_ },
  { "TF_NewBufferFromString", TF_NewBufferFromString_ },
  { "TF_NewBuffer", TF_NewBuffer_ },
  { "TF_DeleteBuffer", TF_DeleteBuffer_ },
  { "TF_GetBuffer", TF_GetBuffer_ },
  { "TF_NewTensor", TF_NewTensor_ },
  { "TF_AllocateTensor", TF_AllocateTensor_ },
  { "TF_TensorMaybeMove", TF_TensorMaybeMove_ },
  { "TF_DeleteTensor", TF_DeleteTensor_ },
  { "TF_TensorType", TF_TensorType_ },
  { "TF_NumDims", TF_NumDims_ },
  { "TF_Dim", TF_Dim_ },
  { "TF_TensorByteSize", TF_TensorByteSize_ },
  { "TF_TensorData", TF_TensorData_ },
  { "TF_TensorElementCount", TF_TensorElementCount_ },
  { "TF_TensorBitcastFrom", TF_TensorBitcastFrom_ },
  { "TF_StringEncode", TF_StringEncode_ },
  { "TF_StringDecode", TF_StringDecode_ },
  { "TF_StringEncodedSize", TF_StringEncodedSize_ },
  { "TF_NewSessionOptions", TF_NewSessionOptions_ },
  { "TF_SetTarget", TF_SetTarget_ },
  { "TF_SetConfig", TF_SetConfig_ },
  { "TF_DeleteSessionOptions", TF_DeleteSessionOptions_ },
  { "TF_NewGraph", TF_NewGraph_ },
  { "TF_DeleteGraph", TF_DeleteGraph_ },
  { "TF_GraphSetTensorShape", TF_GraphSetTensorShape_ },
  { "TF_GraphGetTensorNumDims", TF_GraphGetTensorNumDims_ },
  { "TF_GraphGetTensorShape", TF_GraphGetTensorShape_ },
  { "TF_NewOperation", TF_NewOperation_ },
  { "TF_SetDevice", TF_SetDevice_ },
  { "TF_AddInput", TF_AddInput_ },
  { "TF_AddInputList", TF_AddInputList_ },
  { "TF_AddControlInput", TF_AddControlInput_ },
  { "TF_ColocateWith", TF_ColocateWith_ },
  { "TF_SetAttrString", TF_SetAttrString_ },
  { "TF_SetAttrStringList", TF_SetAttrStringList_ },
  { "TF_SetAttrInt", TF_SetAttrInt_ },
  { "TF_SetAttrIntList", TF_SetAttrIntList_ },
  { "TF_SetAttrFloat", TF_SetAttrFloat_ },
  { "TF_SetAttrFloatList", TF_SetAttrFloatList_ },
  { "TF_SetAttrBool", TF_SetAttrBool_ },
  { "TF_SetAttrBoolList", TF_SetAttrBoolList_ },
  { "TF_SetAttrType", TF_SetAttrType_ },
  { "TF_SetAttrTypeList", TF_SetAttrTypeList_ },
  { "TF_SetAttrPlaceholder", TF_SetAttrPlaceholder_ },
  { "TF_SetAttrFuncName", TF_SetAttrFuncName_ },
  { "TF_SetAttrShape", TF_SetAttrShape_ },
  { "TF_SetAttrShapeList", TF_SetAttrShapeList_ },
  { "TF_SetAttrTensorShapeProto", TF_SetAttrTensorShapeProto_ },
  { "TF_SetAttrTensorShapeProtoList", TF_SetAttrTensorShapeProtoList_ },
  { "TF_SetAttrTensor", TF_SetAttrTensor_ },
  { "TF_SetAttrTensorList", TF_SetAttrTensorList_ },
  { "TF_SetAttrValueProto", TF_SetAttrValueProto_ },
  { "TF_FinishOperation", TF_FinishOperation_ },
  { "TF_OperationName", TF_OperationName_ },
  { "TF_OperationOpType", TF_OperationOpType_ },
  { "TF_OperationDevice", TF_OperationDevice_ },
  { "TF_OperationNumOutputs", TF_OperationNumOutputs_ },
  { "TF_OperationOutputType", TF_OperationOutputType_ },
  { "TF_OperationOutputListLength", TF_OperationOutputListLength_ },
  { "TF_OperationNumInputs", TF_OperationNumInputs_ },
  { "TF_OperationInputType", TF_OperationInputType_ },
  { "TF_OperationInputListLength", TF_OperationInputListLength_ },
  { "TF_OperationInput", TF_OperationInput_ },
  { "TF_OperationOutputNumConsumers", TF_OperationOutputNumConsumers_ },
  { "TF_OperationOutputConsumers", TF_OperationOutputConsumers_ },
  { "TF_OperationNumControlInputs", TF_OperationNumControlInputs_ },
  { "TF_OperationGetControlInputs", TF_OperationGetControlInputs_ },
  { "TF_OperationNumControlOutputs", TF_OperationNumControlOutputs_ },
  { "TF_OperationGetControlOutputs", TF_OperationGetControlOutputs_ },
  { "TF_OperationGetAttrMetadata", TF_OperationGetAttrMetadata_ },
  { "TF_OperationGetAttrString", TF_OperationGetAttrString_ },
  { "TF_OperationGetAttrStringList", TF_OperationGetAttrStringList_ },
  { "TF_OperationGetAttrInt", TF_OperationGetAttrInt_ },
  { "TF_OperationGetAttrIntList", TF_OperationGetAttrIntList_ },
  { "TF_OperationGetAttrFloat", TF_OperationGetAttrFloat_ },
  { "TF_OperationGetAttrFloatList", TF_OperationGetAttrFloatList_ },
  { "TF_OperationGetAttrBool", TF_OperationGetAttrBool_ },
  { "TF_OperationGetAttrBoolList", TF_OperationGetAttrBoolList_ },
  { "TF_OperationGetAttrType", TF_OperationGetAttrType_ },
  { "TF_OperationGetAttrTypeList", TF_OperationGetAttrTypeList_ },
  { "TF_OperationGetAttrShape", TF_OperationGetAttrShape_ },
  { "TF_OperationGetAttrShapeList", TF_OperationGetAttrShapeList_ },
  { "TF_OperationGetAttrTensorShapeProto", TF_OperationGetAttrTensorShapeProto_ },
  { "TF_OperationGetAttrTensorShapeProtoList", TF_OperationGetAttrTensorShapeProtoList_ },
  { "TF_OperationGetAttrTensor", TF_OperationGetAttrTensor_ },
  { "TF_OperationGetAttrTensorList", TF_OperationGetAttrTensorList_ },
  { "TF_OperationGetAttrValueProto", TF_OperationGetAttrValueProto_ },
  { "TF_GraphOperationByName", TF_GraphOperationByName_ },
  { "TF_GraphNextOperation", TF_GraphNextOperation_ },
  { "TF_GraphToGraphDef", TF_GraphToGraphDef_ },
  { "TF_GraphGetOpDef", TF_GraphGetOpDef_ },
  { "TF_GraphVersions", TF_GraphVersions_ },
  { "TF_NewImportGraphDefOptions", TF_NewImportGraphDefOptions_ },
  { "TF_DeleteImportGraphDefOptions", TF_DeleteImportGraphDefOptions_ },
  { "TF_ImportGraphDefOptionsSetPrefix", TF_ImportGraphDefOptionsSetPrefix_ },
  { "TF_ImportGraphDefOptionsSetDefaultDevice", TF_ImportGraphDefOptionsSetDefaultDevice_ },
  { "TF_ImportGraphDefOptionsSetUniquifyNames", TF_ImportGraphDefOptionsSetUniquifyNames_ },
  { "TF_ImportGraphDefOptionsSetUniquifyPrefix", TF_ImportGraphDefOptionsSetUniquifyPrefix_ },
  { "TF_ImportGraphDefOptionsAddInputMapping", TF_ImportGraphDefOptionsAddInputMapping_ },
  { "TF_ImportGraphDefOptionsRemapControlDependency", TF_ImportGraphDefOptionsRemapControlDependency_ },
  { "TF_ImportGraphDefOptionsAddControlDependency", TF_ImportGraphDefOptionsAddControlDependency_ },
  { "TF_ImportGraphDefOptionsAddReturnOutput", TF_ImportGraphDefOptionsAddReturnOutput_ },
  { "TF_ImportGraphDefOptionsNumReturnOutputs", TF_ImportGraphDefOptionsNumReturnOutputs_ },
  { "TF_ImportGraphDefOptionsAddReturnOperation", TF_ImportGraphDefOptionsAddReturnOperation_ },
  { "TF_ImportGraphDefOptionsNumReturnOperations", TF_ImportGraphDefOptionsNumReturnOperations_ },
  { "TF_ImportGraphDefResultsReturnOutputs", TF_ImportGraphDefResultsReturnOutputs_ },
  { "TF_ImportGraphDefResultsReturnOperations", TF_ImportGraphDefResultsReturnOperations_ },
  { "TF_ImportGraphDefResultsMissingUnusedInputMappings", TF_ImportGraphDefResultsMissingUnusedInputMappings_ },
  { "TF_DeleteImportGraphDefResults", TF_DeleteImportGraphDefResults_ },
  { "TF_GraphImportGraphDefWithResults", TF_GraphImportGraphDefWithResults_ },
  { "TF_GraphImportGraphDefWithReturnOutputs", TF_GraphImportGraphDefWithReturnOutputs_ },
  { "TF_GraphImportGraphDef", TF_GraphImportGraphDef_ },
  { "TF_GraphCopyFunction", TF_GraphCopyFunction_ },
  { "TF_GraphNumFunctions", TF_GraphNumFunctions_ },
  { "TF_GraphGetFunctions", TF_GraphGetFunctions_ },
  { "TF_OperationToNodeDef", TF_OperationToNodeDef_ },
  { "TF_NewWhile", TF_NewWhile_ },
  { "TF_FinishWhile", TF_FinishWhile_ },
  { "TF_AbortWhile", TF_AbortWhile_ },
  { "TF_AddGradients", TF_AddGradients_ },
  { "TF_AddGradientsWithPrefix", TF_AddGradientsWithPrefix_ },
  { "TF_GraphToFunction", TF_GraphToFunction_ },
  { "TF_FunctionName", TF_FunctionName_ },
  { "TF_FunctionToFunctionDef", TF_FunctionToFunctionDef_ },
  { "TF_FunctionImportFunctionDef", TF_FunctionImportFunctionDef_ },
  { "TF_FunctionSetAttrValueProto", TF_FunctionSetAttrValueProto_ },
  { "TF_FunctionGetAttrValueProto", TF_FunctionGetAttrValueProto_ },
  { "TF_DeleteFunction", TF_DeleteFunction_ },
  { "TF_TryEvaluateConstant", TF_TryEvaluateConstant_ },
  { "TF_NewSession", TF_NewSession_ },
  { "TF_LoadSessionFromSavedModel", TF_LoadSessionFromSavedModel_ },
  { "TF_CloseSession", TF_CloseSession_ },
  { "TF_DeleteSession", TF_DeleteSession_ },
  { "TF_SessionRun", TF_SessionRun_ },
  { "TF_SessionPRunSetup", TF_SessionPRunSetup_ },
  { "TF_SessionPRun", TF_SessionPRun_ },
  { "TF_DeletePRunHandle", TF_DeletePRunHandle_ },
  { "TF_NewDeprecatedSession", TF_NewDeprecatedSession_ },
  { "TF_CloseDeprecatedSession", TF_CloseDeprecatedSession_ },
  { "TF_DeleteDeprecatedSession", TF_DeleteDeprecatedSession_ },
  { "TF_Reset", TF_Reset_ },
  { "TF_ExtendGraph", TF_ExtendGraph_ },
  { "TF_Run", TF_Run_ },
  { "TF_PRunSetup", TF_PRunSetup_ },
  { "TF_PRun", TF_PRun_ },
  { "TF_SessionListDevices", TF_SessionListDevices_ },
  { "TF_DeprecatedSessionListDevices", TF_DeprecatedSessionListDevices_ },
  { "TF_DeleteDeviceList", TF_DeleteDeviceList_ },
  { "TF_DeviceListCount", TF_DeviceListCount_ },
  { "TF_DeviceListName", TF_DeviceListName_ },
  { "TF_DeviceListType", TF_DeviceListType_ },
  { "TF_DeviceListMemoryBytes", TF_DeviceListMemoryBytes_ },
  { "TF_DeviceListIncarnation", TF_DeviceListIncarnation_ },
  { "TF_LoadLibrary", TF_LoadLibrary_ },
  { "TF_GetOpList", TF_GetOpList_ },
  { "TF_DeleteLibraryHandle", TF_DeleteLibraryHandle_ },
  { "TF_GetAllOpList", TF_GetAllOpList_ },
  { "TF_NewApiDefMap", TF_NewApiDefMap_ },
  { "TF_DeleteApiDefMap", TF_DeleteApiDefMap_ },
  { "TF_ApiDefMapPut", TF_ApiDefMapPut_ },
  { "TF_ApiDefMapGet", TF_ApiDefMapGet_ },
  { "TF_GetAllRegisteredKernels", TF_GetAllRegisteredKernels_ },
  { "TF_GetRegisteredKernelsForOp", TF_GetRegisteredKernelsForOp_ },
  { "TF_NewServer", TF_NewServer_ },
  { "TF_ServerStart", TF_ServerStart_ },
  { "TF_ServerStop", TF_ServerStop_ },
  { "TF_ServerJoin", TF_ServerJoin_ },
  { "TF_ServerTarget", TF_ServerTarget_ },
  { "TF_DeleteServer", TF_DeleteServer_ },
  { "TF_RegisterLogListener", TF_RegisterLogListener_ },
  // terminating entry
  { "EXIT", NULL },
};

#endif // TENSORFLOW_M_H
