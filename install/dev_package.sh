#!/bin/bash
set -eo pipefail

apt-get update
apt-get install -y --no-install-recommends $BUILD_PACKAGE
equivs-control python-pypdf
rm python-pypdf
touch python-pypdf
echo "Section: python
 Package: python-pypdf
 Version: 1.13
 Architecture: all
 Description: fake package to provide python-pypdf
 This package provide the dependency needed by Odoo.
 python-pypdf2 replace python-pypdf, but while compatible,
 does not provide python-pypdf" >> python-pypdf
 
cat python-pypdf
equivs-build python-pypdf
dpkg -i python-pypdf_1.13_all.deb
