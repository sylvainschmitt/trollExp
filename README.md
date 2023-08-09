trollExp - Run a regional TROLL experiment
================
Sylvain Schmitt
May 5, 2023

- [Installation](#installation)
- [Usage](#usage)
- [Workflow](#workflow)
- [Singularity](#singularity)
- [Data](#data)

[`singularity` &
`snakemake`](https://github.com/sylvainschmitt/snakemake_singularity)
workflow to run a regional TROLL experiment.

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
git checkout regional
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

### [prepare_spatial_data](https://github.com/sylvainschmitt/trollExp/blob/climate/rules/prepare_spatial_data.py)

- Script:
  [`prepare_spatial_data.R`](https://github.com/sylvainschmitt/trollExp/blob/climate/scripts/prepare_spatial_data.R)

Prepare soil and climate spatial data for common extent and resolution.

### [spinup_years](https://github.com/sylvainschmitt/trollExp/blob/climate/rules/spinup_years.smk)

- Script:
  [`spinup_years.R`](https://github.com/sylvainschmitt/trollExp/blob/climate/scripts/spinup_years.R)

Define years from the historical period for the spin-up simulations.

### [prepare_spinup_climate](https://github.com/sylvainschmitt/trollExp/blob/climate/rules/prepare_spinup_climate.smk)

- Script:
  [`prepare_spinup_climate.R`](https://github.com/sylvainschmitt/trollExp/blob/climate/scripts/prepare_spinup_climate.R)

Prepare spin-up climate data as a TROLL input from ERA5-Land data.

### [prepare_spinup_soil](https://github.com/sylvainschmitt/trollExp/blob/climate/rules/prepare_spinup_soil.smk)

- Script:
  [`prepare_spinup_climate.R`](https://github.com/sylvainschmitt/trollExp/blob/climate/scripts/prepare_spinup_soil.R)

Prepare spin-up soil data as a TROLL input from METRAADICA soil data.

### [prepare_spinup_species](https://github.com/sylvainschmitt/trollExp/blob/climate/rules/prepare_spinup_species.smk)

- Script:
  [`prepare_spinup_species.R`](https://github.com/sylvainschmitt/trollExp/blob/climate/scripts/prepare_spinup_species.R)

Prepare spin-up species data as a TROLL input from gathered functional
trait data (dummy for the moment).

### [spinup](https://github.com/sylvainschmitt/trollExp/blob/climate/rules/spinup.smk)

- Script:
  [`spinup.R`](https://github.com/sylvainschmitt/trollExp/blob/climate/scripts/spinup.R)

Run a TROLL simulation for the 600-years spin-up with historical
climate.

### [summarise](https://github.com/sylvainschmitt/trollExp/blob/climate/rules/summarise.smk)

- Script:
  [`summarise.R`](https://github.com/sylvainschmitt/trollExp/blob/climate/scripts/summarise.R)

Summarise a 600 year TROLL simulation in one table to free disk space
and prepare aggregation.

### [assemble](https://github.com/sylvainschmitt/trollExp/blob/climate/rules/assemble.smk)

- Script:
  [`assemble.R`](https://github.com/sylvainschmitt/trollExp/blob/climate/scripts/assemble.R)

Assemble all TROLL simulations in a single raster or netcdf file.

### [plot](https://github.com/sylvainschmitt/trollExp/blob/climate/rules/plot.smk)

- Script:
  [`plot`](https://github.com/sylvainschmitt/trollExp/blob/climate/scripts/plot.R)

Plot the resulting mean values of variable over the 100 last years and
build animation of a typical year dynamic.

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

#### **METRADICA**

1kmx1km soil texture information for French Guiana. We will use
following variables for TROLL:

- silt: proportion of silt
- clay: proportion of clay
- sand: proportion of sand

### Aggregated species

See [ALT - Biodiversity
pages](https://main--altpages.netlify.app/biodiviersity-introduction).
