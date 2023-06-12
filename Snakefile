configfile: "config/config_test.yml"
# configfile: "config/config.yml"

ruleorder: prepare_climate > troll

rule all:
   input:
        expand("results/simulations/{model}_{rcm}_{exp}",
                model=config["model"],
                rcm=config["rcm"],
                exp=config["scenario"])
                
# Rules #

## Prepare climate ##
include: "rules/prepare_cordex.smk"
include: "rules/projection_years.smk"
include: "rules/prepare_projection.smk"

## Prepare TROLL inputs ##
include: "rules/spinup_years.smk"
include: "rules/prepare_climate.smk"

## Run TROLL ##
include: "rules/troll.smk"

## TROLL outputs ##
