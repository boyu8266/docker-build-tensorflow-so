FROM tensorflow/tensorflow:devel

ARG TENSORFLOW_TAG=v2.8.0
ARG CMAKE_VERSION=3.22.2
ENV SRC /tensorflow_src
ENV WORKSPACE /workspace

# update & upgrade
RUN apt-get update -y && \
apt-get upgrade -y
# install CMake
RUN wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-Linux-x86_64.sh \
    -q -O /tmp/cmake-install.sh \
    && chmod u+x /tmp/cmake-install.sh \
    && mkdir /opt/cmake \
    && /tmp/cmake-install.sh --skip-license --prefix=/opt/cmake \
    && ln -s /opt/cmake/bin/cmake /usr/bin/cmake \
    && rm /tmp/cmake-install.sh
# install OpenCv
RUN apt-get install libopencv-dev python3-opencv -y

WORKDIR ${SRC}
# checkout specific tag
RUN git fetch --tags && \ 
git checkout ${TENSORFLOW_TAG}
# setup config
RUN echo "/usr/bin/python" | ./configure
# build so file
RUN && bazel build -c opt //tensorflow/lite:libtensorflowlite.so

WORKDIR ${WORKSPACE}
# Sample Repo
RUN git clone https://github.com/karthickai/tflite.git
# Copy so file
RUN cp ${SRC}/bazel-bin/tensorflow/lite/libtensorflowlite.so \
${WORKSPACE}/tflite/tflite-dist/libs/linux_x64

ENTRYPOINT ["cd ${WORKSPACE}/tflite"]
