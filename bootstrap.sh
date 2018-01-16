#!/bin/bash

if [[ -f ./setup/bootstrap.$(uname).sh ]]; then
  ./setup/bootstrap.$(uname).sh
else
  uname -v | grep -q "Ubuntu"
  ubuntu=$?
  if [[ ${ubuntu} = 0 ]]; then
    ./setup/bootstrap.Ubuntu.sh
  else
    echo 'Quit'
    exit 1
  fi
fi
