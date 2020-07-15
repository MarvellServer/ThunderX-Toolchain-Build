
###############################################################################
# GCC Source                                                                  #
###############################################################################

FROM centos:8.1.1911 as gcc-ilp32_source

# install pre-requisites
RUN dnf -y install git wget bzip2

# define env
ENV DIR_BASE=/tmp/gcc-ilp32
ENV DIR_SOURCE=${DIR_BASE}/source

# set up ssh keys
COPY data/github_rsa /root/.ssh/
COPY data/config /root/.ssh/

# create dirs
RUN mkdir -p ${DIR_BASE}
RUN mkdir -p ${DIR_SOURCE}

# clone repos : binutils-gdb
RUN cd ${DIR_SOURCE} && \
    git clone http://sourceware.org/git/binutils-gdb.git

# clone repos : linux-kernel
RUN cd ${DIR_SOURCE} && \
    git clone git@github.com:MarvellServer/ThunderX-ilp32-linux.git

# clone repos : glibc-ilp32
RUN cd ${DIR_SOURCE} && \
    git clone git@github.com:MarvellServer/ThunderX-Toolchain-glibc-ilp32.git

# clone repos : gcc-ilp32
RUN cd ${DIR_SOURCE} && \
    git clone git@github.com:MarvellServer/ThunderX-Toolchain-gcc-ilp32.git

# update and checkout : binutils-gdb
RUN cd ${DIR_SOURCE}/binutils-gdb && \
    git pull && \
    git checkout master

# update and checkout : ThunderX-ilp32-linux
RUN cd ${DIR_SOURCE}/ThunderX-ilp32-linux && \
    git pull && \
    git checkout ilp32-5.4.y

# update and checkout : ThunderX-Toolchain-glibc-ilp32
RUN cd ${DIR_SOURCE}/ThunderX-Toolchain-glibc-ilp32 && \
    git pull && \
    git checkout v-0.2

# update and checkout : ThunderX-Toolchain-gcc-ilp32
RUN cd ${DIR_SOURCE}/ThunderX-Toolchain-gcc-ilp32 && \
    git pull && \
    git checkout struct_opt

# download_prerequisites
RUN cd ${DIR_SOURCE}/ThunderX-Toolchain-gcc-ilp32 && \
    contrib/download_prerequisites

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
# GCC Build                                                                   #
###############################################################################

# define base
FROM base_ubuntu_20.04 as build_gcc-ilp32_ubuntu_20.04

# define env
ENV NTHREADS=64
ENV DIR_BASE=/tmp/gcc-ilp32
ENV DIR_SOURCE=${DIR_BASE}/source
ENV DIR_BUILD=${DIR_BASE}/build

# create directories
RUN mkdir -p ${DIR_BASE}
RUN mkdir -p ${DIR_SOURCE}
RUN mkdir -p ${DIR_BUILD}

# copy sources
COPY --from=gcc-ilp32_source ${DIR_SOURCE}/binutils-gdb                   ${DIR_SOURCE}/binutils-gdb
COPY --from=gcc-ilp32_source ${DIR_SOURCE}/ThunderX-ilp32-linux           ${DIR_SOURCE}/ThunderX-ilp32-linux
COPY --from=gcc-ilp32_source ${DIR_SOURCE}/ThunderX-Toolchain-glibc-ilp32 ${DIR_SOURCE}/ThunderX-Toolchain-glibc-ilp32
COPY --from=gcc-ilp32_source ${DIR_SOURCE}/ThunderX-Toolchain-gcc-ilp32   ${DIR_SOURCE}/ThunderX-Toolchain-gcc-ilp32

# define build config
ENV INSTALL_PREFIX=/opt/gcc-ilp32/10.0.1
ENV TARGET aarch64-linux-gnu
ENV MULTILIB_CONF -with-multilib-list=lp64,ilp32
ENV LIBMVEC_CONF --enable-mathvec
ENV CONF --prefix=${INSTALL_PREFIX} --with-sysroot=${INSTALL_PREFIX} \
         --target=${TARGET} --host=${TARGET} --build=${TARGET}
ENV GCC_CONF ${CONF} --enable-gnu-indirect-function \
             --with-advance-toolchain=${INSTALL_PREFIX} ${MULTILIB_CONF}

# update PATH
ENV PATH ${INSTALL_PREFIX}/bin:${INSTALL_PREFIX}/usr/bin:${PATH}

