###############################################################################
# build mavell flang 9.0.1                                                    #
###############################################################################
FROM centos:8.1.1911 as devel_flang-9.0.1

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
      rpm-build \
      rpmdevtools \
      binutils-devel

# update alternatives
RUN alternatives --set python /usr/bin/python3
RUN update-alternatives --install /usr/bin/pydoc          pydoc         /usr/bin/pydoc3         10
RUN update-alternatives --install /usr/bin/python-config  python-config /usr/bin/python3-config 10
RUN update-alternatives --install /usr/bin/pip            pip           /usr/bin/pip3           10

# define local vars
ENV LLVM_VERSION=9.0.0
ENV FLANG_LLVM_RELEASE=release_90
ENV INSTALL_ROOT=/opt/llvm
ENV GCC_INSTALL_PREFIX=/usr
ENV BUILD_ROOT=/tmp/llvm-${LLVM_VERSION}
ENV INSTALL_PREFIX=${INSTALL_ROOT}/${LLVM_VERSION}

# LLVM : fetch source
RUN mkdir -p ${BUILD_ROOT} && \
  cd ${BUILD_ROOT} && \
  git clone --depth 1 https://github.com/flang-compiler/llvm.git -b ${FLANG_LLVM_RELEASE}

# LLVM : configure
RUN cd ${BUILD_ROOT}/llvm && \
  rm -rf build-${FLANG_LLVM_RELEASE} && mkdir -p build-${FLANG_LLVM_RELEASE} && cd build-${FLANG_LLVM_RELEASE} && \
  cmake ../ -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -DLLVM_TARGETS_TO_BUILD=AArch64 \
    -DCMAKE_C_COMPILER=gcc \
    -DCMAKE_CXX_COMPILER=g++ \
    -DCMAKE_C_FLAGS="-w" \
    -DCMAKE_CXX_FLAGS="-w"

# LLVM : build and install
RUN cd ${BUILD_ROOT}/llvm/build-${FLANG_LLVM_RELEASE} &&\
  make -j && \
  make -j install

# LLVM : cleanup
RUN rm -rf ${BUILD_ROOT}/llvm

# FLANG-DRIVER : fetch source
RUN mkdir -p ${BUILD_ROOT} && \
  cd ${BUILD_ROOT} && \
  git clone --depth 1 https://github.com/flang-compiler/flang-driver.git -b ${FLANG_LLVM_RELEASE}

# FLANG-DRIVER : configure
RUN cd ${BUILD_ROOT}/flang-driver && \
  rm -rf build-${FLANG_LLVM_RELEASE} && mkdir -p build-${FLANG_LLVM_RELEASE} && cd build-${FLANG_LLVM_RELEASE} && \
  cmake ../ -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -DLLVM_TARGETS_TO_BUILD=AArch64 \
    -DLLVM_CONFIG=${INSTALL_PREFIX}/bin/llvm-config \
    -DCMAKE_C_COMPILER=gcc \
    -DCMAKE_CXX_COMPILER=g++ \
    -DCMAKE_C_FLAGS="-w" \
    -DCMAKE_CXX_FLAGS="-w" \
    -DGCC_INSTALL_PREFIX=${GCC_INSTALL_PREFIX}

# FLANG-DRIVER : build and install
RUN cd ${BUILD_ROOT}/flang-driver/build-${FLANG_LLVM_RELEASE} && \
  make -j && \
  make -j install

# FLANG-DRIVER : cleanup
RUN rm -rf ${BUILD_ROOT}/flang-driver

# OPENMP : fetch source
RUN mkdir -p ${BUILD_ROOT} && \
  cd ${BUILD_ROOT} && \
  git clone --depth 1 https://github.com/llvm-mirror/openmp.git -b ${FLANG_LLVM_RELEASE}

# OPENMP : configure
RUN cd ${BUILD_ROOT}/openmp && \
  rm -rf build-${FLANG_LLVM_RELEASE} && mkdir -p build-${FLANG_LLVM_RELEASE} && cd build-${FLANG_LLVM_RELEASE} && \
  cmake ../ -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -DCMAKE_C_COMPILER=${INSTALL_PREFIX}/bin/clang \
    -DCMAKE_CXX_COMPILER=${INSTALL_PREFIX}/bin/clang++ \
    -DCMAKE_C_FLAGS="-w" \
    -DCMAKE_CXX_FLAGS="-w"

# OPENMP : build and install
RUN cd ${BUILD_ROOT}/openmp/build-${FLANG_LLVM_RELEASE} && \
  make -j && \
  make -j install

# OPENMP : cleanup
RUN rm -rf ${BUILD_ROOT}/openmp

# FLANG : fetch source
RUN mkdir -p ${BUILD_ROOT} && \
  cd ${BUILD_ROOT} && \
  git clone --depth 1 https://github.com/flang-compiler/flang.git

