#!/usr/bin/env bash

readonly PHP_VERSION="${PHP_VERSION:8.0}"
readonly PROJECT_NAME="rectorized-app-${PHP_VERSION}"
readonly PROJECT_HOME=$(pwd)

# Enable network communication with Docker socket.
sudo chmod 666 /var/run/docker.sock

laraboot new "${PROJECT_NAME}" --php-version="${PHP_VERSION}.*" || exit 125

cd $PROJECT_NAME || exit 2

cp ../src/laraboot.json .
cp ../src/buildpack.yml .
cp ../src/rector.php .

sudo chmod -R 777 .

laraboot task add @core/laraboot-rector --format=file -vvv
laraboot build --pack-params default-process=task

# Grab tar file from image
image_id=$(docker run -id rectorized-app)
docker export "$image_id" >image-app.tar.gz
mkdir tmpy && tar -xf image-app.tar.gz -C tmpy
tree -L 1 tmpy
pushd tmpy/workspace || exit 3
ls -ltah .
tar -czf ${PROJECT_HOME}/app.tar.gz .
ls -ltah ${PROJECT_HOME}/app.tar.gz
# shellcheck disable=SC2164
popd

exit 0
