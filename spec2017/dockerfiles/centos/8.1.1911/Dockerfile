###############################################################################
# CentOS Base                                                                 #
###############################################################################

FROM centos:8.1.1911 as base_centos_8.1.1911

# install dnf plugins and enable epel repo
RUN dnf -y install dnf-plugins-core epel-release

# enable additional repos
RUN dnf config-manager --set-enabled PowerTools
RUN dnf config-manager --set-enabled extras

# install development packages
RUN dnf -y makecache
RUN dnf -y install automake \
                   autoconf \
                   libtool \
                   m4 \
                   gcc \
                   gcc-c++ \
                   gcc-gfortran \
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
                   numactl \
                   numactl-devel \
                   python3 \
                   python3-devel \
                   openssl-devel \
                   ncurses-devel \
                   libxml2-devel \
                   libedit-devel \
                   libffi-devel \
                   binutils-devel \
                   openssh-clients \
                   gettext

# update alternatives
RUN alternatives --set python /usr/bin/python3
RUN update-alternatives --install /usr/bin/pydoc          pydoc         /usr/bin/pydoc3         10
RUN update-alternatives --install /usr/bin/python-config  python-config /usr/bin/python3-config 10
RUN update-alternatives --install /usr/bin/pip            pip           /usr/bin/pip3           10

###############################################################################
# SETP the toolchain                                                          #
###############################################################################
ENV INSTALL_PREFIX=/opt/flang/9.0.0

# copy the rpm package
COPY data/*.rpm /tmp

# install the toolchain
RUN dnf -y install /tmp/*.rpm
COPY data/libje* ${INSTALL_PREFIX}/lib/

###############################################################################
# SPEC CPU2017                                                                 #
###############################################################################

FROM base_centos_8.1.1911 as spec_flang_centos_8.1.1911

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
