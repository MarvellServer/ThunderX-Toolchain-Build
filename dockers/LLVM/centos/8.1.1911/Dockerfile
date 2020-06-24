###############################################################################
# DEVEL_LLVM9                                                                  #
###############################################################################
FROM centos:8.1.1911 as devel_llvm9

# install dnf plugins and enable epel repo
RUN dnf -y install dnf-plugins-core epel-release

# enable additional repos
RUN dnf config-manager --set-enabled PowerTools
RUN dnf config-manager --set-enabled extras

# install development packages
RUN dnf -y makecache
RUN dnf -y install \
      automake \
      autoconf \
      libtool \
      m4 \
      gcc \
      gcc-c++ \
      gcc-gfortran \
      patch \
      patchutils \
      diffutils \
      python2-devel \
      python3-devel \
      hwloc \
      openssl-devel \
      numactl \
      numactl-devel \
      openssh-clients \
      git \
      subversion \
      wget \
	pkg-config \
  ca-certificates \
	flex \
	texinfo \
  help2man \
 	unzip \
	make \
	gawk \
	ncurses-devel \
	bison \
	rsync \
	openssl-devel \
  libxml2-devel \
  libedit-devel \
  swig \
  libffi-devel \
  cmake \
  binutils-devel

# update alternatives
RUN alternatives --set python /usr/bin/python3
RUN update-alternatives --install /usr/bin/pydoc          pydoc         /usr/bin/pydoc3         10
RUN update-alternatives --install /usr/bin/python-config  python-config /usr/bin/python3-config 10
RUN update-alternatives --install /usr/bin/pip            pip           /usr/bin/pip3           10

# create build directories
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

# update path
ENV PATH=${INSTALL_PREFIX}/bin:/usr/local/bin:${PATH}

# install rpm tools
RUN dnf -y install rpm-build rpmdevtools

# create tar file
RUN tar -czvf ${BUILD_DIR}/llvm-9.0.0.tar.gz /opt/llvm/9.0.0

# get spec file
COPY llvm.spec ${BUILD_ROOT}/llvm.spec

# build RPMS
RUN rpmbuild --target aarch64 -bb ${BUILD_ROOT}/llvm.spec

# install rpm
RUN mv /opt/llvm /opt/llvm-archive
RUN rpm -ivh /root/rpmbuild/RPMS/aarch64/llvm-9.0.0-20200624.el8.aarch64.rpm

# Test GCC with spec2017
RUN mkdir -p /tmp/spec2017
COPY cpu2017.tar.xz /tmp/spec2017

RUN cd /tmp/spec2017 && \
    tar -xf cpu2017.tar.xz && \
    ./install.sh -f
    
COPY llvm.cfg /tmp/spec2017/config/

ENV LD_LIBRARY_PATH=${INSTALL_PREFIX}/lib:${LD_LIBRARY_PATH}
RUN cd /tmp/spec2017/config && \
    echo "running spec2017" && \
    ../bin/runcpu --define bits=64 --config=llvm.cfg --size=ref --tune=base --rebuild --ignore_errors --iterations=1 --copies=96 --output_format txt 605.mcf_s
#502.gcc_r

FROM devel_llvm9 AS devel
