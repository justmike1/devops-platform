#!/bin/bash

set -e

scripts_folder=$(dirname "${BASH_SOURCE[0]}")
. $scripts_folder/utils.sh

# Specify the URL you want to check
site_url=

# read args from cli 
eval "$(read_args "$@")"

check_site_status() {
    local url="$1"
    local status_code=$(curl -s -o /dev/null -w "%{http_code}" "$url")

    if [[ $status_code -eq 200 ]]; then
        return 0
    else
        return 1
    fi
}

# Call the check_site_status function with the site_url
if check_site_status "$site_url"; then
    echo "The site is live!"
else
    echo "The site is not live!"
    exit 1
fi
