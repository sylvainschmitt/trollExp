configfile: "config/config_dag.yml"

ruleorder: prepare_spinup > spinup
ruleorder: prepare_run > run

rule all:
   input:
        expand("results/run2/{site}_{tau}_{delta}",
                site=config["sites"],
                tau=config["tau"],
                delta=config["delta"])
                
# Rules #
include: "rules/rename.py"
include: "rules/format.py"
include: "rules/prepare_spinup.py"
include: "rules/spinup.py"
include: "rules/prepare_run.py"
include: "rules/run.py"
include: "rules/run2.py"
