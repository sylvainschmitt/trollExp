configfile: "config/config.yml"

ruleorder: prepare_spinup > spinup
ruleorder: prepare_run > run

rule all:
   input:
        expand("results/run/{site}",
                site=config["sites"])
                
# Rules #
include: "rules/get_data.py"
include: "rules/prepare_spinup.py"
include: "rules/prepare_spinup_era.py"
include: "rules/prepare_spinup_raw.py"
include: "rules/spinup.py"
include: "rules/prepare_run.py"
include: "rules/prepare_run_era.py"
include: "rules/prepare_run_raw.py"
include: "rules/run.py"
