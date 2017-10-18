#!/bin/sh

script_dir=$(cd $(dirname $0); pwd)
. "${script_dir}/conf"

for version in ${PYTHON_2_VERSIONS} ${PYTHON_3_VERSIONS}; do
  pyenv install ${version}
done

pyenv global ${PYTHON_GLOBAL_VERSION}
