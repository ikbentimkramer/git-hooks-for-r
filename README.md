# Git hooks for R

These are my personal git hooks for R development. They make sure all tests pass before allowing a commit to happen. 

## Prerequisites

Make sure R is installed. The R packages `devtools`, `usethis` and `testthat` are also required.

## Installation

Copy the files in `hooks` to the `.git/hooks` directory of the repository you want to use the hooks in. Cloning this repository and linking to your local copy works as well.

## Running tests

Run the file `test/tests.sh`.

