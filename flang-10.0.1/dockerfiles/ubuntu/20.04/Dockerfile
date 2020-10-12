
###############################################################################
# FLANG Source                                                                 #
###############################################################################

FROM centos:8.1.1911 as flang_source

# install pre-requisites
RUN dnf -y install git

# define env
ENV DIR_BASE=/tmp/flang
ENV DIR_SOURCE=${DIR_BASE}/source

# set up ssh keys
COPY data/github_rsa /root/.ssh/github_rsa
COPY data/ssh_config /root/.ssh/config

# create dirs
RUN mkdir -p ${DIR_BASE}
RUN mkdir -p ${DIR_SOURCE}

# clone repos : llvm-project
RUN cd ${DIR_SOURCE} && \
    git clone https://github.com/flang-compiler/classic-flang-llvm-project.git

# clone repos : flang
RUN cd ${DIR_SOURCE} && \
    git clone https://github.com/flang-compiler/flang.git

# clone repos : openmp
RUN cd ${DIR_SOURCE} && \
    git clone https://github.com/llvm-mirror/openmp.git

# update and checkout : llvm-project
RUN cd ${DIR_SOURCE}/classic-flang-llvm-project && \
    git checkout release_100

# update and checkout : openmp
RUN cd ${DIR_SOURCE}/openmp && \
    git checkout release_90

###############################################################################
# Ubuntu Base                                                                 #
###############################################################################

FROM ubuntu:20.04 as base_ubuntu_20.04

# install development packages
RUN apt-get update -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        automake \
        autoconf \
        libtool \
        m4 \
        gcc \
        g++ \
        gfortran \
        git \
        subversion \
        wget \
        rsync \
        make \
        cmake \
        pkg-config \
        ca-certificates \
        flex \
        texinfo \
        help2man \
        unzip \
        gawk \
        swig \
        bison \
        patch \
        patchutils \
        diffutils \
        hwloc \
        hwloc \
        libnuma-dev\
        python3 \
        python3-pip \
        python3-dev \
        libtool-bin \
        libncurses5-dev \
        bison \
        libssl-dev \
        libxml2-dev \
        libedit-dev \
        libffi-dev \
        binutils-dev \
        sudo \
        openssh-client \
        lbzip2 \
        gettext

# update python defaults
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1 && \
    update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

###############################################################################
# FLANG Build                                                                #
###############################################################################

# define base
FROM base_ubuntu_20.04 as build_flang_ubuntu_20.04

# define env
ENV NTHREADS=64
ENV DIR_BASE=/tmp/flang
ENV DIR_SOURCE=${DIR_BASE}/source
ENV DIR_BUILD=${DIR_BASE}/build

# create directories
RUN mkdir -p ${DIR_BASE}
RUN mkdir -p ${DIR_SOURCE}
RUN mkdir -p ${DIR_BUILD}

# copy sources
COPY --from=flang_source ${DIR_SOURCE}/classic-flang-llvm-project ${DIR_SOURCE}/classic-flang-llvm-project
COPY --from=flang_source ${DIR_SOURCE}/flang           ${DIR_SOURCE}/flang
COPY --from=flang_source ${DIR_SOURCE}/openmp          ${DIR_SOURCE}/openmp

# define build config
ENV INSTALL_PREFIX=/opt/flang/10.0.1

# configure, build and install : classic-flang-llvm
RUN cd ${DIR_BUILD} && \
    mkdir -p llvm-build && \
    cd llvm-build && \
    cmake ${DIR_SOURCE}/classic-flang-llvm-project/llvm \
              -DCMAKE_BUILD_TYPE=Release \
              -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
              -DLLVM_ENABLE_PROJECTS=clang \
              -DLLVM_TARGETS_TO_BUILD=AArch64 \
              -DCMAKE_C_COMPILER=gcc \
              -DCMAKE_CXX_COMPILER=g++ \
	      -DLLVM_ENABLE_CLASSIC_FLANG=ON \
              -DLLVM_CONFIG=$INSTALL_PREFIX/bin/llvm-config \
              -DCMAKE_C_FLAGS="-w -fpermissive" \
              -DCMAKE_CXX_FLAGS="-w -fpermissive" && \
    make -j${NTHREADS} | tee classic-flang-llvm-project-build.log && \
    make install | tee classic-flang-llvm-project-install.log

# update environment
ENV LDFLAGS="-Wl,-rpath=${INSTALL_PREFIX}/lib -Wl,-rpath-link=${INSTALL_PREFIX}/lib ${LDFLAGS}"

# configure, build and install : openmp
RUN cd ${BUILD_DIR} && \
    mkdir openmp-build && \
    cd  openmp-build && \
    cmake ${DIR_SOURCE}/openmp \
              -DCMAKE_BUILD_TYPE=Release \
              -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
              -DLLVM_CONFIG=$INSTALL_PREFIX/bin/llvm-config \
              -DCMAKE_C_COMPILER=$INSTALL_PREFIX/bin/clang \
              -DCMAKE_CXX_COMPILER=$INSTALL_PREFIX/bin/clang++ \
	      -DCMAKE_Fortran_COMPILER=$INSTALL_PREFIX/bin/flang \
              -DLLVM_TARGETS_TO_BUILD=AArch64 \
              -DCMAKE_C_FLAGS="-w" \
              -DCMAKE_CXX_FLAGS="-w" && \
    make -j${NTHREADS} | tee openmp-build.log && \
    make -j${NTHREADS} install | tee openmp-install.log

