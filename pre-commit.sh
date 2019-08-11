#!/bin/bash

######################################################################
## filename: pre-commit.sh
## description: R-focussed pre-commit hook for GIT
## arguments: 
## author: Tim Kramer
######################################################################

######################################################################
# This scripts assumes the following:
#  - R is installed
#  - Rscript is in $PATH
#  - The R package 'devtools' is installed
######################################################################

# In order to know if a stash has been made, we need to compare the
# stash stack before and after we store the stash. If both stacks are
# the same, nothing was stored.
OLD_STASH=$(git rev-parse -q --verify refs/stash)
# Stash all unstaged and untracked files
git stash push -q -u --keep-index
NEW_STASH=$(git rev-parse -q --verify refs/stash)

# If there were no changes, nothing got stashed and nothing should
# run.
if [ "$OLD_STASH" = "$NEW_STASH" ]; then
    echo "Pre-commit: no changes to test"
    exit 0
fi

# Run tests
STATUS= Rscript -e "library(devtools)" -e "devtools::load_all()" \
        -e "devtools::check()"

# Roll back stash if tests exit nonzero
if [ "$STATUS" -ne 0 ]; then
    git reset --hard -q
    git clean -fd -q
    git stash pop -q
    exit $STATUS
fi

# Make signal file for post-commit
touch .commit
exit 0
