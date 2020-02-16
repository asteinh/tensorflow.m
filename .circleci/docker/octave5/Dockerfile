FROM asteinh/docker:tensorflowm-octave5-base

MAINTAINER asteinh

# obtain: /home/cibuild/REPOSITORY-CONTENT
COPY project/ ./

RUN sudo chown -R octave:octave *

# fetch libraries
RUN curl https://storage.googleapis.com/tensorflow/libtensorflow/libtensorflow-cpu-linux-x86_64-1.15.0.tar.gz -o libtensorflow-cpu-linux-x86_64-1.15.0.tar.gz && \
    mkdir -p tensorflow/mex/third_party/libtensorflow-cpu-linux-x86_64-1.15.0 && \
    tar -xzf libtensorflow-cpu-linux-x86_64-1.15.0.tar.gz -C tensorflow/mex/third_party/libtensorflow-cpu-linux-x86_64-1.15.0 && \
    rm libtensorflow-cpu-linux-x86_64-1.15.0.tar.gz

WORKDIR tensorflow/

RUN octave --eval "setup();"

ENTRYPOINT ["/bin/bash"]
