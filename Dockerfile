FROM quay.io/pypa/manylinux2014_x86_64
LABEL maintainer="Shamil K (noteness@riseup.net)"

RUN yum -y install cmake wget openssl-devel

WORKDIR /root/cmake
ARG CMAKE_VERSION="3.26.4"

RUN wget -q "https://github.com/Kitware/CMake/releases/download/v3.26.4/cmake-${CMAKE_VERSION}.tar.gz" && tar -xf "cmake-${CMAKE_VERSION}.tar.gz"

WORKDIR "/root/cmake/cmake-${CMAKE_VERSION}"
RUN cmake -DCMAKE_BUILD_TYPE=Release . && make -j"$(nproc)" && make install

WORKDIR /root/ninja
ARG NINJA_VERSION="1.11.1"
RUN wget -q "https://github.com/ninja-build/ninja/archive/refs/tags/v${NINJA_VERSION}.tar.gz" && tar -xf "v${NINJA_VERSION}.tar.gz"
WORKDIR "/root/ninja/ninja-${NINJA_VERSION}"
RUN cmake -DCMAKE_BUILD_TYPE=Release -Bbuild && cmake --build build -j"$(nproc)" && cmake --install build

WORKDIR /root/llvm
ARG LLVM_VERSION="12.0.1"
RUN wget -q "https://github.com/llvm/llvm-project/releases/download/llvmorg-12.0.1/llvm-${LLVM_VERSION}.src.tar.xz" && tar -xf "llvm-${LLVM_VERSION}.src.tar.xz"
WORKDIR /root/llvm/llvm-12.0.1.src/build
RUN cmake -G Ninja -DCMAKE_BUILD_TYPE=Release ../ && ninja && cmake --install .

RUN rm -rf /root/*

COPY entrypoint /usr/local/bin/entrypoint

WORKDIR /

ENTRYPOINT ["entrypoint"]
CMD ["/bin/bash"]

