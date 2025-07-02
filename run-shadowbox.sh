#!/bin/bash

set -e

IMAGE_NAME="shadowroot-lpe"
CONTAINER_NAME="shadowbox"

echo "[*] Building $IMAGE_NAME..."
docker build -t $IMAGE_NAME .

echo "[*] Starting container $CONTAINER_NAME..."
docker run --rm -it --privileged --name $CONTAINER_NAME $IMAGE_NAME
