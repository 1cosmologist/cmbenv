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
Miniforge is installed at `<prefix>/<version>/conda`; packages are installed
in its separate `envs/cmbenv` environment, not in base. The environment uses
Python 3.14 because packages such as pixell do not yet support Python 3.15.

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
    ( set -o pipefail
      CONF=perlmutter PKGS=default PREFIX=${cmbprefix} ./install.sh |& tee install-${CMBENVVERSION}.log
    )
}

loadcmbenv () {
    local tag="${1:-0.0.1}" branch="${2:-master}"
    local version="${branch}-${tag}"
    local install_dir="${cmbprefix:?Set cmbprefix first}/${version}"
    local env_dir="$install_dir/conda/envs/cmbenv"

    module is-loaded PrgEnv-gnu || {
        echo "Load or swap to PrgEnv-gnu before calling loadcmbenv" >&2
        return 1
    }
    if module is-loaded cmbenv; then
        echo "Unload the existing cmbenv module first" >&2
        return 1
    fi

    module unload cudatoolkit || return 1
    module load cudatoolkit/13.0 cudnn/9.5.0 || return 1
    module load cray-mpich craype-accel-nvidia80 || return 1
    module use "$install_dir/modulefiles" || return 1
    module load "cmbenv/$version" || return 1
    [[ "${CMBENV:-}" == "$env_dir" ]] || {
        echo "Loaded cmbenv from an unexpected path" >&2
        return 1
    }
    source "$install_dir/conda/bin/activate" "$env_dir" || return 1
    export CMBENVVERSION="$version"
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