# create directories
RUN mkdir -p ${INSTALL_PREFIX} && \
    mkdir -p ${INSTALL_PREFIX}/lib && \
    mkdir -p ${INSTALL_PREFIX}/lib64 && \
    mkdir -p ${INSTALL_PREFIX}/libilp32 && \
    mkdir -p ${INSTALL_PREFIX}/include && \
    mkdir -p ${INSTALL_PREFIX}/usr && \
    mkdir -p ${INSTALL_PREFIX}/usr/lib && \
    mkdir -p ${INSTALL_PREFIX}/usr/lib64 && \
    mkdir -p ${INSTALL_PREFIX}/usr/libilp32

# configure, build and install : binutils-gdb
ENV BUILD_COMP=binutils-gdb
ENV BINUTILS_CONF ${CONF}
RUN cd ${DIR_BUILD} && \
    mkdir -p ${BUILD_COMP} && \
    cd ${BUILD_COMP} && \
    ${DIR_SOURCE}/${BUILD_COMP}/configure ${BINUTILS_CONF} && \
    make -Otarget -j${NTHREADS} | tee ${BUILD_COMP}-build.log && \
    make -Otarget install | tee ${BUILD_COMP}-install.log

# configure, build and install : ThunderX-Toolchain-gcc-ilp32 / init
ENV BUILD_COMP=ThunderX-Toolchain-gcc-ilp32
ENV INIT_GCC_CONF --with-newlib --without-headers \
                  --enable-languages=c --enable-threads=no \
                  --disable-shared --disable-decimal-float \
                  --disable-libsanitizer --disable-bootstrap
RUN cd ${DIR_BUILD} && \
    mkdir -p ${BUILD_COMP}-init && \
    cd ${BUILD_COMP}-init && \
    ${DIR_SOURCE}/${BUILD_COMP}/configure ${GCC_CONF} ${INIT_GCC_CONF} && \
    make -Otarget -j${NTHREADS} all-gcc all-target-libgcc | tee ${BUILD_COMP}-init-build.log && \
    make -Otarget install-gcc install-target-libgcc | tee ${BUILD_COMP}-init-install.log

# configure, build and install : ThunderX-ilp32-linux
ENV BUILD_COMP=ThunderX-ilp32-linux
RUN cd ${DIR_SOURCE}/${BUILD_COMP} && \
    export CC=/usr/bin/gcc && \
    make -Otarget headers_install ARCH=arm64 INSTALL_HDR_PATH=${INSTALL_PREFIX}/usr HOSTCC=/usr/bin/gcc && \
    unset CC

# configure, build and install : ThunderX-Toolchain-glibc-ilp32 / lib64
ENV BUILD_COMP=ThunderX-Toolchain-glibc-ilp32
ENV GLIBC_CONF --with-headers=${INSTALL_PREFIX}/usr/include \
               ${LIBMVEC_CONF} --enable-obsolete-rpc \
               --prefix=/usr --host=${TARGET}
RUN export BUILD_CC=/usr/bin/gcc && \
    export CC="${INSTALL_PREFIX}/bin/${TARGET}-gcc -mabi=lp64" && \
    export CXX="${INSTALL_PREFIX}/bin/${TARGET}-g++ -mabi=lp64" && \
    export AR="${INSTALL_PREFIX}/bin/ar" && \
    export RANLIB="${INSTALL_PREFIX}/bin/ranlib" && \
    export LD="${INSTALL_PREFIX}/bin/ld" && \
    export AS="${INSTALL_PREFIX}/bin/as" && \
    cd ${DIR_BUILD} && \
    mkdir -p ${BUILD_COMP}-lib64 && \
    cd ${BUILD_COMP}-lib64 && \
    ${DIR_SOURCE}/${BUILD_COMP}/configure ${GLIBC_CONF} && \
    make -Otarget -j${NTHREADS} all | tee ${BUILD_COMP}-lib64-build.log && \
    make -Otarget DESTDIR=${INSTALL_PREFIX} install | tee ${BUILD_COMP}-lib64-install.log && \
    unset BUILD_CC CC CXX AR RANLIB AS LD

# configure, build and install : ThunderX-Toolchain-glibc-ilp32 / lib32
ENV BUILD_COMP=ThunderX-Toolchain-glibc-ilp32
ENV GLIBC_CONF --with-headers=${INSTALL_PREFIX}/usr/include \
               ${LIBMVEC_CONF} --enable-obsolete-rpc \
               --prefix=/usr --host=${TARGET}
