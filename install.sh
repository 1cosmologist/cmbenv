#!/bin/bash

while getopts "v" opt; do
    case $opt in
	v) set -x # print commands as they are run so we know where we are if something fails
	   ;;
    esac
done
echo Starting cmbenv installation at $(date)
SECONDS=0

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

export PATH=$CONDADIR/bin:$PATH

# Initialize environment
source $CONFIGUREENV

# Set installation directories
CMBENV=$PREFIX/$CMBENVVERSION
CONDADIR=$CMBENV/conda
MODULEDIR=$CMBENV/modulefiles/cmbenv

# Install conda root environment
echo Installing conda root environment at $(date)

mkdir -p $CONDADIR/bin
mkdir -p $CONDADIR/lib

curl -SL $MINICONDA \
  -o miniconda.sh \
    && /bin/bash miniconda.sh -b -f -p $CONDADIR

source $CONDADIR/bin/activate
export PYVERSION=$(python3 -c "import sys; print(str(sys.version_info[0])+'.'+str(sys.version_info[1]))")
echo Using Python version $PYVERSION

# Install packages
source $INSTALLPKGS

# Compile python modules
echo Pre-compiling python modules at $(date)

python$PYVERSION -m compileall -f "$CONDADIR/lib/python$PYVERSION/site-packages"

# Set permissions
echo Setting permissions at $(date)

chgrp -R $GRP $CONDADIR
chmod -R u=rwX,g=rX,o-rwx $CONDADIR

# Install modulefile
echo Installing the cmbenv modulefile to $MODULEDIR at $(date)

mkdir -p $MODULEDIR

cp $topdir/modulefile.gen cmbenv.module

sed -i 's@_CONDADIR_@'"$CONDADIR"'@g' cmbenv.module
sed -i 's@_CMBENVVERSION_@'"$CMBENVVERSION"'@g' cmbenv.module
sed -i 's@_PYVERSION_@'"$PYVERSION"'@g' cmbenv.module
sed -i 's@_CONDAPRGENV_@'"$CONDAPRGENV"'@g' cmbenv.module

cp cmbenv.module $MODULEDIR/$CMBENVVERSION
cp $topdir/cmbenv.modversion $MODULEDIR/.version_$CMBENVVERSION

chgrp -R $GRP $MODULEDIR
chmod -R u=rwX,g=rX,o-rwx $MODULEDIR

# All done
echo Done at $(date)
duration=$SECONDS
echo "Installation took $(($duration / 60)) minutes and $(($duration % 60)) seconds."
