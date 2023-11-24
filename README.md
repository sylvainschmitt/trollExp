# trollExp - Run a TROLL experiment with phenology
Sylvain Schmitt -
Nov 24, 2023

- [Installation](#installation)
- [Usage](#usage)
- [Workflow](#workflow)
  - [Data](#data)
  - [Spin-up](#spin-up)
  - [Run](#run)
- [Singularity](#singularity)
- [Data](#data-1)

[`singularity` &
`snakemake`](https://github.com/sylvainschmitt/snakemake_singularity)
workflow to run a TROLL experiment with phenology.

![Workflow.](dag/dag.svg)

# Installation

- [x] Python ≥3.5
- [x] Snakemake ≥5.24.1
- [x] Singularity ≥3.7.3

Once installed simply clone the workflow and go to the corresponding
branch:

``` bash
git clone git@github.com:sylvainschmitt/trollExp.git
cd trollExp
git checkout pheno-fluxnet
```

# Usage

### Locally

``` bash
snakemake --dag | dot -Tsvg > dag/dag.svg # dag locally
snakemake -j 1 --use-singularity --singularity-args # run locally
module load bioinfo/Snakemake/7.20.0 # for test on genobioinfo node
snakemake -np # dry run
sbatch job_genobioinfo.sh # run
```

# Workflow

## Data

### [rename](https://github.com/sylvainschmitt/trollExp/blob/pheno-fluxnet/rules/rename.py)

Rename and copy FLUXNET raw files.

### [format](https://github.com/sylvainschmitt/trollExp/blob/pheno-fluxnet/rules/format.py)

- Script:
  [`format.R`](https://github.com/sylvainschmitt/trollExp/blob/pheno-fluxnet/scripts/format.R)

Format FLUXNET raw, species and soil data into TROLL inputs.

## Spin-up

### [prepare_spinup](https://github.com/sylvainschmitt/trollExp/blob/pheno-fluxnet/rules/prepare_spinup.py)

- Script:
  [`prepare_spinup.R`](https://github.com/sylvainschmitt/trollExp/blob/pheno-fluxnet/scripts/prepare_spinup.R)

Prepare climate data as a TROLL input for a 600-years spin-up.

### [spinup](https://github.com/sylvainschmitt/trollExp/blob/pheno-fluxnet/rules/spinup.py)

- Script:
  [`spinup.R`](https://github.com/sylvainschmitt/trollExp/blob/pheno-fluxnet/scripts/spinup.R)

Run a TROLL simulation for a 600-years spin-up.

## Run

### [prepare_run](https://github.com/sylvainschmitt/trollExp/blob/pheno-fluxnet/rules/prepare_run.py)

- Script:
  [`prepare_run.R`](https://github.com/sylvainschmitt/trollExp/blob/pheno-fluxnet/scripts/prepare_run.R)

Prepare climate data as a TROLL for the run.

### [run](https://github.com/sylvainschmitt/trollExp/blob/pheno-fluxnet/rules/run.py)

- Script:
  [`run.R`](https://github.com/sylvainschmitt/trollExp/blob/pheno-fluxnet/scripts/run.R)

Run a TROLL simulation.

# Singularity

The whole workflow currently rely on the [`singularity-troll`
image](https://github.com/sylvainschmitt/singularity-troll).

# Data

- [FLUXNET 2015](https://fluxnet.org/data/fluxnet2015-dataset/)
- [Soil gathered by
  Isabelle](https://main--altpages.netlify.app/pheno#soils)
- [Imputed species traits](https://main--altpages.netlify.app/biod-imp)
