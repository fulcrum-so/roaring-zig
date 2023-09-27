#!/bin/bash
# The amalgamation repo hasn't been updated in a while.  Fortunately it's easy
#  to build yourself.
set -eou pipefail

script_path="$( cd "$(dirname "$0")" ; pwd -P )"
arg_repo_path="${1-}"
sibling_repo_path="${script_path}/../CRoaring"
tmp_repo_path="/tmp/CRoaring"

if [ ! -z "${arg_repo_path}" ]; then
    if [ -d "${arg_repo_path}" ]; then
        echo "Using CRoaring repo provided: ${arg_repo_path}"
        repo=$arg_repo_path
    else
        echo "The provided CRoaring directory '${arg_repo_path})' does not exist"
        exit 1
    fi
elif [ -d "${sibling_repo_path}" ]; then
    echo "Using the sibling CRoaring directory at ${sibling_repo_path}"
    repo=$sibling_repo_path
else
    echo "Cloning CRoaring into ${tmp_repo_path}"
    repo=$tmp_repo_path
    git clone --depth 1 https://github.com/RoaringBitmap/CRoaring.git $repo
fi

# canonicalize the repo path
repo="$( cd "${repo}" ; pwd -P )"

# this is a hacky workaround for a bug in the amalgamation script
mv $repo/.git $repo/.git.backup
# the amalgamation script writes to the current working directory
cd $script_path/croaring
# run the CRoaring amalgamation script
$repo/amalgamation.sh
# remove unnecessary demo and C++ amalgamation files
rm amalgamation_demo.c amalgamation_demo.cpp roaring.hh

# clean up
cd -
mv $repo/.git.backup $repo/.git
if [ $repo == $tmp_repo_path ]; then
    rm -rf $tmp_repo_path
fi