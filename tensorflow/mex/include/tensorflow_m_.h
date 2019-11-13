#ifndef TENSORFLOW_M_H
#define TENSORFLOW_M_H

#include "mex.h"
#include "tensorflow/c/c_api.h"

#define NOT_IMPLEMENTED mexErrMsgTxt("Not implemented.");
#define NOT_SUPPORTED   mexErrMsgTxt("Not supported.");
#define NOT_TESTED      mexWarnMsgTxt("Implementation untested!");

#define STRCMP(X, Y) (strcmp(X, Y) == 0 ? true : false)
#define MIN(X, Y) (((X) < (Y)) ? (X) : (Y))

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
  if(!ptr) mexErrMsgTxt("Invalid handle.");
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

#endif // TENSORFLOW_M_H
