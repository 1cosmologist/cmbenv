# cmbenv

## Introduction

This package is a fork of exgalsky/xgsmenv environment written and maintained by Marcelo Alvarez.
It contains scripts for installing cmbenv, an environment for
running extraglactic sky modeling software under development. Currently
configured for running healpy and GPU-enabled jax on Perlmutter at NERSC.

## Bash convenience functions

```bash
cmbprefix=$SCRATCH/cmbenv
installcmbenv () {

    tag=0.0.1
    branch=master
    if [ ! -z $1 ] ; then    tag=$1; fi
    if [ ! -z $2 ] ; then branch=$2; fi

    export PYTHONPATH=
    cd
    export CMBENVVERSION=$branch-$tag
    rm -rf $cmbprefix/$CMBENVVERSION
    tmp_build_dir=$SCRATCH/cmbenv
    rm -rf ${tmp_build_dir}
    git clone -b $branch https://github.com/1cosmologist/cmbenv ${tmp_build_dir}
    cd ${tmp_build_dir}
    # echo $PATH
    echo `which python`
    CONF=perlmutter PKGS=default PREFIX=${cmbprefix} ./install.sh |& tee install-${CMBENVVERSION}.log
}

loadcmbenv () {
    
    tag=0.0.1
    branch=master
    if [ ! -z $1 ] ; then    tag=$1; fi
    if [ ! -z $2 ] ; then branch=$2; fi

    export CMBENVVERSION=$branch-$tag

    module unload cudatoolkit # ignore the systemwide cudatoolkit to avoid version conflicts
    module load cudatoolkit/12.2
    module load cudnn/8.9.3_cuda12
    module load cray-mpich craype-accel-nvidia80
    module use ${cmbprefix}/${CMBENVVERSION}/modulefiles
    module load cmbenv
    source ${cmbprefix}/${CMBENVVERSION}/conda/bin/activate
}
```

## Quick start

### Install

```bash
# set target
prefix=/prepend-path-here/cmbenv # <-- where this version will be installed
mkdir -p ${prefix}

tmp_build_dir=/path-to-temporary-build-directory
git clone https://github.com/exgalsky/cmbenv ${tmp_build_dir}
cd ${tmp_build_dir}

unset PYTHONPATH
export CMBENVVERSION=$(date '+%Y%m%d')-0.0.0 # <-- name of this version
CONF=perlmutter PKGS=default PREFIX=${prefix} ./install.sh |& tee install.log
```

### Load the environment installed above

```bash
module use ${prefix}/${CMBENVVERSION}/modulefiles
module load cmbenv
```
