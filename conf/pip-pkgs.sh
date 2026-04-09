# Install pip packages.
echo Installing pip packages at $(date)

# JAX install follows: https://docs.nersc.gov/development/languages/python/using-python-perlmutter/#jax
pip install --no-cache-dir "jax[cuda12]==0.5.3" "jaxlib" -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html

# see https://docs.nersc.gov/development/languages/python/parallel-python/
pip install --force --no-cache-dir --no-binary=mpi4py mpi4py
pip install cython

# git clone git@github.com:1cosmologist/skytools.git skytools
# cd skytools
# pip install --no-dependencies .

if [ $? != 0 ]; then
    echo "ERROR installing pip packages; exiting"
    exit 1
fi

echo Current time $(date) Done installing conda packages
