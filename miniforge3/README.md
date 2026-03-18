# Miniforge3

This creates miniforge and `conda` to be used by the group.

The `conda` binary can be found at the following path and can be executed by anyone.

```bash
MINIFORGE3_VERSION=25.9.1-0
/projects/able/opt/miniforge3-${MINIFORGE3_VERSION}/bin/conda
```

Each user's `conda` environments and package cache are automatically placed under

```bash
/projects/able/users/$USER/.conda/envs
/projects/able/users/$USER/.conda/pkgs
```

Because the module sets `CONDA_ENVS_PATH` and `CONDA_PKGS_DIRS`, you can just run:

```bash
conda create -n myenv python=3.12
conda activate myenv
```

and your env will be created under `/projects/able/users/$USER/.conda/envs/myenv`.

Shared environments created by `mbkane` can be found under `/projects/able/.conda` but cannot be modified by anyone other than `mbkane` but can be used by all members of `kanegroup`.

```bash
/projects/able/.conda/envs
/projects/able/.conda/pkgs
```

## Using the ABLE `miniforge3` module

The miniforge3 module can be loaded as follows to use the group's shared miniforge3 binaries and environments

```bash
module use /projects/able/modulefiles
module load miniforge3/25.9.1-0
```

To enable `conda activate` in that shell without using `conda init`:

```bash
eval "$(conda shell.bash hook)"
conda activate base         # or another env
```

**Do not** run conda init yourself. The module handles all environment setup.

If the module detects an old conda initialize block in your ~/.bashrc that points
to a different install, it will print a warning. In that case, remove or comment
out the old block.

### Configuring the VSCode On-Demand app

The [VSCode On-Demand app](https://ood.explorer.northeastern.edu/pun/sys/dashboard/batch_connect/sys/vscode/session_contexts/new) by default will load the `anaconda3` module, and use that instead of the ABLE group's shared `miniforge3` module. To ensure that VSCode uses our preferred `conda` you must modify your User Settings JSON.

In the VSCode On-Demand app, run the VSCode command `>Preferences: Open User Settings (JSON)` by typing `F1` and that command. Then, add the following to the main `{}` list:

```json
    "python.condaPath": "/projects/able/opt/miniforge3-25.9.1-0/bin/conda",
    "python.defaultInterpreterPath": "/projects/able/opt/miniforge3-25.9.1-0/bin/python",
```

### SLURM batch script example

```bash
#!/bin/bash
#SBATCH --job-name=conda-test
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=04:00:00

# Load the ABLE `miniforge3` module
module use /projects/able/modulefiles
module load miniforge3/25.9.1-0

# Initialize conda for this shell
eval "$(conda shell.bash hook)"

# First time only:
# conda create -n able-test python=3.12 -y

conda activate able-test
python -c "import sys; print(sys.executable)"
```

### Per-user env & package directories

Shared conda environments created by `mbkane` that all users can use are stored in the `/projects/able/.conda/` directory.

```bash
mkdir -p /projects/able/.conda/envs
mkdir -p /projects/able/.conda/pkgs
chown "mbkane":"kanegroup" /projects/able/.conda -R
chmod 750 /projects/able/.conda
chmod 750 /projects/able/.conda/envs
chmod 750 /projects/able/.conda/pkgs
```

Environments can be created with commands like

```bash
conda create -p /projects/able/.conda/envs/gee-env python=3.12 ...
```
