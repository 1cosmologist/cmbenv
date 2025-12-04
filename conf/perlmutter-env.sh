# export MINICONDA=https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
# miniforge solves fast and works well with conda-forge
export MINICONDA=https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh
export CONDAVERSION=0.0
export GRP=mp107
export CONDAPRGENV=gnu

export CC="gcc"
export FC="gfortran"
export CFLAGS="-O3 -fPIC -pthread"
export FCFLAGS="-O3 -fPIC -pthread -fexceptions"
export NTMAKE=8

# needed for mpi4py
# see https://docs.nersc.gov/development/languages/python/using-python-perlmutter
module unload cudatoolkit # ignore the systemwide cudatoolkit to avoid version conflicts
module load cudatoolkit/12.2
module load cudnn/8.9.3_cuda12
module load cray-mpich craype-accel-nvidia80

export MPICC="cc -target-accel=nvidia80 -shared"

for PRGENV in $(echo gnu intel cray nvidia)
do
  mod=`module -t list 2>&1 | grep PrgEnv-$PRGENV`
  if [ "x$mod" != x ] ; then
    if [ $PRGENV != $CONDAPRGENV ] ; then
      echo "swapping PrgEnv-$PRGENV for PrgEnv-$CONDAPRGENV"
      module swap PrgEnv-$PRGENV PrgEnv-$CONDAPRGENV
    fi
  fi
done