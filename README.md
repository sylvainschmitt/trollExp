trollExp - Run a TROLL experiment with phenology
================
Sylvain Schmitt
June 26, 2023

- [Installation](#installation)
- [Usage](#usage)
- [Workflow](#workflow)
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

### [get_data](https://github.com/sylvainschmitt/trollExp/blob/pheno-plumber/rules/get_fluxes.py)

Download data from PLUMBER2, the flux tower dataset tailored for land
model evaluation (<https://essd.copernicus.org/articles/14/449/2022/>).

### [prepare_climate](https://github.com/sylvainschmitt/trollExp/blob/pheno-plumber/rules/prepare_climate.py)

- Script:
  [`prepare_climate.R`](https://github.com/sylvainschmitt/trollExp/blob/pheno-plumber/scripts/prepare_climate.R)

Prepare climate data as a TROLL input for a defined model and regional
climate model (RCM).

### [troll](https://github.com/sylvainschmitt/trollExp/blob/pheno-plumber/rules/troll.py)

- Script:
  [`troll.R`](https://github.com/sylvainschmitt/trollExp/blob/pheno-plumber/scripts/troll.R)

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
