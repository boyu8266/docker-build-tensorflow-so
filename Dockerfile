ARG GCC_VERSION=10
FROM gcc:$GCC_VERSION

# Update
RUN apt update && \
    apt upgrade -y

# GCC
ARG CMAKE_VERSION=3.22.2
RUN wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-Linux-x86_64.sh \
      -q -O /tmp/cmake-install.sh \
      && chmod u+x /tmp/cmake-install.sh \
      && mkdir /usr/bin/cmake \
      && /tmp/cmake-install.sh --skip-license --prefix=/usr/bin/cmake \
      && rm /tmp/cmake-install.sh
ENV PATH="/usr/bin/cmake/bin:${PATH}"

# Git
RUN apt install git -y

# Python
RUN apt install python3 python3-dev python3-pip -y
RUN pip3 install numpy wheel

# BAZEL
ARG BAZEL_VERSION=3.1.0
RUN curl -L -o bazel-installer.sh https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh
RUN chmod +x bazel-installer.sh && ./bazel-installer.sh && rm -f ./bazel-installer.sh
RUN mkdir -p /usr/local/lib/bazel/bin
RUN cd /usr/local/lib/bazel/bin && curl -fLO https://releases.bazel.build/${BAZEL_VERSION}/release/bazel-${BAZEL_VERSION}-linux-x86_64 && chmod +x bazel-${BAZEL_VERSION}-linux-x86_64

# upgrade
RUN apt upgrade -y

# Tensorflow Repo
ARG WORKSPACE=/home/workspace
ARG TF_TAG=v2.4.2
RUN mkdir ${WORKSPACE} && \
    cd ${WORKSPACE} && \
    git clone -b ${TF_TAG} --single-branch --depth 1 https://github.com/tensorflow/tensorflow.git
RUN cd ${WORKSPACE}/tensorflow && echo "/usr/bin/python3" | ./configure
RUN cd ${WORKSPACE}/tensorflow && bazel build -c opt //tensorflow/lite:libtensorflowlite.so

# Sample Repo
RUN cd ${WORKSPACE} && git clone https://github.com/karthickai/tflite.git

# Copy so file
RUN cp ${WORKSPACE}/tensorflow/bazel-bin/tensorflow/lite/libtensorflowlite.so \
    ${WORKSPACE}/tflite/tflite-dist/libs/linux_x64