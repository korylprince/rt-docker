#!/bin/bash
set -e

version=$1

tag="korylprince/rt-docker"
itag="korylprince/rt-docker-indexer"

docker build --no-cache --build-arg "VERSION=$version" --tag "$tag:$version" .

docker push "$tag:$version"

if [ "$2" = "latest" ]; then
    docker tag "$tag:$version" "$tag:latest"
    docker push "$tag:latest"
fi

docker build --no-cache --build-arg "VERSION=$version" --tag "$itag:$version" -f indexer/Dockerfile .

docker push "$itag:$version"

if [ "$2" = "latest" ]; then
    docker tag "$itag:$version" "$itag:latest"
    docker push "$itag:latest"
fi
