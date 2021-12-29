#!/bin/bash

image_name=dhet/postfix-pg
time_tag=$(date -u -I)

docker login -u "$USER" -p "$PASSWORD"

docker build -t "$image_name:latest" . 
docker tag "$image_name:latest" "$image_name:$time_tag"

docker push "$image_name:latest"
docker push "$image_name:$time_tag"
