#!/bin/bash

script=$(readlink -f "$0")
route=$(dirname "$script")

pip -V > /dev/null 2>&1 || sudo apt install python-pip -y || exit 1
virtualenv --version > /dev/null 2>&1 || sudo pip install virtualenv || exit 2

bk_idx=1
if [ -e ${route}/../build/py_env ]; then
    while [ -e ${route}/../build/py_env.${bk_idx} ]; do
        let bk_idx++
    done
    mv ${route}/../build/py_env ${route}/../build/py_env.${bk_idx}
fi
mkdir -p ${route}/../build

cd ${route}/../
export PYTHONPATH=
virtualenv ${route}/../build/py_env
source ${route}/../build/py_env/bin/activate
export FDSNS_SRC_DIR=.
pip install -r ${route}/../requirements.txt
deactivate
