#!/bin/bash
set -eo pipefail

curl -o wkhtmltox.deb -SL https://builds.wkhtmltopdf.org/0.12.1.4/wkhtmltox_0.12.1.4-1.stretch_amd64.deb
echo '9c1855d0c5ca58f1221851d5284fa500baf9e78d  wkhtmltox.deb' | sha1sum -c -
dpkg --force-depends -i wkhtmltox.deb
rm wkhtmltox.deb
