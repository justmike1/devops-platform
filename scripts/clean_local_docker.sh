#!/bin/bash

read -r -p "Are you sure you want to clean all local docker images? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
        docker rm -vf $(docker ps -aq)
        docker rmi -f $(docker images -aq)
        docker system prune --all --force --volumes
        ;;
    *)
        exit 1
        ;;
esac
