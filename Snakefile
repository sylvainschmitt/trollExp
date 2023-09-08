configfile: "config/config.yml"

ruleorder: prepare_spinup > spinup
ruleorder: prepare_run > run

rule all:
   input:
        expand("results/run/{site}",
                site=config["sites"])
                
# Rules #
include: "rules/rename.py"
include: "rules/format.py"
include: "rules/prepare_spinup.py"
include: "rules/spinup.py"
include: "rules/prepare_run.py"
include: "rules/run.py"
