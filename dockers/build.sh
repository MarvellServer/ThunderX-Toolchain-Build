#!/bin/bash

set -ex

# get environment
BASE_DIR=`pwd`
BUILD_DIR=${BASE_DIR}/build

# read config file
source ${BASE_DIR}/config
echo ${toolchain_branch}

# create build directory
mkdir -p ${BUILD_DIR}
mkdir -p ${BUILD_DIR}/data
echo > ${BUILD_DIR}/Dockerfile

# add source dockerfile
cat ${BASE_DIR}/source/Dockerfile.${toolchain_name} > ${BUILD_DIR}/Dockerfile

# add base dockerfile
cat ${BASE_DIR}/base/Dockerfile.${platform_name} >> ${BUILD_DIR}/Dockerfile

# add build Dockerfile
cat ${BASE_DIR}/toolchain/Dockerfile.${toolchain_name} >> ${BUILD_DIR}/Dockerfile

# add package Dockerfile
cat ${BASE_DIR}/package/Dockerfile.${platform_name} >> ${BUILD_DIR}/Dockerfile

# add apps Dockerfile
cat ${BASE_DIR}/apps/Dockerfile.spec.${platform_name} >> ${BUILD_DIR}/Dockerfile

# update Dockerfile
sed -i "s/PLATFORM_NAME/${platform_name}/g"         ${BUILD_DIR}/Dockerfile
sed -i "s/PLATFORM_VERSION/${platform_version}/g"   ${BUILD_DIR}/Dockerfile
sed -i "s/TOOLCHAIN_NAME/${toolchain_name}/g"       ${BUILD_DIR}/Dockerfile
sed -i "s/TOOLCHAIN_VERSION/${toolchain_version}/g" ${BUILD_DIR}/Dockerfile
sed -i "s/TOOLCHAIN_BRANCH/${toolchain_branch}/g"   ${BUILD_DIR}/Dockerfile

# copy extra files
cd ${BASE_DIR}
cp -r extras/github_rsa     ${BUILD_DIR}/data/github_rsa
cp -r extras/ssh_config     ${BUILD_DIR}/data/config
cp -r package/llvm.spec     ${BUILD_DIR}/data/llvm.spec
cp -r package/llvm.ctrl     ${BUILD_DIR}/data/control
cp -r extras/cpu2017.tar.xz ${BUILD_DIR}/data/cpu2017.tar.xz
cp -r apps/llvm.cfg         ${BUILD_DIR}/data/llvm.cfg

# build docker
cd ${BUILD_DIR}
image_tag=${toolchain_name}_${platform_name}_${platform_version}:${toolchain_branch}
docker build --add-host mirror.fileplanet.com:0.0.0.0 -t ${image_tag} .

# copy the rpm file
#docker run ${image_tag}
#container_id=$(docker ps -a | grep ${image_tag} | head -n1 | awk '{print $1}')
#docker cp ${container_id}:/root/rpmbuild/RPMS/aarch64/llvm-9.0.0-20200701.el8.aarch64.rpm ${BUILD_DIR}/
