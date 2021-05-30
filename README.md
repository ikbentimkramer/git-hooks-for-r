# Git hooks for R

Sometimes, you have to work in an environment without continuous integration. At least, I did. Yet you still want to make sure your tests are run regularly. You could do this manually, but you can also use git hooks to do this for you. This is exactly what the hooks in this repo do for you! These hooks run `R CMD CHECK` in your R package whenever you try to commit something in git. You will know `R CMD CHECK` failed, because the hooks will prevent a commit if this is the case. Not ideal, but better than no automatic testing at all.

## Prerequisites

Make sure R is installed. The R packages `devtools`, `usethis` and `testthat` are also required.

## Installation

Copy the files in `hooks` to the `.git/hooks` directory of the repository you want to use the hooks in. Cloning this repository and linking to your local copy works as well.

## Unit testing

There are some very rudimentary unit tests for these hooks as well! You can run them using: `test/tests.sh`.
