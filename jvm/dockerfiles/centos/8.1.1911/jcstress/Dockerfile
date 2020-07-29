
###############################################################################
# Jcstress                                                                    #
###############################################################################

# define base docker images
FROM centos:8.1.1911

# install Bell-soft JDK
RUN dnf -y makecache && \
    dnf -y install https://download.bell-sw.com/java/14.0.2+13/bellsoft-jdk14.0.2+13-linux-aarch64.rpm

# update environemt
ENV JAVA_HOME /usr/lib/jvm/bellsoft-java14.aarch64
ENV PATH ${JAVA_HOME}/bin:${PATH}

# install maven and mercurial
RUN dnf -y install maven mercurial

# download and build jcstress
RUN cd /tmp && \
    hg clone http://hg.openjdk.java.net/code-tools/jcstress/ jcstress && \
    cd jcstress && \
    mvn clean install

# run Jcstress
RUN cd /tmp/jcstress && \
    java -jar tests-all/target/jcstress.jar
