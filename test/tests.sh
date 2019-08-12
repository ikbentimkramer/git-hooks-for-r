#!/bin/bash

######################################################################
## filename: test-pre-commit.sh
## description: Tests for pre-commit.sh
## arguments: 
## author: Tim Kramer
######################################################################

######################################################################
# This scripts assumes the following:
#  - R is installed
#  - Rscript is in $PATH
#  - The R package 'devtools' is installed
######################################################################

# Set up test environment
hookscriptdir="$PWD"
tempdir="/tmp/test.$(date +%s)"
mkdir $tempdir
cd $tempdir
cat <<\EOF > setup.R
# This R script sets up a very basic test environment for git
# hooks. It should pass all tests with 0 errors, 0 warnings and 0
# notes.

# Required packages:
# devtools
# testthat
# usethis

library(devtools)
library(usethis)

test_dir <- "git.hooks.testenv"

usethis::create_package(test_dir, rstudio = FALSE, open = FALSE)
setwd(test_dir)
usethis::use_cc0_license("Testy McTest")
usethis::use_testthat()
usethis::use_test("mock", open = FALSE)

# use_git() requires interactive input, so we have to set that up
# manually.
EOF

Rscript setup.R > /dev/null 2>&1
cd "git.hooks.testenv"
git init > /dev/null
git add .
git commit -m "Initial commit" > /dev/null
ln -s "$hookscriptdir/pre-commit.sh" ./.git/hooks/pre-commit
ln -s "$hookscriptdir/post-commit.sh" ./.git/hooks/post-commit


testerrors=0
# Run tests

echo "--- When a commit is empty, it should: ---"
# Test setup
OLDSTASH=$(git rev-parse -q --verify refs/stash)
OLDCOMMIT=$(git rev-parse -q --verify refs/heads/master)
git commit --allow-empty -m "asdsad" > "$tempdir/stdout.log" 2>&1
NEWSTASH=$(git rev-parse -q --verify refs/stash)
NEWCOMMIT=$(git rev-parse -q --verify refs/heads/master)
MATCHCOUNT=$(grep -F "Pre-commit: no changes to test" -c "$tempdir/stdout.log")

#Testing
# not leave a stash
if [ "$OLDSTASH" = "$NEWSTASH" ]; then
    TEST1="OK"
else
    TEST1="NOT OK"
    (( testerrors++ ))
fi
# continue to commit
if [ "$OLDCOMMIT" != "$NEWCOMMIT" ]; then
    TEST2="OK"
else
    TEST2="NOT OK"
    (( testerrors++ ))
fi
# report "Pre-commit: no changes to test"
if [ "$MATCHCOUNT" -eq 1 ]; then
    TEST3="OK"
else
    TEST3="NOT OK"
    (( testerrors++ ))
fi

# Reporting
echo "    not leave a stash ... $TEST1"
echo "    continue to commit ... $TEST2"
echo "    report 'Pre-commit: no changes to test' ... $TEST3"

# Test teardown
git reset --hard -q "$OLDCOMMIT"
rm "$tempdir/stdout.log"
OLDSTASH=""
OLDCOMMIT=""
NEWSTASH=""
NEWCOMMIT=""
MATCHCOUNT=""
TEST1=""
TEST2=""
TEST3=""


echo "--- When a commit is nonempty, but tests fail, it should ---"
# Test setup
OLDSTASH=$(git rev-parse -q --verify refs/stash)
OLDCOMMIT=$(git rev-parse -q --verify refs/heads/master)
echo "test_that('This should fail', fail())" > ./tests/testthat/test-mock.R
git add . > /dev/null 2>&1
git commit -m "asdsad" > "$tempdir/stdout.log" 2>&1
NEWSTASH=$(git rev-parse -q --verify refs/stash)
NEWCOMMIT=$(git rev-parse -q --verify refs/heads/master)
MATCHCOUNT=$(grep -F "Pre-commit: tests failed; aborting commit" -c "$tempdir/stdout.log")

# report "Pre-commit: tests failed; aborting commit"
if [ "$MATCHCOUNT" -eq 1 ]; then
    TEST1="OK"
else
    TEST1="NOT OK"
    (( testerrors++ ))
fi

# abort commit
if [ "$OLDCOMMIT" = "$NEWCOMMIT" ]; then
    TEST2="OK"
else
    TEST2="NOT OK"
    (( testerrors++ ))
fi

# not leave a stash
if [ "$OLDSTASH" = "$NEWSTASH" ]; then
    TEST3="OK"
