# from distutils.core import setup
from setuptools import setup, find_packages
import os
import glob

from codecs import open
from os import path

here = path.abspath(path.dirname(__file__))

# Get the long description from the README file
with open(path.join(here, 'README.md'), encoding='utf-8') as f:
    long_description = f.read()

# use the in house version number so we stay in synch with ourselves.
from razor.version import razor_version

setup(
    name='razor',
    version=razor_version,
    python_requires='>=3.6',
    description='The OCCAM saga',
    long_description_content_type='text/markdown',
    long_description=long_description,
    url='https://github.com/SRI-CSL/OCCAM',
    author='Ian A. Mason',
    author_email='iam@csl.sri.com',


    packages=find_packages(exclude=['examples']),

    entry_points = {
        'console_scripts': [
            'slash = razor.slash:entrypoint',
        ],
    },

    license='MIT',

    install_requires=[
        "protobuf >= 3.5.1"
    ],


    classifiers=[
        'Development Status :: 3 - Alpha',
        'Natural Language :: English',
        'Intended Audience :: Developers',
        'Topic :: System :: Distributed Computing',
        'License :: OSI Approved :: MIT License',
        'Programming Language :: Python',
        'Programming Language :: Python :: 3',
    ],
)