# PGMATH : configure
RUN cd ${BUILD_ROOT}/flang/runtime/libpgmath && \
  rm -rf build-${FLANG_LLVM_RELEASE} && mkdir -p build-${FLANG_LLVM_RELEASE} && cd build-${FLANG_LLVM_RELEASE} && \
  cmake ../ -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -DCMAKE_C_COMPILER=gcc \
    -DCMAKE_CXX_COMPILER=g++ \
    -DCMAKE_C_FLAGS="-w" \
    -DCMAKE_CXX_FLAGS="-w"

# PGMATH : build and install
RUN cd ${BUILD_ROOT}/flang/runtime/libpgmath/build-${FLANG_LLVM_RELEASE} && \
  make -j && \
  make -j install

# FLANG : update env
ENV LDFLAGS="-Wl,-rpath=${INSTALL_PREFIX}/lib -Wl,-rpath-link=${INSTALL_PREFIX}/lib ${LDFLAGS}"

# FLANG : configure
RUN cd ${BUILD_ROOT}/flang/ && \
  rm -rf build-${FLANG_LLVM_RELEASE} && mkdir -p build-${FLANG_LLVM_RELEASE} && cd build-${FLANG_LLVM_RELEASE} && \
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
    -DFLANG_LLVM_EXTENSIONS=ON

# FLANG : build and install
RUN cd ${BUILD_ROOT}/flang/build-${FLANG_LLVM_RELEASE} && \
  make -j && \
  make -j install

# FLANG : cleanup
RUN rm -rf ${BUILD_ROOT}

# Build marvell Release of LLVM/FLANG -s1
ENV BUILD_ROOT=/tmp/flang-marvell
ENV INSTALL_ROOT=/opt/llvm
ENV FLANG_MRVL_VERSION=9.0.1
ENV GCC_RUNPATH=/usr/lib/gcc/aarch64-linux-gnu/8
ENV CMAKE_PATH=/usr/bin/cmake
ENV GMAKE_PATH=/usr/bin/make
ENV FLANG_INSTALL_PREFIX=${INSTALL_ROOT}/${FLANG_MRVL_VERSION}-s1

# MRVL_FLANG : fetch source
RUN mkdir -p ${BUILD_ROOT} && \
  cd ${BUILD_ROOT} && \
  git clone --depth 1 https://github.com/MarvellServer/ThunderX-Toolchain-flang9.git flang9

###############################################################################
# This is the place to apply the patch.                                       #
# After you apply the patch, please also change the PKG_NAME below            #
###############################################################################
COPY data/flang9-tx3-patch ${BUILD_ROOT}/flang9
COPY data/flang9-tbl-patch ${BUILD_ROOT}/flang9

RUN cd ${BUILD_ROOT}/flang9 && \
#    git apply flang9-tx3-patch && \
    git apply flang9-tx3-patch
#    git apply flang9-tbl-patch

# MRVL_FLANG : s1 : update Makefile
RUN cd ${BUILD_ROOT} && \
  rm -rf Makefile.build build Makefile.build-s1 build-s1 && \
  cp flang9/Makefile.build . && \
  sed -i "s#^CC = .*#CC = gcc#" Makefile.build && \
  sed -i "s#^CXX = .*#CXX = g++#" Makefile.build && \
  sed -i "s#^FC = .*#FC = ${INSTALL_ROOT}/9.0.0/bin/flang#" Makefile.build && \
  sed -i "s#^GCC_RUNPATH = .*#GCC_RUNPATH = ${GCC_RUNPATH}#" Makefile.build && \
  sed -i "s#^CMAKE_PREFIX = .*#CMAKE_PREFIX = ${FLANG_INSTALL_PREFIX}#" Makefile.build && \
  sed -i "s#^CMAKE = .*#CMAKE = ${CMAKE_PATH}#" Makefile.build && \
  sed -i "s#^GMAKE = .*#GMAKE = ${GMAKE_PATH}#" Makefile.build && \
  sed -i "s#^LIBFFI_INCDIR = .*#\#LIBFFI_INCDIR = #" Makefile.build && \
  sed -i "s#^GFLAG = -g#GFLAG = -w#" Makefile.build && \
  sed -i "s#CMAKE_VERBOSE_MAKEFILE:BOOL=ON#CMAKE_VERBOSE_MAKEFILE:BOOL=OFF#" Makefile.build && \
  sed -i "115iCMAKE_OPTIONS += -DGCC_INSTALL_PREFIX:FILEPATH=${GCC_INSTALL_PREFIX}" Makefile.build && \
  sed -i "s#/usr/bin/gmake#/usr/bin/make#" Makefile.build && \
  sed -i "s#/usr/bin/env -##" Makefile.build

# MRVL_FLANG : s1 : configure, build and install
RUN cd ${BUILD_ROOT} && \
  make -f Makefile.build configure && \
  cd build && \
  make -j32 && \
  make -j install

# Build marvell Release of LLVM - s2
ENV FLANG_INSTALL_PREFIX=${INSTALL_ROOT}/${FLANG_MRVL_VERSION}

