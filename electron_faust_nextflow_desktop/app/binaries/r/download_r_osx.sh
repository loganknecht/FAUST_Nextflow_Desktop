#!/usr/bin/env bash

# Taken from here:
# https://github.com/dirkschumacher/r-shiny-electron/blob/master/get-r-mac.sh
set -e

R_VERSION=3.5.1
# R_VERSION=3.6.3

# Download and extract the main Mac Resources directory
# Requires xar and cpio, both installed in the Dockerfile
mkdir -p r-mac
curl --output r-mac/latest_r.pkg \
     https://cloud.r-project.org/bin/macosx/R-${R_VERSION}.pkg
     # https://cloud.r-project.org/bin/macosx/R-3.5.1.pkg # Old Version

cd r-mac
xar -xf latest_r.pkg
rm -r r-1.pkg Resources tcltk8.pkg texinfo5.pkg Distribution latest_r.pkg
cat r.pkg/Payload | gunzip -dc | cpio -i
mv R.framework/Versions/Current/Resources/* .
rm -r r.pkg R.framework

# Patch the main R script
sed -i.bak '/^R_HOME_DIR=/d' bin/R
sed -i.bak 's;/Library/Frameworks/R.framework/Resources;${R_HOME};g' bin/R
chmod +x bin/R
rm -f bin/R.bak

# Remove unneccessary files TODO: What else
rm -r doc tests
rm -r lib/*.dSYM
