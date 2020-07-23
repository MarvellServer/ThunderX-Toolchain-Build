
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

# clone repos : llvm-project
RUN cd ${DIR_SOURCE} && \
    git clone https://github.com/llvm/llvm-project.git

# update and checkout : llvm-project
RUN cd ${DIR_SOURCE}/llvm-project && \
    git pull origin && \
    git checkout llvmorg-10.0.1

###############################################################################
# Ubuntu Base                                                                 #
###############################################################################

FROM ubuntu:18.04 as base_ubuntu_18.04

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
# LLVM Build                                                                  #
###############################################################################

# define base
FROM base_ubuntu_18.04 as build_llvm_ubuntu_18.04

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
COPY --from=llvm_source ${DIR_SOURCE}/llvm-project ${DIR_SOURCE}/llvm-project

# define build config
ENV INSTALL_PREFIX=/opt/llvm/10.0.1
ENV GCC_INSTALL_PREFIX=/usr

# configure, build and install : llvm-project
RUN cd ${DIR_BUILD} && \
    mkdir -p llvm-project && \
    cd llvm-project && \
    cmake -G "Unix Makefiles" \
          -DLLVM_ENABLE_PROJECTS=clang \
          -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
          -DCMAKE_BUILD_TYPE=Release \
          -DLLVM_TARGETS_TO_BUILD=AArch64 \
#         -DLLVM_HOST_TRIPLE=${TRIPLET_HOST} \
#         -DLLVM_DEFAULT_TARGET_TRIPLE=${TRIPLET_TARGET} \
          -DCMAKE_C_COMPILER=${GCC_INSTALL_PREFIX}/bin/gcc \
          -DCMAKE_CXX_COMPILER=${GCC_INSTALL_PREFIX}/bin/g++ \
          -DCMAKE_C_FLAGS='-w -fpermissive' \
          -DCMAKE_CXX_FLAGS="-w -fpermissive" \
#         -DCMAKE_CXX_STANDARD=17 \
#         -DCLANG_BUILD_EXAMPLES=ON \
#         -DCLANG_BUILD_TOOLS=ON \
#         -DLLVM_BUILD_DOCS=ON \
#         -DLLVM_BUILD_EXAMPLES=ON \
#         -DLLVM_INSTALL_BINUTILS_SYMLINKS=ON \
#         -DLLVM_INSTALL_CCTOOLS_SYMLINKS=ON \
#         -DLLVM_INSTALL_UTILS=ON \
#         -DENABLE_LINKER_BUILD_ID=ON \
#         -DLIBCLANG_BUILD_STATIC=ON \
#         -DLLVM_BUILD_LLVM_DYLIB=ON \
#         -DLLVM_ENABLE_FFI=ON \
#         -DLLVM_ENABLE_EH=ON \
#         -DLLVM_ENABLE_RTTI=ON \
#         -DLLVM_ENABLE_ASSERTIONS=ON \
          -DGCC_INSTALL_PREFIX=${GCC_INSTALL_PREFIX} \
          ${DIR_SOURCE}/llvm-project/llvm && \
    make -j${NTHREADS} | tee llvm-project-build.log && \
    make install | tee llvm-project-install.log

###############################################################################
# ubuntu Packaging                                                            #
###############################################################################

FROM base_ubuntu_18.04 as pkg_llvm_ubuntu_18.04

# arg
ARG DATESTRING=YYYYMMDD

# env
ENV INSTALL_PREFIX=/opt/llvm/10.0.1

# copy install dir
COPY --from=build_llvm_ubuntu_18.04 /opt/llvm /opt/llvm

# Copy control file
COPY data/control /tmp/
RUN sed -i "s/DATESTRING/${DATESTRING}/g" /tmp/control
RUN export ARCH=`dpkg --print-architecture` && \
    mkdir -p /tmp/llvm-10.0.1-${DATESTRING}-ubuntu-18.04_${ARCH}/DEBIAN && \
    mv /tmp/control /tmp/llvm-10.0.1-${DATESTRING}-ubuntu-18.04_${ARCH}/DEBIAN

# create deb file
RUN export ARCH=`dpkg --print-architecture` && \
    cd /tmp && \
    mv -v /opt /tmp/llvm-10.0.1-${DATESTRING}-ubuntu-18.04_${ARCH}/ && \
    dpkg-deb --build llvm-10.0.1-${DATESTRING}-ubuntu-18.04_${ARCH}

# clean-up the package
RUN rm -rf /opt/llvm

# install the deb file
RUN export ARCH=`dpkg --print-architecture` && \
    apt-get -y install /tmp/llvm-10.0.1-${DATESTRING}-ubuntu-18.04_${ARCH}.deb

# install additional packages
RUN apt-get -y install xz-utils

###############################################################################
# SPEC CPU2017                                                                 #
###############################################################################

FROM pkg_llvm_ubuntu_18.04 as spec_llvm_ubuntu_18.04

# env
ENV INSTALL_PREFIX=/opt/llvm/10.0.1

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
