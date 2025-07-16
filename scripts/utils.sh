#!/bin/bash

scripts_folder=$(dirname "${BASH_SOURCE[0]}")

RED="\e[31m"
YELLOW="\e[33m"
GREEN="\e[32m"
NC="\e[0m"

# regex for fetching numbers
number_regex='^[0-9]+$'

read_args() {
	res=""
	while [ $# -gt 0 ]; do
		if [[ $1 == *"--"* ]]; then
			param="${1/--/}"
			res="${param}=${2}; ${res}"
		fi
		shift
	done
	echo "$res"
}

# if string (#2) contains in list (#1)
contains() { 
    [[ $1 =~ (^| )$2($| ) ]] && echo 'yes' || echo 'no'
}

# outported variables
root_folder=$scripts_folder/..
