#!/bin/sh

. ./conf

for version in ${RUBY_VERSIONS}; do
  rbenv install ${version}
done

rbenv global ${RUBY_GLOBAL_VERSION}
