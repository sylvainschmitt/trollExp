trollExp - Run a TROLL experiment
================
Sylvain Schmitt
May 5, 2023

- <a href="#installation" id="toc-installation">Installation</a>
- <a href="#usage" id="toc-usage">Usage</a>
  - <a href="#locally" id="toc-locally">Locally</a>
  - <a href="#hpc" id="toc-hpc">HPC</a>
- <a href="#workflow" id="toc-workflow">Workflow</a>

[`singularity` &
`snakemake`](https://github.com/sylvainschmitt/snakemake_singularity)
workflow to run a TROLL experiment.

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
```

# Usage

## Locally

``` bash
snakemake -np -j 1 # dry run
snakemake --dag | dot -Tsvg > dag/dag.svg # dag
snakemake -j 1 --use-singularity # run
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

### [select_years](https://github.com/sylvainschmitt/trollExp/blob/main/rules/select_years.smk)

- Script:
  [`select_years.R`](https://github.com/sylvainschmitt/trollExp/blob/main/scripts/select_years.R)

Define years for the warm-up simulations.

### [prepare_climate](https://github.com/sylvainschmitt/trollExp/blob/main/rules/prepare_climate.smk)

- Script:
  [`prepare_climate.R`](https://github.com/sylvainschmitt/trollExp/blob/main/scripts/prepare_climate.R)

Prepare climate data as a TROLL input for defined years for the warm-up
simulations.

### [troll_warm](https://github.com/sylvainschmitt/trollExp/blob/main/rules/troll_warm.smk)

- Script:
  [`troll_warm.R`](https://github.com/sylvainschmitt/trollExp/blob/main/scripts/troll_warm.R)

Run a TROLL warm up simulation before an experiments (e.g. creation of a
600-years old mature forest).

### [troll_exp](https://github.com/sylvainschmitt/trollExp/blob/main/rules/troll_exp.smk)

- Script:
  [`troll_exp.R`](https://github.com/sylvainschmitt/trollExp/blob/main/scripts/troll_exp.R)

Run a TROLL simulation for an experiments.
