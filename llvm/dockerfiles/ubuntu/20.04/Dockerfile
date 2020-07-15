
###############################################################################
# LLVM Source                                                                 #
###############################################################################

FROM centos:8.1.1911 as llvm_source

# install pre-requisites
RUN dnf -y install git

# define env
ENV DIR_BASE=/tmp/llvm
ENV DIR_SOURCE=${DIR_BASE}/source

# set up ssh keys
COPY data/github_rsa /root/.ssh/
COPY data/config /root/.ssh/

# create dirs
RUN mkdir -p ${DIR_BASE}
RUN mkdir -p ${DIR_SOURCE}

# clone repos : ThunderX-Toolchain-CT-LLVM-9
RUN cd ${DIR_SOURCE} && \
    git clone git@github.com:MarvellServer/ThunderX-Toolchain-CT-LLVM-9.git

# clone repos : llvm-project
RUN cd ${DIR_SOURCE} && \
    git clone https://github.com/llvm/llvm-project.git

# clone repos : flang-driver
RUN cd ${DIR_SOURCE} && \
    git clone https://github.com/flang-compiler/flang-driver.git

# clone repos : ThunderX-Toolchain-CT-FLANG
RUN cd ${DIR_SOURCE} && \
    git clone git@github.com:MarvellServer/ThunderX-Toolchain-CT-FLANG.git

# update and checkout : ThunderX-Toolchain-CT-LLVM-9
RUN cd ${DIR_SOURCE}/ThunderX-Toolchain-CT-LLVM-9 && \
    git pull origin && \
    git checkout ctt_latest_release

# update and checkout : llvm-project
RUN cd ${DIR_SOURCE}/llvm-project && \
    git pull origin && \
    git checkout origin/release/9.x

# update and checkout : flang-driver
RUN cd ${DIR_SOURCE}/flang-driver && \
    git pull origin && \
    git checkout release_90

# update and checkout : ThunderX-Toolchain-CT-FLANG
RUN cd ${DIR_SOURCE}/ThunderX-Toolchain-CT-FLANG && \
    git pull origin && \
    git checkout ctt_latest_release

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
# LLVM Build                                                                 #
###############################################################################

# define base
FROM base_ubuntu_20.04 as build_llvm_ubuntu_20.04

# define env
ENV NTHREADS=64
ENV DIR_BASE=/tmp/llvm
ENV DIR_SOURCE=${DIR_BASE}/source
ENV DIR_BUILD=${DIR_BASE}/build

# create directories
RUN mkdir -p ${DIR_BASE}
RUN mkdir -p ${DIR_SOURCE}
RUN mkdir -p ${DIR_BUILD}

# copy sources
COPY --from=llvm_source ${DIR_SOURCE}/ThunderX-Toolchain-CT-LLVM-9 ${DIR_SOURCE}/ThunderX-Toolchain-CT-LLVM-9
COPY --from=llvm_source ${DIR_SOURCE}/llvm-project/clang           ${DIR_SOURCE}/clang
COPY --from=llvm_source ${DIR_SOURCE}/llvm-project/lld             ${DIR_SOURCE}/lld
COPY --from=llvm_source ${DIR_SOURCE}/llvm-project/openmp          ${DIR_SOURCE}/openmp
COPY --from=llvm_source ${DIR_SOURCE}/ThunderX-Toolchain-CT-FLANG  ${DIR_SOURCE}/ThunderX-Toolchain-CT-FLANG
COPY --from=llvm_source ${DIR_SOURCE}/flang-driver                 ${DIR_SOURCE}/flang-driver

# define build config
ENV INSTALL_PREFIX=/opt/llvm/9.0.0

# configure, build and install : ThunderX-Toolchain-CT-LLVM-9
RUN cd ${DIR_BUILD} && \
    mkdir -p ThunderX-Toolchain-CT-LLVM-9 && \
    cd ThunderX-Toolchain-CT-LLVM-9 && \
    cmake ${DIR_SOURCE}/ThunderX-Toolchain-CT-LLVM-9 \
              -DCMAKE_BUILD_TYPE=Release \
              -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
              -DLLVM_ENABLE_PROJECTS='clang;openmp;lld' \
              -DLLVM_TARGETS_TO_BUILD=AArch64 \
              -DCMAKE_C_COMPILER=gcc \
              -DCMAKE_CXX_COMPILER=g++ \
              -DCMAKE_C_FLAGS="-w -fpermissive" \
              -DCMAKE_CXX_FLAGS="-w -fpermissive" && \
    make -j${NTHREADS} | tee llvm-build.log && \
    make install | tee llvm-install.log