else
    TEST3="NOT OK"
    (( testerrors++ ))
fi

# Reporting
echo "    report 'Pre-commit: tests failed; aborting commit' ... $TEST1"
echo "    abort commit ... $TEST2"
echo "    not leave a stash ... $TEST3"

# Test teardown
git reset --hard -q "$OLDCOMMIT"
rm "$tempdir/stdout.log"
OLDSTASH=""
OLDCOMMIT=""
NEWSTASH=""
NEWCOMMIT=""
MATCHCOUNT=""
TEST1=""
TEST2=""
TEST3=""


echo "--- When a commit is nonempty and tests succeed, it should ---"
# Test setup
OLDSTASH=$(git rev-parse -q --verify refs/stash)
OLDCOMMIT=$(git rev-parse -q --verify refs/heads/master)
echo "test_that('This should succeed', succeed())" > ./tests/testthat/test-mock.R
git add . > /dev/null 2>&1
git commit -m "asdsad" > "$tempdir/stdout.log" 2>&1
NEWSTASH=$(git rev-parse -q --verify refs/stash)
NEWCOMMIT=$(git rev-parse -q --verify refs/heads/master)

# Testing
# not leave a stash
if [ "$OLDSTASH" = "$NEWSTASH" ]; then
    TEST1="OK"
else
    TEST1="NOT OK"
    (( testerrors++ ))
fi
# continue to commit
if [ "$OLDCOMMIT" != "$NEWCOMMIT" ]; then
    TEST2="OK"
else
    TEST2="NOT OK"
    (( testerrors++ ))
fi

# Reporting
echo "    not leave a stash ... $TEST1"
echo "    continue to commit ... $TEST2"

# Test teardown
git reset --hard -q "$OLDCOMMIT"
OLDSTASH=""
OLDCOMMIT=""
NEWSTASH=""
NEWCOMMIT=""
TEST1=""
TEST2=""

echo "--- When testing adds files, it should ---"
# Test setup
OLDSTASH=$(git rev-parse -q --verify refs/stash)
OLDCOMMIT=$(git rev-parse -q --verify refs/heads/master)
Rscript -e "library(devtools)" -e "use_r('mock')" > /dev/null 2>&1
cat <<\EOF > R/mock.R
#' Add together two numbers.
#'
#' @param x A number.
#' @param y A number.
#' @return The sum of \code{x} and \code{y}.
#' @examples
#' add(1, 1)
#' add(10, 1)
#' @export
add <- function(x, y) {
  x + y
}
EOF
git add . > /dev/null 2>&1
touch file1
git diff --name-only --cached > ../tocommit
git commit -m "sadkajsd" > /dev/null 2>&1
NEWSTASH=$(git rev-parse -q --verify refs/stash)
NEWCOMMIT=$(git rev-parse -q --verify refs/heads/master)
git diff-tree --no-commit-id --name-only -r "$NEWCOMMIT" > ../committed

# Testing
# not leave a stash
if [ "$OLDSTASH" = "$NEWSTASH" ]; then
    TEST1="OK"
else
    TEST1="NOT OK"
    (( testerrors++ ))
fi

# continue to commit
if [ "$OLDCOMMIT" != "$NEWCOMMIT" ]; then
    TEST2="OK"
else
    TEST2="NOT OK"
    (( testerrors++ ))
fi

# amend the files to the previous commit
if [ "$(cat ../tocommit)" != "$(cat ../committed)" ]; then
    TEST3="OK"
else
    TEST3="NOT OK"
    (( testerrors++ ))
fi

# not amend non-generated files
if [ $(grep -F "file1" -c ../committed) -eq 0 ]; then
    TEST4="OK"
else
    TEST4="NOT OK"
    (( testerrors++ ))
fi

# Reporting
echo "    not leave a stash ... $TEST1"
echo "    continue to commit ... $TEST2"
echo "    amend the files to the previous commit ... $TEST3"
echo "    not amend non-generated files ... $TEST4"

# Teardown
git reset --hard -q "$OLDCOMMIT"
rm file1 # Just in case
rm ../tocommit
rm ../committed
OLDSTASH=""
OLDCOMMIT=""
NEWSTASH=""
NEWCOMMIT=""
TOCOMMIT=""
COMMITTED=""
TEST1=""
TEST2=""
TEST3=""
TEST4=""

# Clean up test environment
rm -rf $tempdir

exit $testerrors
