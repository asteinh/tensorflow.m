FROM asteinh/docker:tensorflowm-octave5-base

MAINTAINER asteinh

# obtain: /home/cibuild/REPOSITORY-CONTENT
COPY project/* ./

WORKDIR tensorflow/

# fetch libraries
ADD https://storage.googleapis.com/tensorflow/libtensorflow/libtensorflow-cpu-linux-x86_64-1.15.0.tar.gz ./
RUN tar -xzf libtensorflow-cpu-linux-x86_64-1.15.0.tar.gz -C ./mex/third_party/ && \
    rm libtensorflow-cpu-linux-x86_64-1.15.0.tar.gz

RUN octave --eval "setup();"

ENTRYPOINT ["/bin/bash"]
