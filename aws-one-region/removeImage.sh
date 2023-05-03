#!/bin/sh

sudo docker container stop $(docker ps -a -q)
docker system prune --all --force --volumes