# update environment
ENV LDFLAGS="-Wl,-rpath=${INSTALL_PREFIX}/lib -Wl,-rpath-link=${INSTALL_PREFIX}/lib ${LDFLAGS}"

# configure, build and install : libpgmath
RUN cd ${BUILD_DIR} && \
    mkdir libpgmath && \
    cd  libpgmath && \
    cmake ${DIR_SOURCE}/ThunderX-Toolchain-CT-FLANG/runtime/libpgmath \
              -DCMAKE_BUILD_TYPE=Release \
              -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
              -DCMAKE_C_COMPILER=gcc \
              -DCMAKE_CXX_COMPILER=g++ \
              -DCMAKE_C_FLAGS="-w" \
              -DCMAKE_CXX_FLAGS="-w" && \
    make -j${NTHREADS} | tee libpgmath-build.log && \
    make -j${NTHREADS} install | tee libpgmath-install.log

# configure, build and install : flang-driver
RUN cd ${BUILD_DIR} && \
    mkdir flang-driver && \
    cd flang-driver && \
    cmake ${DIR_SOURCE}/flang-driver \
              -DCMAKE_BUILD_TYPE=Release \
              -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
              -DLLVM_TARGETS_TO_BUILD=AArch64 \
              -DLLVM_CONFIG=${INSTALL_PREFIX}/bin/llvm-config \
              -DCMAKE_C_COMPILER=gcc \
              -DCMAKE_CXX_COMPILER=g++ \
              -DCMAKE_C_FLAGS="-w" \
              -DCMAKE_CXX_FLAGS="-w" \
              -DGCC_INSTALL_PREFIX=/usr && \
    make -j${NTHREADS} | tee flang-driver-build.log && \
    make -j${NTHREADS} install | tee flang-driver-install.log

# configure, build and install : flang
RUN cd ${BUILD_DIR} && \
    mkdir ThunderX-Toolchain-CT-FLANG && \
    cd ThunderX-Toolchain-CT-FLANG && \
    cmake ${DIR_SOURCE}/ThunderX-Toolchain-CT-FLANG \
              -DCMAKE_BUILD_TYPE=Release \
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
     make -j${NTHREADS} | tee flang-build.log && \
     make -j${NTHREADS} install | tee flang-install.log

###############################################################################
# ubuntu Packaging                                                            #
###############################################################################

FROM base_ubuntu_20.04 as pkg_llvm_ubuntu_20.04

# arg
ARG DATESTRING=YYYYMMDD

# env
ENV INSTALL_PREFIX=/opt/llvm/9.0.0

# copy install dir
COPY --from=build_llvm_ubuntu_20.04 /opt/llvm /opt/llvm

# Copy control file
COPY data/control /tmp/
RUN sed -i "s/DATESTRING/${DATESTRING}/g" /tmp/control
RUN export ARCH=`dpkg --print-architecture` && \
    mkdir -p /tmp/llvm-9.0.0-${DATESTRING}-ubuntu-20.04_${ARCH}/DEBIAN && \
    mv /tmp/control /tmp/llvm-9.0.0-${DATESTRING}-ubuntu-20.04_${ARCH}/DEBIAN

# create deb file
RUN export ARCH=`dpkg --print-architecture` && \
    cd /tmp && \
    mv -v /opt /tmp/llvm-9.0.0-${DATESTRING}-ubuntu-20.04_${ARCH}/ && \
    dpkg-deb --build llvm-9.0.0-${DATESTRING}-ubuntu-20.04_${ARCH}

# clean-up the package
RUN rm -rf /opt/llvm

# install the deb file
RUN export ARCH=`dpkg --print-architecture` && \
    apt-get -y install /tmp/llvm-9.0.0-${DATESTRING}-ubuntu-20.04_${ARCH}.deb

# install additional packages
RUN apt-get -y install xz-utils

###############################################################################
# SPEC CPU2017                                                                 #
###############################################################################

FROM pkg_llvm_ubuntu_20.04 as spec_llvm_ubuntu_20.04

# env
ENV INSTALL_PREFIX=/opt/llvm/9.0.0

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
COPY data/llvm.cfg /tmp/spec2017/config/

# run spec
RUN cd /tmp/spec2017/config && \
    echo "running spec2017" && \
    ../bin/runcpu --define bits=64 --config=llvm.cfg --size=ref --tune=base --rebuild --ignore_errors --iterations=1 --copies=64 --output_format txt 502.gcc_r
