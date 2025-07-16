#!/bin/bash

set -e

scripts_folder=$(dirname "${BASH_SOURCE[0]}")
. $scripts_folder/utils.sh

ns=
pod=

# read args from cli 
eval "$(read_args "$@")"

while true; do
    status=$(kubectl get pod $pod -n $ns -o jsonpath='{.status.phase}')
    if [ "$status" == "Succeeded" ]; then
        echo "Pod has completed"
        break
    else
        echo "Pod is in $status state, waiting"
        sleep 5
    fi
done
