#!/bin/bash
set -e

version=$1

tag="ghcr.io/korylprince/rt-docker"
itag="ghcr.io/korylprince/rt-docker-indexer"

ALPINEDEPS=$(cat ./perl-depends.alpine | xargs)
CPANDEPS=$(cat ./perl-depends.cpan | xargs)

docker build --no-cache \
    --build-arg "VERSION=${version:1}" \
    --build-arg "ALPINEDEPS=$ALPINEDEPS" \
    --build-arg "CPANDEPS=$CPANDEPS" \
    --label "org.opencontainers.image.source=https://github.com/korylprince/rt-docker" \
    --label "org.opencontainers.image.title=rt-docker" \
    --tag "rt5:build" .

docker tag "rt5:build" "$tag:$version"

docker push "$tag:$version"

if [ "$2" = "latest" ]; then
    docker tag "$tag:$version" "$tag:latest"
    docker push "$tag:latest"
fi

docker build --no-cache \
    --build-arg "VERSION=${version:1}" \
    --build-arg "ALPINEDEPS=$ALPINEDEPS" \
    --label "org.opencontainers.image.source=https://github.com/korylprince/rt-docker" \
    --label "org.opencontainers.image.title=rt-docker-indexer" \
    --tag "$itag:$version" \
    -f indexer/Dockerfile .

docker push "$itag:$version"

if [ "$2" = "latest" ]; then
    docker tag "$itag:$version" "$itag:latest"
    docker push "$itag:latest"
fi

docker image rm "rt5:build"
