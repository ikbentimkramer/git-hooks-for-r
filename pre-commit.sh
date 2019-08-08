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

# Run tests
exec Rscript -e "library(devtools)" -e "devtools::load_all()" \
     -e "devtools::check()"

exit

