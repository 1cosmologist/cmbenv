# cmbenv

## Introduction

This package is a fork of `exgalsky/xgsmenv` environment written and maintained by Marcelo Alvarez.
It contains scripts for installing `cmbenv`, an environment for
running extraglactic sky modeling software under development. Currently
configured for running healpy and GPU-enabled jax on Perlmutter at NERSC.

There is a corresponding version for MacOS but without GPU support, since JAX does not 
support Apple Silicon GPUs. But the same packages can be installed with CPU support.

On Perlmutter, mpi4py is built from source with the Cray compiler wrapper and
Cray MPICH; other packages may use Conda's compilers and libraries. Load the
compatible Cray MPICH and CUDA modules when running the environment.

## Bash convenience functions on NERSC Perlmutter (Updated 11/16/2026)

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
    module load cudatoolkit/13.0
    module load cudnn/9.5.0
    module load cray-mpich craype-accel-nvidia80
    module use ${cmbprefix}/${CMBENVVERSION}/modulefiles
    module load cmbenv
    source ${cmbprefix}/${CMBENVVERSION}/conda/bin/activate
}
```

## Bash convenience functions on MacOS
```bash
cmbprefix=/PATH/TO/cmbenv
installcmbenv () {

    tag=0.0.1
    branch=mac
    if [ ! -z $1 ] ; then    tag=$1; fi
    if [ ! -z $2 ] ; then branch=$2; fi

    export PYTHONPATH=
    cd
    export CMBENVVERSION=$branch-$tag
    rm -rf $cmbprefix/$CMBENVVERSION
    tmp_build_dir=/PATH/TO/cmbenv
    rm -rf ${tmp_build_dir}
    git clone -b $branch https://github.com/1cosmologist/cmbenv ${tmp_build_dir}
    chmod -R a+x ${tmp_build_dir}
    cd ${tmp_build_dir} 
    # echo $PATH
    echo `which python`
    CONF=mac PKGS=mac-default PREFIX=${cmbprefix} ./mac-install.sh |& tee install-${CMBENVVERSION}.log
}

loadcmbenv () {
    
    tag=0.0.1
    branch=mac
    if [ ! -z $1 ] ; then    tag=$1; fi
    if [ ! -z $2 ] ; then branch=$2; fi

    export CMBENVVERSION=$branch-$tag
    source ${cmbprefix}/${CMBENVVERSION}/conda/bin/activate
}
```
