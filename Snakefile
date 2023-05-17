configfile: "config/config.yml"

rule all:
   input:
        expand("results/simulations/{output}.tsv",
                output=["trajectory", "species", "forest"])
                 
# Rules #

## Prepare soil ##
include: "rules/get_soil.smk"
include: "rules/extract_soil.smk"

## Run TROLL ##
include: "rules/troll_warm.smk"

## TROLL outputs ##
include: "rules/gather_warm.smk"
