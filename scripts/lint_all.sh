#!/bin/bash

scripts_folder=$(dirname "${BASH_SOURCE[0]}")
root_folder=$scripts_folder/..

success=0

./"$scripts_folder"/format_all.sh -c

_pylint() {
	printf "\nRunning pylint on $1..."
	pylint "$root_folder/$1" --rcfile="$root_folder"/.pylintrc
}

_pylint alerts

if [ $? -ne 0 ]; then
	success=1
fi

exit $success
