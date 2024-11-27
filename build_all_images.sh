#!/usr/bin/env bash

set -x

# Get latest CoverageControl repo from dev branch
wget https://github.com/KumarRobotics/CoverageControl/archive/refs/heads/dev.zip -O CoverageControl.zip
FROM_IMAGE_TAG=noble-torch2.5.1-jazzy
docker buildx build --no-cache -t agarwalsaurav/pac:noble -t agarwalsaurav/pac:latest --build-arg IMAGE_TAG=${FROM_IMAGE_TAG} --push .
if [ $? -ne 0 ]; then
    echo "Failed to build image"
    exit 1
fi

FROM_IMAGE_TAG=jammy-torch2.5.1-humble
docker buildx build --no-cache -t agarwalsaurav/pac:humble --build-arg IMAGE_TAG=${FROM_IMAGE_TAG} --push .
if [ $? -ne 0 ]; then
    echo "Failed to build image"
    exit 1
fi

FROM_IMAGE_TAG=arm64-jammy-torch2.5.1-humble
docker buildx build --no-cache -t agarwalsaurav/pac:arm64-humble --platform linux/arm64 --build-arg IMAGE_TAG=${FROM_IMAGE_TAG} --push .
if [ $? -ne 0 ]; then
    echo "Failed to build image"
    exit 1
fi

FROM_IMAGE_TAG=arm64-noble-torch2.5.1-jazzy
docker buildx build --no-cache -t agarwalsaurav/pac:arm64-jazzy --platform linux/arm64 --build-arg IMAGE_TAG=${FROM_IMAGE_TAG} --push .
if [ $? -ne 0 ]; then
    echo "Failed to build image"
    exit 1
fi
