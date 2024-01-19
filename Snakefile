configfile: "config/config_dag.yml"

ruleorder: prepare_spinup > spinup
ruleorder: prepare_run > run

rule all:
   input:
        expand("results/run2/{site}_{a0}_{b0}_{delta}",
                site=config["sites"],
                a0=config["a0"],
                b0=config["b0"],
                delta=config["delta"])
                
# Rules #
include: "rules/rename.py"
include: "rules/format.py"
include: "rules/prepare_spinup.py"
include: "rules/spinup.py"
include: "rules/prepare_run.py"
include: "rules/run.py"
include: "rules/run2.py"
