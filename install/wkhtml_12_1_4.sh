#!/bin/bash
set -eo pipefail

curl -o wkhtmltox.deb -SL https://builds.wkhtmltopdf.org/0.12.1.4/wkhtmltox_0.12.1.4-1.stretch_amd64.deb
echo 'b82d75142929799011fa066e376ae65dcb89aad316a6398f8e137dd9cb7ae278 wkhtmltox.deb' | sha1sum -c -
dpkg --force-depends -i wkhtmltox.deb
rm wkhtmltox.deb
