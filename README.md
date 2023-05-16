trollExp - Run a TROLL experiment with soil
================
Sylvain Schmitt
May 16, 2023

- <a href="#installation" id="toc-installation">Installation</a>
- <a href="#usage" id="toc-usage">Usage</a>
  - <a href="#locally" id="toc-locally">Locally</a>
  - <a href="#hpc" id="toc-hpc">HPC</a>
- <a href="#workflow" id="toc-workflow">Workflow</a>
  - <a href="#soil" id="toc-soil">Soil</a>
- <a href="#singularity" id="toc-singularity">Singularity</a>
- <a href="#data" id="toc-data">Data</a>
  - <a href="#soil-1" id="toc-soil-1">Soil</a>

[`singularity` &
`snakemake`](https://github.com/sylvainschmitt/snakemake_singularity)
workflow to run a TROLL experiment with soil.

![Workflow.](dag/dag.svg)

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

## Locally

``` bash
snakemake -np -j 1 # dry run
snakemake --dag | dot -Tsvg > dag/dag.svg # dag
snakemake -j 20 --use-singularity --singularity-args "\-e" # run
```

## HPC

### Muse

``` bash
module load snakemake # for test on node
snakemake -np # dry run
sbatch job_muse.sh # run
```

### Genologin

``` bash
module load bioinfo/snakemake-5.25.0 # for test on node
snakemake -np # dry run
sbatch job_genologin.sh # run
```

# Workflow

## Soil

### [get_soil](https://github.com/sylvainschmitt/trollExp/blob/main/rules/get_soil.smk)

- Script:
  [`get_soil.R`](https://github.com/sylvainschmitt/trollExp/blob/main/scripts/get_soilx.R)

Download SoildGrids data for a given variable and depth.

### [extract_soil](https://github.com/sylvainschmitt/trollExp/blob/main/rules/extract_soil.smk)

- Script:
  [`extract_soil.R`](https://github.com/sylvainschmitt/trollExp/blob/main/scripts/extract_soil.R)

Extract soil data for given addresses.

<!-- ## Run TROLL -->
<!-- ### [troll_warm](https://github.com/sylvainschmitt/trollExp/blob/main/rules/troll_warm.smk) -->
<!-- * Script: [`troll_warm.R`](https://github.com/sylvainschmitt/trollExp/blob/main/scripts/troll_warm.R) -->
<!-- Run a TROLL warm up simulation before an experiments (e.g. creation of a 600-years old mature forest). -->
<!-- ### [troll_exp](https://github.com/sylvainschmitt/trollExp/blob/main/rules/troll_exp.smk) -->
<!-- * Script: [`troll_exp.R`](https://github.com/sylvainschmitt/trollExp/blob/main/scripts/troll_exp.R) -->
<!-- Run a TROLL simulation for an experiments. -->

# Singularity

The whole workflow currently rely on the [`singularity-troll`
image](https://github.com/sylvainschmitt/singularity-troll).

> Need to add: gdalUtilities, sf, osmdata, nominatimlite, corrplot,
> ggtern

# Data

## Soil

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
