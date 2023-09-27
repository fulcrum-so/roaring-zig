#!/bin/bash
# The amalgamation repo hasn't been updated in a while.  Fortunately it's easy
#  to build yourself.
set -eou pipefail

if [[ -z "${CROARING_REPO}" ]]; then
    repo="/tmp/CRoaring"
    git clone --depth 1 https://github.com/RoaringBitmap/CRoaring.git $repo
else
    repo="${CROARING_REPO}"
fi

mv $repo/.git $repo/.git.backup
cd croaring
$repo/amalgamation.sh

# clean up
cd -
mv $repo/.git.backup $repo/.git
rm croaring/amalgamation_demo.c croaring/amalgamation_demo.cpp croaring/roaring.hh

if [[ -z "${CROARING_REPO}" ]]; then
    rm -rf $repo
fi
