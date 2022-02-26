From tensorflow/tensorflow:devel

Run apt update -y && \
    apt upgrade -y

# install opencv
RUN apt-get install libopencv-dev python3-opencv -y

# install camke
ARG CMAKE_VERSION=3.22.2
ARG CMAKE_FOLDER=/opt/cmake
RUN wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-Linux-x86_64.sh \
    -q -O /tmp/cmake-install.sh \
    && chmod u+x /tmp/cmake-install.sh \
    && mkdir ${CMAKE_FOLDER} \
    && /tmp/cmake-install.sh --skip-license --prefix=${CMAKE_FOLDER} \
    && rm /tmp/cmake-install.sh \
    && ln -s /opt/cmake/bin/cmake /usr/bin/cmake

WORKDIR /tensorflow_src
ARG TENSORFLOW_TAG=v2.8.0
RUN git fetch --tags \
    && git checkout ${TENSORFLOW_TAG}
RUN echo "/usr/bin/python3" | ./configure
RUN bazel build -c opt //tensorflow/lite:libtensorflowlite.so

WORKDIR /workspace
RUN git clone https://github.com/karthickai/tflite.git
RUN cp /tensorflow_src/bazel-bin/tensorflow/lite/libtensorflowlite.so \
    ./tflite/tflite-dist/libs/linux_x64
RUN cp -r /tensorflow_src/tensorflow/core/util \
    ./tflite/tflite-dist/include/tensorflow/core
RUN cp -r /tensorflow_src/tensorflow/lite \
    ./tflite/tflite-dist/include/tensorflow