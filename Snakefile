# configfile: "config/config.yml"
configfile: "config/config_dag.yml"

ruleorder: prepare_spinup > spinup
ruleorder: prepare_run > run

rule all:
   input:
        expand("results/run/{model}_{rcm}_{exp}",
                model=config["model"],
                rcm=config["rcm"],
                exp=config["scenario"])
                
# Rules #

## Spinup ##
include: "rules/spinup_years.py"
include: "rules/prepare_spinup.py"
include: "rules/spinup.py"

## Run  ##
include: "rules/prepare_run.py"
include: "rules/run.py"

## TROLL outputs ##
