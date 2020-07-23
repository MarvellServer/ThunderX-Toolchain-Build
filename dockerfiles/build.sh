#!/bin/bash

set -e

# get environment
BASE_DIR=`pwd`

# define date as TODAY
DATESTRING=`date +"%Y%m%d"`

# source config file
source ${BASE_DIR}/config

# verify the config file
if [ "${DISTRO_NAME}" == "centos" ] || [ "${DISTRO_NAME}" == "ubuntu" ]
then

  if [ "${TOOLCHAIN_NAME}" == "gcc-ilp32" ]
  then
    if [ -z "${GCC_BRANCH}" ] || [ -z "${TOOLCHAIN_VERSION}" ]
    then
      echo "TOOLCHAIN_VERSION / GCC_BRANCH Not Defined"
      exit
    fi
  elif [ "${TOOLCHAIN_NAME}" == "llvm" ]
  then
    if [ -z "${LLVM_BRANCH}" ] || [ -z "${TOOLCHAIN_VERSION}" ]
    then
      echo "TOOLCHAIN_VERSION / LLVM_BRANCH Not Defined"
      exit
    fi
  elif [ "${TOOLCHAIN_NAME}" == "flang" ]
  then
    if [ -z "${FLANG_BRANCH}" ] || [ -z "${TOOLCHAIN_VERSION}" ]
    then
      echo "TOOLCHAIN_VERSION / FLANG_BRANCH Not Defined"
      exit
    fi
  else
    echo "Toolchain ${TOOLCHAIN_NAME} Not Supported"
    exit
  fi
else
  echo "Distro ${DISTRO_NAME} Not supported"
  exit
fi

# create build directory
BUILD_DIR=${BASE_DIR}/build/${TOOLCHAIN_NAME}/${DISTRO_NAME}/${DISTRO_VERSION}
mkdir -p ${BUILD_DIR}
mkdir -p ${BUILD_DIR}/data

# create empty file
echo > ${BUILD_DIR}/Dockerfile

# add source dockerfile
cat ${BASE_DIR}/source/Dockerfile.${TOOLCHAIN_NAME} > ${BUILD_DIR}/Dockerfile

# add base dockerfile
cat ${BASE_DIR}/base/Dockerfile.${DISTRO_NAME} >> ${BUILD_DIR}/Dockerfile

# add build Dockerfile
cat ${BASE_DIR}/toolchain/Dockerfile.${TOOLCHAIN_NAME} >> ${BUILD_DIR}/Dockerfile

# add package Dockerfile
cat ${BASE_DIR}/package/Dockerfile.${DISTRO_NAME} >> ${BUILD_DIR}/Dockerfile

# add apps Dockerfile
cat ${BASE_DIR}/apps/${APP}/Dockerfile.${APP} >> ${BUILD_DIR}/Dockerfile

# update template files
sed -i "s/DISTRO_NAME/${DISTRO_NAME}/g"             ${BUILD_DIR}/Dockerfile
sed -i "s/DISTRO_VERSION/${DISTRO_VERSION}/g"       ${BUILD_DIR}/Dockerfile
sed -i "s/TOOLCHAIN_NAME/${TOOLCHAIN_NAME}/g"       ${BUILD_DIR}/Dockerfile
sed -i "s/TOOLCHAIN_VERSION/${TOOLCHAIN_VERSION}/g" ${BUILD_DIR}/Dockerfile

# update template files
if [ "${TOOLCHAIN_NAME}" == "gcc-ilp32" ]
then

  # update the template
  sed -i "s/GCC_BRANCH/${GCC_BRANCH}/g"   ${BUILD_DIR}/Dockerfile

elif [ "${TOOLCHAIN_NAME}" == "llvm" ]
then

  # update the template
  sed -i "s/LLVM_BRANCH/${LLVM_BRANCH}/g"   ${BUILD_DIR}/Dockerfile

elif [ "${TOOLCHAIN_NAME}" == "flang" ]
then

  # update the template
  sed -i "s/FLANG_BRANCH/${FLANG_BRANCH}/g"   ${BUILD_DIR}/Dockerfile

fi

# copy and update config files
if [ "${DISTRO_NAME}" == "centos" ]
then

  # copy config files
  cp -r package/${TOOLCHAIN_NAME}.spec                ${BUILD_DIR}/data/${TOOLCHAIN_NAME}.spec
  sed -i "s/TOOLCHAIN_VERSION/${TOOLCHAIN_VERSION}/g" ${BUILD_DIR}/data/${TOOLCHAIN_NAME}.spec

elif [ "${DISTRO_NAME}" == "ubuntu" ]
then

  # copy config files
  cp -r package/${TOOLCHAIN_NAME}.ctrl                ${BUILD_DIR}/data/control
  sed -i "s/TOOLCHAIN_VERSION/${TOOLCHAIN_VERSION}/g" ${BUILD_DIR}/data/control
  sed -i "s/DISTRO_NAME/${DISTRO_NAME}/g"             ${BUILD_DIR}/data/control
  sed -i "s/DISTRO_VERSION/${DISTRO_VERSION}/g"       ${BUILD_DIR}/data/control

fi

# copy app files
if [ "${APP}" == "spec" ]
then

  cp apps/${APP}/${TOOLCHAIN_NAME}.cfg ${BUILD_DIR}/data/${TOOLCHAIN_NAME}.cfg

fi

# copy extra files
cd ${BASE_DIR}
cp extras/github_rsa     ${BUILD_DIR}/data/github_rsa
cp extras/ssh_config     ${BUILD_DIR}/data/config
cp extras/cpu2017.tar.xz ${BUILD_DIR}/data/cpu2017.tar.xz

# build the docker
cd ${BUILD_DIR}
IMAGE_TAG=${TOOLCHAIN_NAME}_${DISTRO_NAME}_${DISTRO_VERSION}:${DATESTRING}
docker build --add-host mirror.fileplanet.com:0.0.0.0 \
             --build-arg DATESTRING=${DATESTRING} \
             -t ${IMAGE_TAG} .

# copy the rpm / deb file
docker run ${IMAGE_TAG}
container_id=$(docker ps -a | grep ${IMAGE_TAG} | head -n1 | awk '{print $1}')

if [ "${DISTRO_NAME}" == "centos" ]
then
  docker cp ${container_id}:/root/rpmbuild/RPMS/aarch64/${TOOLCHAIN_NAME}-${TOOLCHAIN_VERSION}-${DATESTRING}.el8.aarch64.rpm ${BUILD_DIR}/
elif [ "${DISTRO_NAME}" == "ubuntu" ]
then
  docker cp ${container_id}:/tmp/${TOOLCHAIN_NAME}-${TOOLCHAIN_VERSION}-${DATESTRING}-${DISTRO_NAME}-${DISTRO_VERSION}_arm64.deb ${BUILD_DIR}/
fi
