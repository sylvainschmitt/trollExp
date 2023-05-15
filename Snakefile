configfile: "config/config_test.yml"

rule all:
   input:
        # expand("results/soil/rasters/{par}_{depth}.tif",
        #          par=config["soil_pars"],
        #          depth=config["depth"])
        expand("results/soil/tables/soil_{depth}.tsv",
                 depth=config["depth"])
                 
# Rules #

## Prepare soil ##
include: "rules/get_soil.smk"
include: "rules/extract_soil.smk"
