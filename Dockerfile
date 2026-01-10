FROM ubuntu:22.04
 
# Set environment variables for non-interactive installs
ENV DEFAULT_DIR=/root/CXL
ENV DEBIAN_FRONTEND=noninteractive
ENV CXL_PATH=/root/CXL
ENV LLVM_SRC_DIR=${DEFAULT_DIR}/llvm-project
ENV LLVM_BUILD_DIR=${LLVM_SRC_DIR}/build

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    curl \
    python2 \
    python3 \
    python3-pip \
    git \
    vim \
    gcc-9 \
    g++-9 \
    libtbb-dev \
    libnuma-dev \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python python /usr/bin/python2 10

RUN mkdir $DEFAULT_DIR
WORKDIR $DEFAULT_DIR

# Download and extract LLVM 20
RUN git clone https://github.com/llvm/llvm-project.git
WORKDIR $LLVM_SRC_DIR
RUN git checkout e14827f0828d14ef17ab76316e8449d1b76e2617

# Build LLVM
WORKDIR $LLVM_SRC_DIR
RUN mkdir -p $LLVM_BUILD_DIR && cd $LLVM_BUILD_DIR && \
    cmake ../llvm \
    -DCMAKE_C_COMPILER=gcc-9 \
    -DCMAKE_CXX_COMPILER=g++-9 \
    -DCMAKE_BUILD_TYPE="Release" \
    -DLLVM_ENABLE_PROJECTS="clang;lld" \
	-DLLVM_TARGETS_TO_BUILD="X86" \
	&& make -j 4

# Download cxlmcpass
WORKDIR $LLVM_SRC_DIR/llvm/lib/Transforms
RUN git clone https://github.com/uci-plrg/cxlmcpass.git CXLMCPass
RUN cd CXLMCPass && git checkout 58e8a2397919cbbff97dd7d3052c4a955b5fd675
RUN echo "add_subdirectory(CXLMCPass)" >> $LLVM_SRC_DIR/llvm/lib/Transforms/CMakeLists.txt

# Build cxlmcpass
WORKDIR $LLVM_SRC_DIR
RUN cd $LLVM_BUILD_DIR && \
    cmake ../llvm \
	&& make -j 4 CXLMCPass

# Download cxlmc
WORKDIR $DEFAULT_DIR
RUN git clone https://github.com/uci-plrg/cxlmc.git
RUN cd cxlmc && git checkout 6ffe2b545ebe4e0cc2922ff0e34e8e7cb1e3fde5

# Download cxlbench
WORKDIR $DEFAULT_DIR
RUN git clone https://github.com/uci-plrg/cxlbench.git
RUN cd cxlbench && git checkout 68ad0ed4c09334ab784c575bf27fd9d4c1b58e2f

# Copy files
COPY build_benchmark.sh build_tools.sh run_bugs.sh run_perf.sh ./ 
