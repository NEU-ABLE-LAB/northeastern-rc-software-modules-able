# northeastern-rc-software-modules-able

Scripts for generate ABLE lab software modules for Northeastern Research Computing

These scripts were inspired by those found in [northeastern-rc-software-modules](https://github.com/northeastern-rc-software-modules).

These scripts install software packages under `/projects/able/opt` (`opt` stands for optional software) and module files under `/projects/able/modulefiles` for loading these software packages into SLURM environments.

## Usage of modules by group members

### Modify `~/.bashrc` file to always make these modules available

Open your `~/.bashrc` file in an editor such as nano

```bash
nano ~/.bashrc
```

Then add the following line near the end

```bash
module use /projects/able/modulefiles
```

## Installation of software and modules

Run the install scripts as a SLURM batch job. For example, to install `code-server/v4.106.3`

```bash
sbatch /projects/able/scripts/northeastern-rc-software-modules-able/code-server/v4.106.3.sh
```
