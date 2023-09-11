trollExp - Run a TROLL experiment with climate
================
Sylvain Schmitt
May 5, 2023

- [Installation](#installation)
- [Usage](#usage)
- [Workflow](#workflow)
  - [Spin-up](#spin-up)
  - [Run](#run)
  - [Post](#post)
  - [Outputs](#outputs)
- [Singularity](#singularity)
- [Data](#data)

[`singularity` &
`snakemake`](https://github.com/sylvainschmitt/snakemake_singularity)
workflow to run a TROLL experiment with climate.

<figure>
<img src="dag/dag.svg" alt="Workflow." />
<figcaption aria-hidden="true">Workflow.</figcaption>
</figure>

# Installation

- [x] Python ≥3.5
- [x] Snakemake ≥5.24.1
- [x] Golang ≥1.15.2
- [x] Singularity ≥3.7.3
- [x] This workflow

``` bash
# Python
sudo apt-get install python3.5
# Snakemake
sudo apt install snakemake`
# Golang
export VERSION=1.15.8 OS=linux ARCH=amd64  # change this as you need
wget -O /tmp/go${VERSION}.${OS}-${ARCH}.tar.gz https://dl.google.com/go/go${VERSION}.${OS}-${ARCH}.tar.gz && \
sudo tar -C /usr/local -xzf /tmp/go${VERSION}.${OS}-${ARCH}.tar.gz
echo 'export GOPATH=${HOME}/go' >> ~/.bashrc && \
echo 'export PATH=/usr/local/go/bin:${PATH}:${GOPATH}/bin' >> ~/.bashrc && \
source ~/.bashrc
# Singularity
mkdir -p ${GOPATH}/src/github.com/sylabs && \
  cd ${GOPATH}/src/github.com/sylabs && \
  git clone https://github.com/sylabs/singularity.git && \
  cd singularity
git checkout v3.7.3
cd ${GOPATH}/src/github.com/sylabs/singularity && \
  ./mconfig && \
  cd ./builddir && \
  make && \
  sudo make install
# detect Mutations
git clone git@github.com:sylvainschmitt/trollExp.git
cd trollExp
git checkout climate
```

# Usage

### Locally

``` bash
snakemake -np -j 1 # dry run
snakemake --dag | dot -Tsvg > dag/dag.svg # dag
data="/home/sschmitt/Documents/trollExp_climate/data"
snakemake -j 1 --use-singularity --singularity-args "\-e \-B $data" # run
```

### Genologin

``` bash
module load bioinfo/snakemake-5.25.0 # for test on node
snakemake -np # dry run
sbatch job_genologin.sh # run
```

# Workflow

## Spin-up

### [spinup_years](https://github.com/sylvainschmitt/trollExp/blob/climate/rules/spinup_years.smk)

- Script:
  [`spinup_years.R`](https://github.com/sylvainschmitt/trollExp/blob/climate/scripts/spinup_years.R)

Define years from the historical period for the spin-up simulations.

### [prepare_spinup](https://github.com/sylvainschmitt/trollExp/blob/climate/rules/prepare_spinup.smk)

- Script:
  [`prepare_spinup.R`](https://github.com/sylvainschmitt/trollExp/blob/climate/scripts/prepare_spinupe.R)

Prepare spin-up data as a TROLL input for a defined model and regional
climate model (RCM).

### [spinup](https://github.com/sylvainschmitt/trollExp/blob/climate/rules/spinup.smk)

- Script:
  [`spinup.R`](https://github.com/sylvainschmitt/trollExp/blob/climate/scripts/spinup.R)

Run a TROLL simulation for the 600-years spin-up with historical
climate.

## Run

### [prepare_run](https://github.com/sylvainschmitt/trollExp/blob/climate/rules/prepare_run.smk)

- Script:
  [`prepare_run.R`](https://github.com/sylvainschmitt/trollExp/blob/climate/scripts/prepare_run.R)

Prepare run data as a TROLL input for a defined model and regional
climate model (RCM).

### [run](https://github.com/sylvainschmitt/trollExp/blob/climate/rules/run.smk)

- Script:
  [`run.R`](https://github.com/sylvainschmitt/trollExp/blob/climate/scripts/run.R)

Run a TROLL simulation for the century with climate from a defined
experiment (RCP).

## Post

### [post_years](https://github.com/sylvainschmitt/trollExp/blob/climate/rules/post_years.smk)

- Script:
  [`post_years.R`](https://github.com/sylvainschmitt/trollExp/blob/climate/scripts/post_years.R)

Define years from the projection period for the post-run simulations.

### [prepare_post](https://github.com/sylvainschmitt/trollExp/blob/climate/rules/prepare_post.smk)

- Script:
  [`prepare_post.R`](https://github.com/sylvainschmitt/trollExp/blob/climate/scripts/prepare_post.R)

Prepare post-run data as a TROLL input for a defined model and regional
climate model (RCM).

### [post](https://github.com/sylvainschmitt/trollExp/blob/climate/rules/post.smk)

- Script:
  [`post.R`](https://github.com/sylvainschmitt/trollExp/blob/climate/scripts/post.R)

Run a TROLL simulation for the century post climate forcing with climate
from a defined experiment (RCP).

## Outputs

*Todo.*

# Singularity

The whole workflow currently rely on the [`singularity-troll`
image](https://github.com/sylvainschmitt/singularity-troll).

# Data

#### **ERA5-Land**

- A global reanalysis dataset (Munoz-Sabater et al. 2021)
- Access from Copernicus eased by
  [`rcontroll`](https://sylvainschmitt.github.io/rcontroll/articles/climate.html)
  *(getEra workflow in preparation)*
- Currently 2004 to 2022 (can go 1950)
- VPD from dew point

#### **CORDEX**

- A Coordinated Regional Climate Downscaling Experiment for South
  America
- Access from IPGSL node eased by [`getCordex`
  workflow](https://github.com/sylvainschmitt/getCordex).
- Historical from 1950 to 2006, RCP from 2006 to 2100
- VPD from relative humidity
- Currently available models: MPI-M-MPI-ESM-MR
- Currently available RCM: ICTP-RegCM4-7
- Currently available scenario: historical, RCP 2.6 and RCP 8.5
