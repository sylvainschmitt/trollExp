trollExp - Run a TROLL experiment with logging
================
Sylvain Schmitt
Jully 18, 2023

- [Installation](#installation)
- [Usage](#usage)
- [Workflow](#workflow)
- [Singularity](#singularity)
- [Data](#data)

[`singularity` &
`snakemake`](https://github.com/sylvainschmitt/snakemake_singularity)
workflow to run a TROLL experiment with logging

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
git checkout logging
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

### [spinup_years](https://github.com/sylvainschmitt/trollExp/blob/logging/rules/spinup_years.smk)

- Script:
  [`spinup_years.R`](https://github.com/sylvainschmitt/trollExp/blob/logging/scripts/spinup_years.R)

Define years from the historical period for the spin-up simulations.

### [prepare_spinup](https://github.com/sylvainschmitt/trollExp/blob/logging/rules/prepare_spinup.smk)

- Script:
  [`prepare_spinup.R`](https://github.com/sylvainschmitt/trollExp/blob/logging/scripts/prepare_spinupe.R)

Prepare spin-up data as a TROLL input from ERA5-Land.

### [spinup](https://github.com/sylvainschmitt/trollExp/blob/logging/rules/spinup.smk)

- Script:
  [`spinup.R`](https://github.com/sylvainschmitt/trollExp/blob/logging/scripts/spinup.R)

Run a TROLL simulation for the 600-years spin-up with historical
climate.

### [log](https://github.com/sylvainschmitt/trollExp/blob/logging/rules/log.smk)

- Script:
  [`log.R`](https://github.com/sylvainschmitt/trollExp/blob/logging/scripts/log.R)

Run a LoggingLab simulation of selective logging with a TROLL simulation
inventory.

### [postlog](https://github.com/sylvainschmitt/trollExp/blob/logging/rules/postlog.smk)

- Script:
  [`postlog.R`](https://github.com/sylvainschmitt/trollExp/blob/logging/scripts/postlog.R)

Run a TROLL simulation during 10 years after the selective logging
simulation.

### [damage](https://github.com/sylvainschmitt/trollExp/blob/logging/rules/damage.smk)

- Script:
  [`damage.R`](https://github.com/sylvainschmitt/trollExp/blob/logging/scripts/damage.R)

Apply gap damages to the TROLL simulation 10 years after selective
logging.

### [recover](https://github.com/sylvainschmitt/trollExp/blob/logging/rules/recover.smk)

- Script:
  [`recover.R`](https://github.com/sylvainschmitt/trollExp/blob/logging/scripts/recover.R)

Run a TROLL simulation of recovery after the selective logging
simulation and 10-years gap damages.

### Outputs

*Todo.*

# Singularity

The workflow currently rely on:

- the [`singularity-troll`
  image](https://github.com/sylvainschmitt/singularity-troll)
- the [`singularity-LoggingLab`
  image](https://github.com/sylvainschmitt/singularity-LoggingLab)

# Data

#### **ERA5-Land**

- A global reanalysis dataset (Munoz-Sabater et al. 2021)
- Access from Copernicus eased by
  [`rcontroll`](https://sylvainschmitt.github.io/rcontroll/articles/climate.html)
  *(getEra workflow in preparation)*
- Currently 2004 to 2022 (can go 1950)
- VPD from dew point
