# Install pip packages.
echo Installing pip packages at $(date)

# JAX install follows: https://docs.nersc.gov/development/languages/python/using-python-perlmutter/#jax
"$ENV_DIR/bin/python" -m pip install --no-cache-dir "jax[cuda13]" "jaxlib" || {
    echo "ERROR installing JAX; exiting" >&2
    exit 1
}

# see https://docs.nersc.gov/development/languages/python/parallel-python/
if [[ ! -x "${CRAYPE_DIR:-}/bin/cc" ]]; then
    echo "ERROR: Cray compiler wrapper not found; load craype and PrgEnv-gnu" >&2
    exit 1
fi

MPI4PY_BUILD_MPICC="$CRAYPE_DIR/bin/cc -shared" \
    "$ENV_DIR/bin/python" -m pip install --force-reinstall --no-cache-dir --no-binary=mpi4py mpi4py || {
    echo "ERROR installing mpi4py; exiting" >&2
    exit 1
}
# pip install --force --no-cache-dir --no-binary=mpi4py mpi4py
# pip install cython

# git clone git@github.com:1cosmologist/skytools.git skytools
# cd skytools
# pip install --no-dependencies .

echo Current time $(date) Done installing conda packages
