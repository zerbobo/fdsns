#!/bin/bash

set -e

script=$(readlink -f "$0")
route=$(dirname "$script")

tgt_version=$1
tgt_install_prefix=$2
working_dir=fdsns
v_env=${route}/../build/py_env

### 1. check paras
if [ "${tgt_version}" == "" ]; then
    git describe >/dev/null 2>&1 && tgt_version=$(git describe --tag)
    if [ "${tgt_version}" == "" ]; then
        echo "No version number can be achieved from git"
        exit 1
    fi
fi
echo "Version is ${tgt_version}"

if [ "${tgt_install_prefix}" == "" ]; then
    tgt_install_prefix=/opt
fi
echo "deb install prefix is ${tgt_install_prefix}"

### 2. check env and tools
pip -V > /dev/null 2>&1 || sudo apt install python-pip -y || exit 2
virtualenv --version > /dev/null 2>&1 || sudo pip install virtualenv || exit 3

source ${v_env}/bin/activate || exit 5

### 3. ready the working dir
cd ${route}/..
mkdir -p dist
bk_idx=1
if [ -e dist/${working_dir} ]; then
    while [ -e dist/${working_dir}.${bk_idx} ]; do
        let bk_idx++ || true
    done
    mv dist/${working_dir} dist/${working_dir}.${bk_idx}
fi

mkdir -p dist/${working_dir}/DEBIAN
mkdir -p dist/${working_dir}/${tgt_install_prefix}/fdsns/whls

### 4. build self and export
cd ${route}/..
export FDSNS_VERSION=${tgt_version}
export PYTHONPATH=
pip install . || exit 6
pip freeze | grep -v "pkg-resources" > ${route}/../dist/${working_dir}/${tgt_install_prefix}/fdsns/whls/requirements.txt
pip wheel -r ${route}/../requirements.txt . -w ${route}/../dist/${working_dir}/${tgt_install_prefix}/fdsns/whls

cp ${route}/runtime_env_install.sh ${route}/../dist/${working_dir}/${tgt_install_prefix}/fdsns/runtime_env_install.sh
cp ${route}/../fdsns_log.conf ${route}/../dist/${working_dir}/${tgt_install_prefix}/fdsns/
cp ${route}/../example_config/fdsns.toml ${route}/../dist/${working_dir}/${tgt_install_prefix}/fdsns/

### 5. make various config files under DEBIAN dir
cd ${route}/../dist/${working_dir}/DEBIAN
touch control
(cat << EOF
Package: fdsns
Version: ${tgt_version}
Section: x11
Priority: optional
Depends:
Suggests:
Architecture: amd64
Maintainer: zerbobo
CopyRight: MIT
Provider: zerbobo
Description: Fast deploying, simple nav site
EOF
) > control

touch postinst
(cat << EOF
#!/bin/bash
touch /usr/bin/run-fdsns-d
(cat << EOF2
#!/bin/bash
source ${tgt_install_prefix}/fdsns/py_env/bin/activate
cd ${tgt_install_prefix}/fdsns/
python -m fdsns.server.web_site &
echo \\\$! > fdsns.pid
EOF2
) > /usr/bin/run-fdsns-d
chmod +x /usr/bin/run-fdsns-d
mkdir -p /usr/lib/systemd/system/
(cat << EOF3
[Unit]
Description=fdsns
After=network.target
[Service]
Type=forking
ExecStart=/usr/bin/run-fdsns-d
PIDFile=${tgt_install_prefix}/fdsns/fdsns.pid
User=root
[Install]
WantedBy=multi-user.target
EOF3
) > /usr/lib/systemd/system/fdsns.service
bash ${tgt_install_prefix}/fdsns/runtime_env_install.sh || echo "${tgt_install_prefix}/fdsns/runtime_env_install.sh fail, you can run it again after installation."
EOF
) > postinst

touch postrm
(cat << EOF
#!/bin/bash
EOF
) > postrm

touch preinst
(cat << EOF
#!/bin/bash
EOF
) > preinst

touch prerm
(cat << EOF
#!/bin/bash
rm -f /usr/bin/run-fdsns-d
rm -f /usr/lib/systemd/system/fdsns.service
rm -rf ${tgt_install_prefix}/fdsns/py_env
EOF
) >> prerm

chmod +x postinst postrm preinst prerm

### 6. start to make .deb package
cd ${route}/../dist/
fakeroot dpkg -b ${working_dir} fdsns_${tgt_version}_amd64.deb || exit 7
rm -fr ${working_dir}

echo "pack fdsns into deb finished."
exit 0
