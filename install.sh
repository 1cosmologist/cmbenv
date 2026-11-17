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
MODULEDIR=$CMBENV/modulefiles/cmbenv

# Install conda root environment
echo Installing conda root environment at $(date)

mkdir -p "$CONDADIR/bin" "$CONDADIR/lib" || fail "Could not create Conda directories"

curl -fSL "$MINICONDA" -o miniconda.sh || fail "Could not download Miniforge"
/bin/bash miniconda.sh -b -f -p "$CONDADIR" || fail "Could not install Miniforge"

source "$CONDADIR/bin/activate" || fail "Could not activate Conda environment"
PYVERSION=$(python -c "import sys; print(str(sys.version_info[0])+'.'+str(sys.version_info[1]))") ||
    fail "Could not determine Python version"
export PYVERSION
echo Using Python version $PYVERSION

# Remove miniconda installer
rm miniconda.sh || fail "Could not remove Miniforge installer"

# Install packages
source "$INSTALLPKGS" || fail "Could not install packages from $INSTALLPKGS"

# Compile python modules
echo Pre-compiling python modules at $(date)

"python$PYVERSION" -m compileall -f "$CONDADIR/lib/python$PYVERSION/site-packages" ||
    fail "Could not pre-compile Python modules"

# Set permissions
echo Setting permissions at $(date)

# chgrp -R $GRP $CONDADIR
# chmod -R u=rwX,g=rX,o-rwx $CONDADIR

# Install modulefile
echo Installing the cmbenv modulefile to $MODULEDIR at $(date)

mkdir -p "$MODULEDIR" || fail "Could not create module directory"

cp "$topdir/modulefile.gen" cmbenv.module || fail "Could not prepare modulefile"

sed -i 's@_CONDADIR_@'"$CONDADIR"'@g' cmbenv.module || fail "Could not configure modulefile"
sed -i 's@_CMBENVVERSION_@'"$CMBENVVERSION"'@g' cmbenv.module || fail "Could not configure modulefile"
sed -i 's@_PYVERSION_@'"$PYVERSION"'@g' cmbenv.module || fail "Could not configure modulefile"
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