# configure, build and install : libpgmath
RUN cd ${BUILD_DIR} && \
    mkdir libpgmath-build && \
    cd  libpgmath-build && \
    cmake ${DIR_SOURCE}/flang/runtime/libpgmath \
              -DCMAKE_BUILD_TYPE=Release \
              -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
              -DLLVM_CONFIG=$INSTALL_PREFIX/bin/llvm-config \
              -DCMAKE_C_COMPILER=$INSTALL_PREFIX/bin/clang \
              -DCMAKE_CXX_COMPILER=$INSTALL_PREFIX/bin/clang++ \
	      -DCMAKE_Fortran_COMPILER=$INSTALL_PREFIX/bin/flang \
              -DLLVM_TARGETS_TO_BUILD=AArch64 \
              -DCMAKE_C_FLAGS="-w" \
              -DCMAKE_CXX_FLAGS="-w" && \
    make -j${NTHREADS} | tee libpgmath-build.log && \
    make -j${NTHREADS} install | tee libpgmath-install.log

# configure, build and install : flang
RUN cd ${BUILD_DIR} && \
    mkdir flang-build && \
    cd flang-build && \
    cmake ${DIR_SOURCE}/flang \
              -DCMAKE_BUILD_TYPE=Release \
              -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
              -DLLVM_CONFIG=$INSTALL_PREFIX/bin/llvm-config \
              -DCMAKE_C_COMPILER=$INSTALL_PREFIX/bin/clang \
              -DCMAKE_CXX_COMPILER=$INSTALL_PREFIX/bin/clang++ \
	      -DCMAKE_Fortran_COMPILER=$INSTALL_PREFIX/bin/flang \
              -DLLVM_TARGETS_TO_BUILD=AArch64 \
              -DCMAKE_Fortran_FLAGS="-w ${LDFLAGS}" \
	      -DFLANG_LLVM_EXTENSIONS=ON \
              -DCMAKE_C_FLAGS="-w" \
              -DCMAKE_CXX_FLAGS="-w" && \
    make -j${NTHREADS} | tee flang-build.log && \
    make -j${NTHREADS} install | tee flang-install.log

###############################################################################
# ubuntu Packaging                                                            #
###############################################################################

FROM base_ubuntu_20.04 as pkg_flang_ubuntu_20.04

# arg
ARG DATESTRING=YYYYMMDD

# env
ENV INSTALL_PREFIX=/opt/flang/10.0.1
ENV PKG_NAME=flang-10.0.1

# copy install dir
COPY --from=build_flang_ubuntu_20.04 /opt/flang /opt/flang

# Copy control file
COPY data/control /tmp/
RUN sed -i "s/DATESTRING/${DATESTRING}/g" /tmp/control
RUN export ARCH=`dpkg --print-architecture` && \
    mkdir -p /tmp/${PKG_NAME}-${DATESTRING}-ubuntu-20.04_${ARCH}/DEBIAN && \
    mv /tmp/control /tmp/${PKG_NAME}-${DATESTRING}-ubuntu-20.04_${ARCH}/DEBIAN

# create deb file
RUN export ARCH=`dpkg --print-architecture` && \
    cd /tmp && \
    mv -v /opt /tmp/${PKG_NAME}-${DATESTRING}-ubuntu-20.04_${ARCH}/ && \
    dpkg-deb --build ${PKG_NAME}-${DATESTRING}-ubuntu-20.04_${ARCH}

# clean-up the package
RUN rm -rf /opt/flang

# install the deb file
RUN export ARCH=`dpkg --print-architecture` && \
    apt-get -y install /tmp/${PKG_NAME}-${DATESTRING}-ubuntu-20.04_${ARCH}.deb

# install additional packages
RUN apt-get -y install xz-utils

###############################################################################
# SPEC CPU2017                                                                 #
###############################################################################

FROM pkg_flang_ubuntu_20.04 as spec_flang_ubuntu_20.04

# env
ENV INSTALL_PREFIX=/opt/flang/10.0.1

# update paths
ENV PATH=${INSTALL_PREFIX}/bin:/usr/local/bin:${PATH}

# copy spec files
RUN mkdir -p /tmp/spec2017
COPY data/cpu2017.tar.xz /tmp/spec2017

# extract
RUN cd /tmp/spec2017 && \
    tar -xf cpu2017.tar.xz && \
    ./install.sh -f

# copy config file
COPY data/flang.cfg /tmp/spec2017/config/
COPY data/gcc-arm.xml /tmp/spec2017/config/
COPY data/llvm.xml /tmp/spec2017/config/

# run spec
RUN cd /tmp/spec2017/config && \
    echo "running spec2017" && \
    ../bin/runcpu --define bits=64 --config=flang.cfg --size=ref --tune=base --rebuild --ignore_errors --iterations=1 --copies=1 --output_format txt 548.exchange2_r && \
    clang --version && \
    flang --version && \
    llc --version

