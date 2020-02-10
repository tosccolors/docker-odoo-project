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

pwd
equivs-control python-pypdf
cat python-pypdf
echo "
 .
 python-pypdf will need to be installed with
 \"pip install pyPdf\"" >> python-pypdf

cat python-pypdf
equivs-build python-pypdf
dpkg -i python-pypdf_1.13_all.deb
pip install pyPdf