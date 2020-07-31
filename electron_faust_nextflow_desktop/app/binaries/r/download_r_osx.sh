# #!/usr/bin/env bash

# WARNING: This MUST be run from the directory it lives in

# Taken from here:
# https://github.com/dirkschumacher/r-shiny-electron/blob/master/get-r-mac.sh
set -e

# From: https://stackoverflow.com/questions/59895/how-to-get-the-source-directory-of-a-bash-script-from-within-the-script-itself
CURRENT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"

INSTALLATION_DIRECTORY_ABSOLUTE_PATH=$CURRENT_DIRECTORY/$R_VERSION_INSTALL_DIRECTORY_RELATIVE_PATH

# ------------------------------------------------------------------------------
# Clean up pre-existing builds
rm -fr $R_MAC_DIRECTORY_NAME

# ------------------------------------------------------------------------------
# Download and extract the source code for R
mkdir -p $R_MAC_DIRECTORY_NAME
cd $R_MAC_DIRECTORY_NAME

curl --remote-name https://cran.rstudio.com/src/base/R-4/$R_VERSION_COMPRESSED_FILE_NAME \
    --output $R_VERSION_COMPRESSED_FILE_NAME

tar -xzvf $R_VERSION_COMPRESSED_FILE_NAME

# Reset workspace state
mv "$R_VERSION_NAME" "$R_VERSION_BUILD_DIRECTORY_NAME"
rm $R_VERSION_COMPRESSED_FILE_NAME

# Return to root directory
cd ../

# ------------------------------------------------------------------------------
# Perform build
cd $R_VERSION_BUILD_DIRECTORY_RELATIVE_PATH

echo "-------------------------------------------------------------------------"
echo "Installing R $R_VERSION into $INSTALLATION_DIRECTORY_ABSOLUTE_PATH"
echo "-------------------------------------------------------------------------"
# WARNING: `configure` creates output in the directory it is invoked from
# This MUST be invoked in the directory where the build files will be placed
./configure \
    --prefix=$INSTALLATION_DIRECTORY_ABSOLUTE_PATH \
    --with-blas \
    --with-lapack

# Actual build entry point
make
make install

# Return to root directory
cd ../

# # ------------------------------------------------------------------------------
# # For some reason the `$R_VERSION_INSTALL_DIRECTORY_RELATIVE_PATH` has a `lib`
# # directory that actually contains the ACTUAL R Files
# # So you need to move the files of that directory to the correct directory in
# # order to avoid errors like `ldpaths not found`
mkdir -p $R_VERSION_FINAL_ARTIFACT_DIRECTORY_RELATIVE_PATH
cp -r ${R_VERSION_INSTALL_DIRECTORY_RELATIVE_PATH}/lib/R/* $R_VERSION_FINAL_ARTIFACT_DIRECTORY_RELATIVE_PATH
# cp -r ${R_VERSION_INSTALL_DIRECTORY_RELATIVE_PATH}/* $R_VERSION_FINAL_ARTIFACT_DIRECTORY_RELATIVE_PATH

# ------------------------------------------------------------------------------
# Inject logic to override the initial configuration and point to the correct
# shiny executable

# Patch the main R script
sed -i.bak '/^R_HOME_DIR=/d' $R_VERSION_BINARY_R_FILE_RELATIVE_PATH
sed -i.bak 's;/Library/Frameworks/R.framework/Resources;${R_HOME};g' $R_VERSION_BINARY_R_FILE_RELATIVE_PATH
chmod +x $R_VERSION_BINARY_R_FILE_RELATIVE_PATH
rm -f $R_VERSION_BINARY_R_FILE_RELATIVE_PATH.bak
# # ------------------------------------------------------------------------------
# # Perform Clean up - only the final artifact should remain
# rm -fr $R_VERSION_BUILD_DIRECTORY_RELATIVE_PATH
# rm -fr $R_VERSION_INSTALL_DIRECTORY_RELATIVE_PATH
