#!/bin/bash

sudo touch /etc/pip.conf

(cat <<EOF
[global]
index-url = https://mirrors.ustc.edu.cn/pypi/web/simple
EOF
) | sudo tee /etc/pip.conf >/dev/null
