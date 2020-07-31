###############################################################################
# Ubuntu Base                                                                 #
###############################################################################

FROM ubuntu:19.10 as base_ubuntu_19.10

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
# ubuntu Package                                                              #
###############################################################################
FROM base_ubuntu_19.10 as spec_ubuntu_19.10
# env
ENV INSTALL_PREFIX=/opt/flang/9.0.0

# copy the deb package
COPY data/*.deb /tmp
COPY data/libje* ${INSTALL_PREFIX}/lib/

# install the toolchain
RUN dpkg -i /tmp/*.deb

###############################################################################
# SPEC CPU2017                                                                #
###############################################################################
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

# run spec
RUN cd /tmp/spec2017/config && \
    echo "running spec2017" && \
    ../bin/runcpu --define bits=64 --config=flang.cfg --size=ref --tune=base --rebuild --ignore_errors --iterations=1 --copies=64 --output_format txt specrate
