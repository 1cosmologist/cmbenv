# conda packages
echo Current time $(date) Installing conda packages
echo Conda environment is "$ENV_DIR"

CONDA_CHANNEL_PRIORITY=flexible conda install --yes --prefix "$ENV_DIR" \
    -c conda-forge -c anaconda -c nvidia -c defaults \
    astropy \
    camb \
    emcee \
    fitsio \
    gputil \
    h5py \
    healpy \
    ipython \
    joblib \
    jupyter \
    matplotlib \
    numba \
    numpy \
    scipy \
    pixell \
    pygtc \
    pysm3 \
    meson \
    namaster \
    skyplot \
    skytools \
    tqdm \
    xarray \
    netcdf4 || { echo "ERROR installing Conda packages" >&2; exit 1; }

"$CONDADIR/bin/conda" list --prefix "$ENV_DIR" --export > "$ENV_DIR/pkg_list.txt" ||
    { echo "ERROR listing Conda packages" >&2; exit 1; }

echo Current time $(date) Done installing conda packages
