#!/bin/bash

set -e

script=$(readlink -f "$0")
route=$(dirname "$script")

target_dir=$1

if [ "${target_dir}" == "" ]; then
    target_dir=/opt
fi

which pip > /dev/null 2>&1 || sudo apt install -y python-pip
which virtualenv > /dev/null 2>&1 || sudo pip install virtualenv
cd ${target_dir}/fdsns
virtualenv py_env --no-download || exit 1
source py_env/bin/activate || exit 2
pip install --no-index --find-links=./whls/ -r ./whls/requirements.txt

echo -e "fdsns runtime env install finished OK"
exit 0
