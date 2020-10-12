#!/bin/bash

set -e

# get environment
BASE_DIR=`pwd`

# define date as TODAY
DATESTRING=`date +"%Y%m%d"`

# get variables
TOOLCHAIN_NAME=$(echo ${BASE_DIR} | rev | cut -d "/" -f 4-4 | rev)
DISTRO_NAME=$(echo ${BASE_DIR} | rev | cut -d "/" -f 2-2 | rev)
DISTRO_VERSION=$(echo ${BASE_DIR} | rev | cut -d "/" -f 1-1 | rev)

# check for files
if [ ! -f "data/ssh_config" ]
then
  echo "SSH config file 'data/ssh_config' missing"
  exit
fi

if [ ! -f "data/github_rsa" ]
then
  echo "GitHub RSA Key missing"
  exit
fi
if [ ! -f "data/cpu2017.tar.xz" ]
then
  echo "SPEC 2017 Source archive missing"
  exit
fi

# build
IMAGE_TAG=${TOOLCHAIN_NAME}_${DISTRO_NAME}_${DISTRO_VERSION}:${DATESTRING}
docker build --add-host mirror.fileplanet.com:0.0.0.0 \
             --build-arg DATESTRING=${DATESTRING} \
             -t ${IMAGE_TAG} .

# copy the rpm / deb file
docker run ${IMAGE_TAG}
container_id=$(docker ps -a | grep ${IMAGE_TAG} | head -n1 | awk '{print $1}')

if [ "${DISTRO_NAME}" == "centos" ]
then
  docker cp ${container_id}:/root/rpmbuild/RPMS/aarch64/flang-10.0.1-${DATESTRING}.el8.aarch64.rpm ${BASE_DIR}/
elif [ "${DISTRO_NAME}" == "ubuntu" ]
then
  docker cp ${container_id}:/tmp/flang-10.0.1-${DATESTRING}-${DISTRO_NAME}-${DISTRO_VERSION}_arm64.deb ${BASE_DIR}/
fi
