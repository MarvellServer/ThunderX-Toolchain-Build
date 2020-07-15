
###############################################################################
# SPEC CPU2017                                                                 #
###############################################################################

FROM pkg_TOOLCHAIN_NAME_DISTRO_NAME_DISTRO_VERSION as spec_TOOLCHAIN_NAME_DISTRO_NAME_DISTRO_VERSION

# env
ENV INSTALL_PREFIX=/opt/TOOLCHAIN_NAME/TOOLCHAIN_VERSION

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
COPY data/TOOLCHAIN_NAME.cfg /tmp/spec2017/config/

# run spec
RUN cd /tmp/spec2017/config && \
    echo "running spec2017" && \
    ../bin/runcpu --define bits=64 --config=TOOLCHAIN_NAME.cfg --size=ref --tune=base --rebuild --ignore_errors --iterations=1 --copies=64 --output_format txt 502.gcc_r
