#!/bin/bash

scripts_folder=$(dirname "${BASH_SOURCE[0]}")
root_folder=$scripts_folder/..

set -e
success=0
p_args=(--write --list-different)
go_args=(-w)

p_log="Running prettier"
log="Running black & isort"

if [[ "$1" = "--check" || "$1" = "-c" ]]; then
	log="$log in check only mode"
	p_log="$p_log in check only mode"
	args=(--check)
  tf_args=(-check)
	p_args=(--check)
  go_args=(-l)
fi


if [[ -d "$root_folder/venv" ]] ; then
  source $root_folder/venv/bin/activate
  echo "$log..."

  for folder in $root_folder/tools/*; do
    if [ -d "$folder" ]; then
      black $folder "${args[@]}"
      isort $folder "${args[@]}"
    fi
  done

  deactivate
fi

echo "$p_log..."

npx prettier . "${p_args[@]}"

if [ $? -ne 0 ]; then
	success=1
fi

echo "Formatting terraform files..."

terraform fmt -recursive "${tf_args[@]}" $root_folder/.

echo "Formatting golang files..."

for g in $(find . | grep "main.go"); do
  gofmt "${go_args[@]}" $g
done

echo "$?" && exit $success
