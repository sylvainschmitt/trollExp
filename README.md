trollExp - Run a TROLL experiment with soil
================
Sylvain Schmitt
May 16, 2023

- [Installation](#installation)
- [Usage](#usage)
- [Workflow](#workflow)
- [Singularity](#singularity)
- [Data](#data)

[`singularity` &
`snakemake`](https://github.com/sylvainschmitt/snakemake_singularity)
workflow to run a TROLL experiment with soil.

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
git checkout soil
```

# Usage

### Locally

``` bash
snakemake -np -j 1 # dry run
snakemake --dag | dot -Tsvg > dag/dag.svg # dag
snakemake -j 1 --use-singularity --singularity-args "\-e" # run
```

### HPC

``` bash
module load bioinfo/snakemake-5.25.0 # for test on node
snakemake -np # dry run
sbatch job_genologin.sh # run
```

# Workflow

### [extract_soil](https://github.com/sylvainschmitt/trollExp/blob/soil/rules/extract_soil.py)

- Script:
  [`extract_soil.R`](https://github.com/sylvainschmitt/trollExp/blob/soil/scripts/extract_soil.R)

Extract soil data for given plot.

### [spinup](https://github.com/sylvainschmitt/trollExp/blob/soil/rules/spinup.py)

- Script:
  [`spinup.R`](https://github.com/sylvainschmitt/trollExp/blob/soil/scripts/spinup.R)

Run a TROLL spin-up simulation (e.g. creation of a 600-years old mature
forest).

# Singularity

The whole workflow currently rely on the [`singularity-troll`
image](https://github.com/sylvainschmitt/singularity-troll).

# Data

#### **METRADICA**

1kmx1km soil texture information for French Guiana. We will use
following variables for TROLL:

- silt: proportion of silt
- clay: proportion of clay
- sand: proportion of sand

#### **SoilGrids**

250x250m soil information for the globe with quantified spatial
uncertainty ([Poggio et
al. 2021](https://soil.copernicus.org/articles/7/217/2021/)). Available
[online](https://files.isric.org/soilgrids/latest/data/) with an example
[R
script](https://git.wur.nl/isric/soilgrids/soilgrids.notebooks/-/blob/master/markdown/webdav_from_R.md).
We will use following variables for TROLL:

- silt: proportion of silt
- clay: proportion of clay
- sand: proportion of sand
- soc: soil organic content
- bdod: dry bulk density
- phh20: hydrogen ion activity in water  
- cec: cation exchange capacity at ph 7
