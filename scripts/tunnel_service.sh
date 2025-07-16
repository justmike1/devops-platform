#!/bin/bash

set -e

scripts_folder=$(dirname "${BASH_SOURCE[0]}")
. $scripts_folder/utils.sh

ns=
svc=
project=

service_ip=
service_port=
local_port=

# read args from cli 
eval "$(read_args "$@")"

node=$(kubectl get nodes --no-headers=true -o custom-columns=NAME:.metadata.name | head -n 1)

if [ -z "$service_ip" ]; then
    service_ip=$(kubectl get svc -n "$ns" "$svc" -o jsonpath='{.spec.clusterIP}')
fi

if [ -z "$service_port" ]; then
    service_port=$(kubectl get svc -n "$ns" "$svc" -o jsonpath='{.spec.ports[0].port}')
fi

if [ -z "$local_port" ]; then
  local_port=${service_port}
fi

echo "Tunneling to $ns/$svc on $node:$service_ip $local_port:$service_port..."

gcloud compute ssh $node --project $project -- -L $local_port:${service_ip}:${service_port}