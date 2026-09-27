#!/bin/sh

# Makes the script stop at the first error
set -e

# Allows the git pull to work from any directory
cd "$(dirname "$0")"

git pull
nvim --headless "+packdel ++all" +qa 2>/dev/null
