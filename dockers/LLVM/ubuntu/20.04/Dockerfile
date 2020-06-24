###############################################################################
# DEVEL_LLVM9                                                                  #
###############################################################################
FROM ubuntu:20.04 as devel_llvm9
RUN apt-get update -y && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	wget \
  git \
  automake \
  autoconf \
  libtool \
	m4 \
	pkg-config \
  ca-certificates \
  python \ 
	python-dev \
	flex \
	texinfo \
  help2man \
 	unzip \
	make \
	gawk \
	libtool-bin \
	libncurses5-dev \
	bison \
	rsync \
	libssl-dev \
  libxml2-dev \
  libedit-dev \
  swig \
  libffi-dev \
  cmake \
  binutils-dev \
	python3-pip \
	python3-dev \
	python3-dev && \
	rm -rf /var/lib/apt/lists/*
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1 && \
    update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        g++ \
        gcc \
	      sudo \
        libnuma-dev \
        openssh-client \
        gfortran && \
    rm -rf /var/lib/apt/lists/*

ENV BUILD_DIR=/tmp/llvm
ENV INSTALL_PREFIX=/opt/llvm/9.0.0

# set up ssh keys
COPY github_rsa /root/.ssh/
COPY config /root/.ssh/

# fetch sources : ThunderX-Toolchain-CT-LLVM-9
RUN mkdir -p ${BUILD_DIR}
RUN cd ${BUILD_DIR} && \
    git clone git@github.com:MarvellServer/ThunderX-Toolchain-CT-LLVM-9.git && \
    cd ThunderX-Toolchain-CT-LLVM-9 && \
    git checkout ctt_latest_release

# fetch sources : llvm-project
RUN cd ${BUILD_DIR} && \
    git clone https://github.com/llvm/llvm-project.git && \
    cd llvm-project && \
    git checkout origin/release/9.x

# fetch sources : 
RUN cd ${BUILD_DIR} && \
    git clone git@github.com:MarvellServer/ThunderX-Toolchain-CT-FLANG.git && \
    cd ThunderX-Toolchain-CT-FLANG && \
    git checkout ctt_latest_release

# fetch sources
RUN cd ${BUILD_DIR} && \
    git clone https://github.com/flang-compiler/flang-driver.git && \
    cd flang-driver && \
    git checkout release_90

# sources: copy clang, lld and openmp
RUN cd ${BUILD_DIR} && \
    cp -r llvm-project/clang . && \
    cp -r llvm-project/lld . && \
    cp -r llvm-project/openmp .

# llvm : configure, build and install llvm
RUN cd ${BUILD_DIR}/ThunderX-Toolchain-CT-LLVM-9 && \
    rm -rf build && mkdir -p build && \
    cd build && \
    cmake ../ -DCMAKE_BUILD_TYPE=Release \
              -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
              -DLLVM_ENABLE_PROJECTS='clang;openmp;lld' \
              -DLLVM_TARGETS_TO_BUILD=AArch64 \
              -DCMAKE_C_COMPILER=gcc \
              -DCMAKE_CXX_COMPILER=g++ \
              -DCMAKE_C_FLAGS="-w -fpermissive" \
              -DCMAKE_CXX_FLAGS="-w -fpermissive" && \
    make -j64 | tee llvm-build.log && \
    make install | tee llvm-install.log

# run unit tests
#RUN cd ${BUILD_DIR}//ThunderX-Toolchain-CT-LLVM-9/build && \
#    make check-llvm-unit
#RUN cd ${BUILD_DIR}//ThunderX-Toolchain-CT-LLVM-9/build && \
#    make clang-test
#RUN cd ${BUILD_DIR}//ThunderX-Toolchain-CT-LLVM-9/build && \
#    make check-llvm  

# update environment
ENV LDFLAGS="-Wl,-rpath=${INSTALL_PREFIX}/lib -Wl,-rpath-link=${INSTALL_PREFIX}/lib ${LDFLAGS}"

# build libpgmath
RUN cd ${BUILD_DIR}/ThunderX-Toolchain-CT-FLANG/runtime/libpgmath && \
    rm -rf build && mkdir -p build && \
    cd build && \
    cmake ../ -DCMAKE_BUILD_TYPE=Release \
              -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
              -DCMAKE_C_COMPILER=gcc \
              -DCMAKE_CXX_COMPILER=g++ \
              -DCMAKE_C_FLAGS="-w" \
              -DCMAKE_CXX_FLAGS="-w" && \
    make -j64 | tee libpgmath-build.log && \
    make -j64 install | tee libpgmath-install.log

# build flang-driver
RUN cd ${BUILD_DIR}/flang-driver && \
    rm -rf build && mkdir -p build && \
    cd build && \
    cmake ../ -DCMAKE_BUILD_TYPE=Release \
              -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
              -DLLVM_TARGETS_TO_BUILD=AArch64 \
              -DLLVM_CONFIG=${INSTALL_PREFIX}/bin/llvm-config \
              -DCMAKE_C_COMPILER=gcc \
              -DCMAKE_CXX_COMPILER=g++ \
              -DCMAKE_C_FLAGS="-w" \
              -DCMAKE_CXX_FLAGS="-w" \
              -DGCC_INSTALL_PREFIX=/usr && \
    make -j64 | tee flang-driver-build.log && \
    make -j64 install | tee flang-driver-install.log

# build flang
RUN cd ${BUILD_DIR}/ThunderX-Toolchain-CT-FLANG && \
    rm -rf build && mkdir -p build && \
    cd build && \
    cmake ../ -DCMAKE_BUILD_TYPE=Release \
              -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
              -DLLVM_TARGETS_TO_BUILD=AArch64 \
              -DLLVM_CONFIG=${INSTALL_PREFIX}/bin/llvm-config \
              -DCMAKE_C_COMPILER=${INSTALL_PREFIX}/bin/clang \
              -DCMAKE_CXX_COMPILER=${INSTALL_PREFIX}/bin/clang++ \
              -DCMAKE_Fortran_COMPILER=${INSTALL_PREFIX}/bin/flang \
              -DCMAKE_C_FLAGS="-w" \
              -DCMAKE_CXX_FLAGS="-w" \
              -DCMAKE_Fortran_FLAGS="-w ${LDFLAGS}" \
              -DFLANG_LLVM_EXTENSIONS=ON \
              -DGCC_INSTALL_PREFIX=/usr && \
     make -j64 | tee flang-build.log && \
     make -j64 install | tee flang-install.log

# install deb file dependencies
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install checkinstall build-essential automake autoconf libtool pkg-config libcurl4-openssl-dev intltool libxml2-dev libgtk2.0-dev libnotify-dev libglib2.0-dev libevent-dev

# Copy control file
RUN export TODAY=`date "+%Y%m%d"` && \
    mkdir -p /tmp/flang-9.0.0-ubuntu-20.04-${TODAY}_arm64/DEBIAN
COPY control /tmp/flang-9.0.0-ubuntu-20.04-${TODAY}_arm64/DEBIAN

# create deb file
RUN cd /tmp && \
    mv -v /opt /tmp/flang-9.0.0-ubuntu-20.04-${TODAY}_arm64/ && \
    dpkg-deb --build flang-9.0.0-ubuntu-20.04-${TODAY}_arm64

# Cleanup :
RUN rm -rf ${BUILD_DIR}
RUN rm -rf /opt/llvm

# update path
ENV PATH=${FLANG_INSTALL_PREFIX}/bin:/usr/local/bin:${PATH}

FROM devel_llvm9 AS devel
