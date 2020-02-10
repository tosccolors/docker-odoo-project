#!/bin/bash
set -eo pipefail

apt-get update
# authentication error for libc-ares2
apt-get install -y --force-yes --no-install-recommends libc-ares2
apt-get install -y --no-install-recommends \
    antiword \
    ca-certificates \
    curl \
    ghostscript \
    graphviz \
    less \
    nano \
    node-clean-css \
    node-less \
    poppler-utils \
    python \
    python-libxslt1 \
    python-pip \
    xfonts-75dpi \
    xfonts-base \
    tcl expect \
    equivs

touch python-pypdf
echo "
Section: python
 Package: python-pypdf
 Version: 1.13
 Description: fake package to provide python-pypdf
 This package provide the dependency needed by Odoo.
 python-pypdf2 replace python-pypdf, but while compatible,
 does not provide python-pypdf
 .
 python-pypdf will need to be installed with
 \"pip install pyPdf\"" >> python-pypdf

equivs-build python-pypdf
dpkg -i python-pypdf_1.13_all.deb
pip install pyPdf