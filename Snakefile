configfile: "config/config.yml"

ruleorder: prepare_climate > troll

rule all:
   input:
        expand("results/simulations/{site}",
                site=config["sites"])
                
# Rules #
include: "rules/get_data.py"
include: "rules/prepare_climate.py"
include: "rules/prepare_climate_era.py"
include: "rules/prepare_climate_raw.py"
include: "rules/troll.py"
