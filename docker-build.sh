#!/bin/bash

version=$1

docker build --no-cache --tag "korylprince/rt-docker:$version" .

docker push "korylprince/rt-docker:$version"

cd indexer

docker build --no-cache --tag "korylprince/rt-docker-indexer:$version" .

docker push "korylprince/rt-docker-indexer:$version"
