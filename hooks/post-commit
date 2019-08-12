#!/bin/bash

######################################################################
## filename: post-commit.sh
## description: R-focussed post-commit hook for GIT
## arguments: 
## author: Tim Kramer
######################################################################

######################################################################
# This scripts assumes the following:
#  - the pre-commit hook makes a file (.commit) if it has run,
#  - the pre-commit hook stashes unstaged and untracked files 
#    when run,
#  - all unstaged and untracked files after commit have 
#    to be amended.
######################################################################

# Exit if pre-commit has not run
if [ ! -e .commit ]; then
    exit 0
fi

# If the pre-commit has run, we know that there is a stash, and we
# know that there may be files that need to be committed
rm .commit
git add .
git commit --amend -C HEAD --no-verify # Don't run pre-commit hook to
				       # prevent loops
git reset --hard -q
git clean -fd -q
git stash pop -q

exit 0
