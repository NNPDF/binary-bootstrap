NOTE:

Since NNPDF 4.0.10, the package is available from  `conda-forge` and the script is not needed to set up private channels.
You can download [miniconda](https://www.anaconda.com/docs/getting-started/miniconda/main) directly or use another implementation such as [pixi](https://pixi.sh/latest/).


The script in this repository is a quick and easy way of installing the latest version of nnpdf into your computer under a conda environment:

```bash
curl https://raw.githubusercontent.com/NNPDF/binary-bootstrap/master/bootstrap.sh -o bootstrap.sh
sh bootstrap.sh
```

and, assuming that the initialization step was accepted in the previous script,

```bash
conda create -n nnpdf_env nnpdf -y
conda activate nnpdf_env
```

This script does three things:

 - Download and install conda, trying to get the right architecture for the computer. You can run the following in your terminal:
 
 - Set the appropiriate conda channels to install the NNPDF
 dependencies. This is done by writting a ~/.condarc file with the
 following content:

```
channels:
  - https://packages.nnpdf.science/public
  - conda-forge
  - defaults
```

 In case the file exists, the script doesn't touch it (as not even
 with conda config is it easy to set the channels in order).

Note: Make sure that the order of the channels is the same as above
Otherwise you might receive incompatible packages.
Defaults is not necessary.

Common issues
-------------

In case of a conflict between local and conda-installed packages, use the environment flag `PYTHONUSERBASE`:

```bash
export PYTHONUSERBASE=intentionally-disabled
```

If the installation of the `nnpdf` package hangs or takes a long time, a solution is to use the `libmamba` solver as [explained here](https://www.anaconda.com/blog/a-faster-conda-for-a-growing-community).
Note that from September '23, or equivalently from conda version 23.9.0, `libmamba` will be the default solver in conda so after this date updating conda `conda update -n base conda` should be enough.
