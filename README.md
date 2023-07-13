trollExp - Run a TROLL experiment with phenology
================
Sylvain Schmitt
June 26, 2023

- [Installation](#installation)
- [Usage](#usage)
- [Workflow](#workflow)
  - [Spin-up](#spin-up)
  - [Run](#run)
- [Singularity](#singularity)
- [Data](#data)

[`singularity` &
`snakemake`](https://github.com/sylvainschmitt/snakemake_singularity)
workflow to run a TROLL experiment with phenology.

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
git checkout pheno-plumber
```

# Usage

### Locally

``` bash
snakemake -np -j 1 # dry run
snakemake --dag | dot -Tsvg > dag/dag.svg # dag
snakemake -j 1 --use-singularity --singularity-args # run
```

### HPC

``` bash
module load bioinfo/snakemake-5.25.0 # for test on node
snakemake -np # dry run
sbatch job_genologin.sh # run
```

# Workflow

## Spin-up

### [get_data](https://github.com/sylvainschmitt/trollExp/blob/pheno-plumber/rules/get_fluxes.py)

Download data from PLUMBER2, the flux tower dataset tailored for land
model evaluation (<https://essd.copernicus.org/articles/14/449/2022/>).

### [prepare_spinup](https://github.com/sylvainschmitt/trollExp/blob/pheno-plumber/rules/prepare_spinup.py)

- Script:
  [`prepare_spinup.R`](https://github.com/sylvainschmitt/trollExp/blob/pheno-plumber/scripts/prepare_spinup.R)

Prepare climate data as a TROLL input for a defined model and regional
climate model (RCM) for the spin-up.

### [prepare_spinup_era](https://github.com/sylvainschmitt/trollExp/blob/pheno-plumber/rules/prepare_spinup_era.py)

- Script:
  [`prepare_spinup_era.R`](https://github.com/sylvainschmitt/trollExp/blob/pheno-plumber/scripts/prepare_spinup_era.R)

Prepare climate data as a TROLL input for a defined model and regional
climate model (RCM) for the spin-up with ERA5-Land data.

### [prepare_spinup_raw](https://github.com/sylvainschmitt/trollExp/blob/pheno-plumber/rules/prepare_spinup_raw.py)

- Script:
  [`prepare_spinup_raw.R`](https://github.com/sylvainschmitt/trollExp/blob/pheno-plumber/scripts/prepare_spinup_raw.R)

Prepare climate data as a TROLL input for a defined model and regional
climate model (RCM) for the spin-up with raw eddy-tower data.

### [spinup](https://github.com/sylvainschmitt/trollExp/blob/pheno-plumber/rules/spinup.py)

- Script:
  [`spinup.R`](https://github.com/sylvainschmitt/trollExp/blob/pheno-plumber/scripts/spinup.R)

Run a TROLL simulation for the 600-years spin-up.

## Run

### [prepare_run](https://github.com/sylvainschmitt/trollExp/blob/pheno-plumber/rules/prepare_run.py)

- Script:
  [`prepare_run.R`](https://github.com/sylvainschmitt/trollExp/blob/pheno-plumber/scripts/prepare_run.R)

Prepare climate data as a TROLL input for a defined model and regional
climate model (RCM) for the run.

### [prepare_run_era](https://github.com/sylvainschmitt/trollExp/blob/pheno-plumber/rules/prepare_run_era.py)

- Script:
  [`prepare_run_era.R`](https://github.com/sylvainschmitt/trollExp/blob/pheno-plumber/scripts/prepare_run_era.R)

Prepare climate data as a TROLL input for a defined model and regional
climate model (RCM) for the run with ERA5-Land data.

### [prepare_run_raw](https://github.com/sylvainschmitt/trollExp/blob/pheno-plumber/rules/prepare_run_raw.py)

- Script:
  [`prepare_run_raw.R`](https://github.com/sylvainschmitt/trollExp/blob/pheno-plumber/scripts/prepare_run_raw.R)

Prepare climate data as a TROLL input for a defined model and regional
climate model (RCM) for the run with raw eddy-tower data.

### [run](https://github.com/sylvainschmitt/trollExp/blob/pheno-plumber/rules/run.py)

- Script:
  [`run.R`](https://github.com/sylvainschmitt/trollExp/blob/pheno-plumber/scripts/run.R)

Run a TROLL simulation.

# Singularity

The whole workflow currently rely on the [`singularity-troll`
image](https://github.com/sylvainschmitt/singularity-troll).

# Data

#### **`PLUMBER2`**

- Sites:
  - GF-Guy (Guyaflux)
  - BR-Sa3 (Santarem)
- Variables: GPP, LAI (Copernicus & MODIS), LE
- Periods: 2001:2003 (BR-Sa3) & 2004:2014 (GF-Guy)
- Origin: EddyFlux & satellites
- Link: <https://essd.copernicus.org/articles/14/449/2022/>
