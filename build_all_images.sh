#!/usr/bin/env bash

set -x

DATESTAMP=$(date -u +'%Y%m%dZ')
# Get latest CoverageControl repo from dev branch
wget https://github.com/KumarRobotics/CoverageControl/archive/refs/heads/dev.zip -O CoverageControl.zip
FROM_IMAGE_TAG=noble-torch2.5.1-jazzy-20250613Z
docker buildx build --no-cache -t agarwalsaurav/pac:jazzy-${DATESTAMP} --build-arg IMAGE_TAG=${FROM_IMAGE_TAG} --push .
if [ $? -ne 0 ]; then
    echo "Failed to build image"
    exit 1
fi

FROM_IMAGE_TAG=noble-torch2.5.1-cuda12.6.3-jazzy-20250613Z
docker buildx build --no-cache -t agarwalsaurav/pac:jazzy-cuda-${DATESTAMP} --build-arg IMAGE_TAG=${FROM_IMAGE_TAG} --push .
if [ $? -ne 0 ]; then
    echo "Failed to build image"
    exit 1
fi

FROM_IMAGE_TAG=jammy-torch2.5.1-humble-20250613Z
# docker buildx build --no-cache -t agarwalsaurav/pac:humble-${DATESTAMP} --build-arg IMAGE_TAG=${FROM_IMAGE_TAG} --push .
if [ $? -ne 0 ]; then
    echo "Failed to build image"
    exit 1
fi

FROM_IMAGE_TAG=jammy-torch2.5.1-cuda12.4.1-humble-20250613Z
docker buildx build --no-cache -t agarwalsaurav/pac:humble-cuda-${DATESTAMP} --build-arg IMAGE_TAG=${FROM_IMAGE_TAG} --push .
if [ $? -ne 0 ]; then
    echo "Failed to build image"
    exit 1
fi

FROM_IMAGE_TAG=arm64-jammy-torch2.5.1-humble-20250613Z
docker buildx build --no-cache -t agarwalsaurav/pac:arm64-humble-${DATESTAMP} --platform linux/arm64 --build-arg IMAGE_TAG=${FROM_IMAGE_TAG} --push .
if [ $? -ne 0 ]; then
    echo "Failed to build image"
    exit 1
fi

FROM_IMAGE_TAG=arm64-noble-torch2.5.1-jazzy-20250613Z
docker buildx build --no-cache -t agarwalsaurav/pac:arm64-jazzy-${DATESTAMP} --platform linux/arm64 --build-arg IMAGE_TAG=${FROM_IMAGE_TAG} --push .
if [ $? -ne 0 ]; then
    echo "Failed to build image"
    exit 1
fi