RUN export BUILD_CC=/usr/bin/gcc && \
    export CC="${INSTALL_PREFIX}/bin/${TARGET}-gcc -mabi=ilp32" && \
    export CXX="${INSTALL_PREFIX}/bin/${TARGET}-g++ -mabi=ilp32" && \
    export AR="${INSTALL_PREFIX}/bin/ar" && \
    export RANLIB="${INSTALL_PREFIX}/bin/ranlib" && \
    export LD="${INSTALL_PREFIX}/bin/ld" && \
    export AS="${INSTALL_PREFIX}/bin/as" && \
    cd ${DIR_BUILD} && \
    mkdir -p ${BUILD_COMP}-lib32 && \
    cd ${BUILD_COMP}-lib32 && \
    ${DIR_SOURCE}/${BUILD_COMP}/configure ${GLIBC_CONF} && \
    make -Otarget -j${NTHREADS} all | tee ${BUILD_COMP}-lib32-build.log && \
    make -Otarget DESTDIR=${INSTALL_PREFIX} install | tee ${BUILD_COMP}-lib32-install.log && \
    unset BUILD_CC CC CXX AR RANLIB AS LD

# configure, build and install : ThunderX-Toolchain-gcc-ilp32 / final
ENV BUILD_COMP=ThunderX-Toolchain-gcc-ilp32
ENV FINAL_GCC_CONF --enable-languages=c,c++,fortran \
                   --disable-libsanitizer --enable-bootstrap \
                   --enable-threads --enable-shared
RUN cd ${DIR_BUILD} && \
    mkdir -p ${BUILD_COMP}-final && \
    cd ${BUILD_COMP}-final && \
    ${DIR_SOURCE}/${BUILD_COMP}/configure ${GCC_CONF} ${FINAL_GCC_CONF} && \
    make -Otarget -j${NTHREADS} all | tee ${BUILD_COMP}-final-build.log && \
    make -Otarget install | tee ${BUILD_COMP}-final-install.log

###############################################################################
# ubuntu Packaging                                                            #
###############################################################################

FROM base_ubuntu_20.04 as pkg_gcc-ilp32_ubuntu_20.04

# arg
ARG DATESTRING=YYYYMMDD

# env
ENV INSTALL_PREFIX=/opt/gcc-ilp32/10.0.1

# copy install dir
COPY --from=build_gcc-ilp32_ubuntu_20.04 /opt/gcc-ilp32 /opt/gcc-ilp32

# Copy control file
COPY data/control /tmp/
RUN sed -i "s/DATESTRING/${DATESTRING}/g" /tmp/control
RUN export ARCH=`dpkg --print-architecture` && \
    mkdir -p /tmp/gcc-ilp32-10.0.1-${DATESTRING}-ubuntu-20.04_${ARCH}/DEBIAN && \
    mv /tmp/control /tmp/gcc-ilp32-10.0.1-${DATESTRING}-ubuntu-20.04_${ARCH}/DEBIAN

# create deb file
RUN export ARCH=`dpkg --print-architecture` && \
    cd /tmp && \
    mv -v /opt /tmp/gcc-ilp32-10.0.1-${DATESTRING}-ubuntu-20.04_${ARCH}/ && \
    dpkg-deb --build gcc-ilp32-10.0.1-${DATESTRING}-ubuntu-20.04_${ARCH}

# clean-up the package
RUN rm -rf /opt/gcc-ilp32

# install the deb file
RUN export ARCH=`dpkg --print-architecture` && \
    apt-get -y install /tmp/gcc-ilp32-10.0.1-${DATESTRING}-ubuntu-20.04_${ARCH}.deb

# install additional packages
RUN apt-get -y install xz-utils

###############################################################################
# SPEC CPU2017                                                                 #
###############################################################################

FROM pkg_gcc-ilp32_ubuntu_20.04 as spec_gcc-ilp32_ubuntu_20.04

# env
ENV INSTALL_PREFIX=/opt/gcc-ilp32/10.0.1

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
COPY data/gcc-ilp32.cfg /tmp/spec2017/config/

# run spec
RUN cd /tmp/spec2017/config && \
    echo "running spec2017" && \
    ../bin/runcpu --define bits=64 --config=gcc-ilp32.cfg --size=ref --tune=base --rebuild --ignore_errors --iterations=1 --copies=64 --output_format txt 502.gcc_r
