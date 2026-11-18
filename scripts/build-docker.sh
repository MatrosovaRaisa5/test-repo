#!/bin/sh
set -e
APP_NAME=$1
IMAGE_TAG=$2
docker build -t ${APP_NAME}:${IMAGE_TAG} -t ${APP_NAME}:latest .
