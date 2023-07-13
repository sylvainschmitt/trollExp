configfile: "config/config.yml"

rule all:
   input:
        expand("results/spinup/{site}",
                site=config["sites"])
                 
# Rules #
include: "rules/extract_soil.py"
include: "rules/spinup.py"
