#!/bin/sh

script_dir=$(cd $(dirname $0); pwd)
. "${script_dir}/conf"

for version in ${RUBY_VERSIONS}; do
  rbenv install ${version}
done

rbenv global ${RUBY_GLOBAL_VERSION}
