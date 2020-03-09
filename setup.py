# -*- coding: utf-8 -*-
from setuptools import setup
import os


src_dir = os.environ.get('FDSNS_SRC_DIR', '.')
version = os.environ.get('FDSNS_VERSION', '0.0.0')


setup(
    name='fdsns',
    version=version,
    description='Fast deploying, simple nav site',
    author='zerbobo',
    classifiers=[
        'Development Status :: 3 - Alpha',
        'Programming Language :: Python :: 2.7',
        'Private :: Do Not Upload',
    ],
    install_requires=[
        'Flask==1.0',
        'Flask-Cors==3.0.3',
        'Toml==0.9.4'
    ],
    package_dir={'fdsns': src_dir + "/fdsns"},
    packages=[
        'fdsns',
        'fdsns.server'
    ],
    package_data={
        'fdsns.server': ['templates/*.html'],
    },
)
