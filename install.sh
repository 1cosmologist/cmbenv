#!/bin/bash

while getopts "v" opt; do
    case $opt in
	v) set -x # print commands as they are run so we know where we are if something fails
	   ;;
    esac
done
echo Starting cmbenv installation at $(date)
SECONDS=0

fail() {
    echo "ERROR: $*" >&2
    exit 1
}

# Defaults
if [ -z $CONF ] ; then CONF=perlmutter; fi
if [ -z $PKGS ] ; then PKGS=default;    fi

# Script directory
pushd $(dirname $0) > /dev/null
topdir=$(pwd)
popd > /dev/null

scriptname=$(basename $0)
fullscript="${topdir}/${scriptname}"

CONFDIR=$topdir/conf

CONFIGUREENV=$CONFDIR/$CONF-env.sh
INSTALLPKGS=$CONFDIR/$PKGS-pkgs.sh

# Initialize environment
source "$CONFIGUREENV" || fail "Could not initialize environment from $CONFIGUREENV"

# Set installation directories
[[ -n ${PREFIX:-} && -n ${CMBENVVERSION:-} ]] || fail "PREFIX and CMBENVVERSION must be set"
CMBENV=$PREFIX/$CMBENVVERSION
CONDADIR=$CMBENV/conda
ENV_DIR=$CONDADIR/envs/cmbenv
MODULEDIR=$CMBENV/modulefiles/cmbenv

# Install conda root environment
echo Installing conda root environment at $(date)

mkdir -p "$CONDADIR/bin" "$CONDADIR/lib" || fail "Could not create Conda directories"

curl -fSL "$MINICONDA" -o miniconda.sh || fail "Could not download Miniforge"
/bin/bash miniconda.sh -b -f -p "$CONDADIR" || fail "Could not install Miniforge"

"$CONDADIR/bin/conda" create --yes --prefix "$ENV_DIR" -c conda-forge "python=3.14" pip ||
    fail "Could not create cmbenv Conda environment"
source "$CONDADIR/bin/activate" "$ENV_DIR" || fail "Could not activate cmbenv Conda environment"
[[ ${CONDA_PREFIX:-} == "$ENV_DIR" ]] || fail "Activated Conda environment is not $ENV_DIR"

# Remove miniconda installer
rm miniconda.sh || fail "Could not remove Miniforge installer"

# Install packages
source "$INSTALLPKGS" || fail "Could not install packages from $INSTALLPKGS"

PYVERSION=$("$ENV_DIR/bin/python" -c "import sys; print(str(sys.version_info[0])+'.'+str(sys.version_info[1]))") ||
    fail "Could not determine Python version"
export PYVERSION
echo Using Python version $PYVERSION

# Compile python modules
echo Pre-compiling python modules at $(date)

"$ENV_DIR/bin/python" -m compileall -f "$ENV_DIR/lib/python$PYVERSION/site-packages" ||
    fail "Could not pre-compile Python modules"

# Set permissions
echo Setting permissions at $(date)

# chgrp -R $GRP $CONDADIR
# chmod -R u=rwX,g=rX,o-rwx $CONDADIR

# Install modulefile
echo Installing the cmbenv modulefile to $MODULEDIR at $(date)

mkdir -p "$MODULEDIR" || fail "Could not create module directory"

cp "$topdir/modulefile.gen" cmbenv.module || fail "Could not prepare modulefile"

sed -i 's@_ENV_DIR_@'"$ENV_DIR"'@g' cmbenv.module || fail "Could not configure modulefile"
sed -i 's@_CMBENVVERSION_@'"$CMBENVVERSION"'@g' cmbenv.module || fail "Could not configure modulefile"
sed -i 's@_CONDAPRGENV_@'"$CONDAPRGENV"'@g' cmbenv.module || fail "Could not configure modulefile"

cp cmbenv.module "$MODULEDIR/$CMBENVVERSION" || fail "Could not install modulefile"
cp "$topdir/cmbenv.modversion" "$MODULEDIR/.version_$CMBENVVERSION" ||
    fail "Could not install module version file"

# chgrp -R $GRP $MODULEDIR
# chmod -R u=rwX,g=rX,o-rwx $MODULEDIR

# All done
echo Done at $(date)
duration=$SECONDS
echo "Installation took $(($duration / 60)) minutes and $(($duration % 60)) seconds."