# MRVL_FLANG : s2 : update Makefile
RUN cd ${BUILD_ROOT} && \
  mv Makefile.build Makefile.build-s1 && \
  mv build build-s1 && \
  cp flang9/Makefile.build . && \
  sed -i "s#^CC = .*#CC = gcc#" Makefile.build && \
  sed -i "s#^CXX = .*#CXX = g++#" Makefile.build && \
  sed -i "s#^FC = .*#FC = ${INSTALL_ROOT}/${FLANG_MRVL_VERSION}-s1/bin/flang#" Makefile.build && \
  sed -i "s#^GCC_RUNPATH = .*#GCC_RUNPATH = ${GCC_RUNPATH}#" Makefile.build && \
  sed -i "s#^CMAKE_PREFIX = .*#CMAKE_PREFIX = ${FLANG_INSTALL_PREFIX}#" Makefile.build && \
  sed -i "s#^CMAKE = .*#CMAKE = ${CMAKE_PATH}#" Makefile.build && \
  sed -i "s#^GMAKE = .*#GMAKE = ${GMAKE_PATH}#" Makefile.build && \
  sed -i "s#^LIBFFI_INCDIR = .*#\#LIBFFI_INCDIR = #" Makefile.build && \
  sed -i "s#^GFLAG = -g#GFLAG = -w#" Makefile.build && \
  sed -i "s#CMAKE_VERBOSE_MAKEFILE:BOOL=ON#CMAKE_VERBOSE_MAKEFILE:BOOL=OFF#" Makefile.build && \
  sed -i "115iCMAKE_OPTIONS += -DGCC_INSTALL_PREFIX:FILEPATH=${GCC_INSTALL_PREFIX}" Makefile.build && \
  sed -i "s#/usr/bin/gmake#/usr/bin/make#" Makefile.build && \
  sed -i "s#/usr/bin/env -##" Makefile.build

# MRVL_FLANG : s2 : configure, build and install
RUN cd ${BUILD_ROOT} && \
  make -f Makefile.build configure && \
  cd build && \
  make -j32 && \
  make -j install

# Cleanup :
RUN rm -rf ${INSTALL_ROOT}/9.0.0 && \
  rm -rf ${INSTALL_ROOT}/9.0.1-s1 && \
  rm -rf ${BUILD_ROOT}

# update path
ENV PATH=${FLANG_INSTALL_PREFIX}/bin:${PATH}

#ENV PKG_NAME=flang-9.0.1-tx3-tbl
ENV PKG_NAME=flang-9.0.1-tx3
#ENV PKG_NAME=flang-9.0.1

RUN sed -i "s#env python#env python3#" ${FLANG_INSTALL_PREFIX}/share/opt-viewer/opt-viewer.py && \
    sed -i "s#env python#env python3#" ${FLANG_INSTALL_PREFIX}/share/opt-viewer/optrecord.py && \
    sed -i "s#env python#env python3#" ${FLANG_INSTALL_PREFIX}/share/opt-viewer/opt-stats.py && \
    sed -i "s#env python#env python3#" ${FLANG_INSTALL_PREFIX}/share/opt-viewer/opt-diff.py && \
    sed -i "s#env python#env python3#" ${FLANG_INSTALL_PREFIX}/share/clang/clang-format-diff.py && \
    sed -i "s#env python#env python3#" ${FLANG_INSTALL_PREFIX}/bin/git-clang-format && \
    sed -i "s#env python#env python3#" ${FLANG_INSTALL_PREFIX}/bin/hmaptool && \
    sed -i "s#env python#env python3#" ${FLANG_INSTALL_PREFIX}/bin/scan-view

RUN cd /opt && \
    export TODAY=`date "+%Y%m%d"` && \
    tar -czvf ${PKG_NAME}-${TODAY}.tar.gz llvm/

RUN cd /root && \
    rpmdev-setuptree

COPY /data/flang.spec /root/rpmbuild/SPECS
RUN export TODAY=`date "+%Y%m%d"` && \
    sed -i "s#REPLACE_TODAY#${TODAY}#" /root/rpmbuild/SPECS/flang.spec

RUN cd /root/rpmbuild/SOURCES && \
    export TODAY=`date "+%Y%m%d"` && \
    cp /opt/${PKG_NAME}-${TODAY}.tar.gz ./ && \
    cd ../SPECS && \
    QA_RPATHS=$[ 0x0002 ] rpmbuild -bb flang.spec

#Start of run the test
RUN mv /opt/llvm /opt/llvm_build && \
    cd /root/rpmbuild/RPMS/aarch64 && \
    export TODAY=`date "+%Y%m%d"` && \
    ls -l *.rpm && \
    rpm -ivh ${PKG_NAME}-${TODAY}-0.el8.aarch64.rpm


#a quick simple test of gcc after installation
RUN cd /tmp && \
    echo -e "#include <stdio.h>  \\n int main() { printf(\"hello world\"); return 0;} " > hello.c

RUN cd /tmp && \
    clang -mcpu=thunderx3t110 -march=armv8.1-a+lse hello.c -o hello.out && \
    ./hello.out && \
    clang --version && \
    flang --version

RUN ls -l /root/rpmbuild/RPMS/aarch64/*.rpm && \
    echo "We stop here so that you can copy the rpm file out of docker container" && \
    echo "You can find the package at /root/rpmbuild/RPMS/aarch64"
FROM devel_flang-9.0.1 AS devel
