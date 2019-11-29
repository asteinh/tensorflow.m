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

#include "tensorflow_m_.h"

void mexFunction(MEX_ARGS) {
  if(nrhs == 0) {
    mexPrintf("This is tensorflow.m - the TensorFlow binding for MATLAB. Have a goofy day!\n");
  } else {
    // first argument is command string, representing the C API functions
    char* cmd = mxArrayToString(prhs[0]);
    if(cmd == NULL)
      mexErrMsgTxt("Could not convert input to string.");

    // Dispatch to cmd handler
    bool dispatched = false;
    for(int i = 0; handles[i].func != NULL; i++) {
      if(strcmp(cmd, handles[i].cmd) == 0) {
        handles[i].func(nlhs, plhs, nrhs-1, prhs+1);
        dispatched = true;
        break;
      }
    }

    if(!dispatched) mexErrMsgTxt("Unkown API command.");

    mxFree(cmd);
  }
}
