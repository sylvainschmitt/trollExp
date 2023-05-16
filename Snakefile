configfile: "config/config.yml"

rule all:
   input:
        expand("results/soil/soil_{area}.tsv",
                 area=config["area"])
                 
# Rules #

## Prepare soil ##
include: "rules/get_soil.smk"
include: "rules/extract_soil.smk"
