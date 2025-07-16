#!/bin/bash

set -e

scripts_folder=$(dirname "${BASH_SOURCE[0]}")
. $scripts_folder/utils.sh

repo=
prefix=remotes/origin/

# read args from cli 
eval "$(read_args "$@")"

from=git@bitbucket.org:test/$repo.git
to=git@github.com:test/$repo.git

if [ -z "${repo}" ]; then
	printf "${NC}${RED}Please choose which repository to migrate with argument --repo${RED}${NC}\n"
	exit 1
fi

echo "Migrating repository $repo from $from to $to" 

pushd ../
printf "${NC}${GREEN}Cloning and setting up repo $repo from bitbucket ${GREEN}${NC}\n" 
git clone $from && cd $repo
git remote add upstream $to 

printf "${NC}${GREEN}Pushing to github the master branch & all the tags ${GREEN}${NC}\n"
git push upstream master
git push --tags upstream

printf "${NC}${GREEN}Setting GitHub as the main git URL redirect${GREEN}${NC}\n"
git remote set-url origin $to

printf "${NC}${GREEN}Pushing all other branches & tags from bitbucket to github ${GREEN}${NC}\n"
git push --mirror

for b in $(git branch -a); do
	if [[ $b == $prefix* ]]; then
			if [ ${b#"$prefix"} != "master" ] && [ ${b#"$prefix"} != "HEAD" ] && [ ${b#"$prefix"} != "local" ] ; then
					git branch ${b#"$prefix"} $b || true
					git checkout ${b#"$prefix"}
					git push
			fi
	fi
done
git checkout master

popd
