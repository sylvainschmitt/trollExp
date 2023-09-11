trollExp - Run a TROLL experiment with biodiversity
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
workflow to run a TROLL experiment with biodiversity

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
git checkout biodiv
```

# Usage

### Locally

``` bash
snakemake -np -j 1 # dry run
snakemake --dag | dot -Tsvg > dag/dag.svg # dag
snakemake -j 1 --use-singularity # run
```

### HPC

``` bash
module load bioinfo/snakemake-5.25.0 # for test on node
snakemake -np # dry run
sbatch job_genologin.sh # run
```

# Workflow

### [sample_coms](https://github.com/sylvainschmitt/trollExp/blob/biodiv/rules/sample_coms.py)

- Script:
  [`sample_coms.R`](https://github.com/sylvainschmitt/trollExp/blob/biodiv/scripts/sample_coms.R)

Sample communities for the biodiviersity experiment.

### [spinup](https://github.com/sylvainschmitt/trollExp/blob/biodiv/rules/spinup.py)

- Script:
  [`spinup.R`](https://github.com/sylvainschmitt/trollExp/blob/biodiv/scripts/spinup.R)

Run a TROLL spin-up simulation (e.g. creation of a 600-years old mature
forest).

# Singularity

The whole workflow currently rely on the [`singularity-troll`
image](https://github.com/sylvainschmitt/singularity-troll).

# Data

Combined functional trait data from:

- Maréchaux et al., (2015)
- Santiago et al., (2018)
- Vleminckx et al., (2021)
- Guillemot et al., (2022)
- Jucker et al., (2022)
- Krebber et al., (in prep)
- TROLL V4
