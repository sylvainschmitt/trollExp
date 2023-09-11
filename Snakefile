configfile: "config/config_dag.yml"
# configfile: "config/config.yml"

ruleorder: prepare_spinup > spinup
ruleorder: prepare_run > run
ruleorder: prepare_post > post

rule all:
   input:
        expand("results/post/SR{richness}_REP{rep}_{model}_{rcm}_{exp}",
                richness=config["richness"],
                rep=config["repetitions"],
                model=config["model"],
                rcm=config["rcm"],
                exp=config["scenario"])
                 
# Rules #

## Spinup ##
include: "rules/sample_coms.py"
include: "rules/spinup_years.py"
include: "rules/prepare_spinup.py"
include: "rules/spinup.py"

## Run  ##
include: "rules/prepare_run.py"
include: "rules/run.py"

## Post  ##
include: "rules/post_years.py"
include: "rules/prepare_post.py"
include: "rules/post.py"
