This script does three things:

 - Download and install conda.
 
 - Set the appropiriate conda channels to install the NNPDF
 dependencies. This is done by writting a ~/.condarc file with the
 following content:

```
channels:
  - https://packages.nnpdf.science/public
  - defaults
  - conda-forge
```

 In case the file exists, the script doesn't touch it (as not even
 with conda config is it easy to set the channels in order).

Note: Make sure that the order of the channels is the same as above
Otherwise you might receive incompatible packages.

Common issues
-------------

In case of a conflict between local and conda-installed packages, use the environment flag `PYTHONUSERBASE`:

```bash
export PYTHONUSERBASE=intentionally-disabled
```

If the installation of the `nnpdf` package hangs or takes a long time, a solution is to use the `libmamba` solver as [explained here](https://www.anaconda.com/blog/a-faster-conda-for-a-growing-community).
Note that from September '23, or equivalently from conda version 23.9.0, `libmamba` will be the default solver in conda so after this date updating conda `conda update -n base conda` should be enough.
