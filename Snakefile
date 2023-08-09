configfile: "config/config_dag.yml"

cells = list(range(1,config["n_cells"]+1))

rule all:
   input:
        expand("results/spinup/projection.{format}", format=["nc", "png", "gif"])
        # expand("results/run/{model}_{rcm}_{exp}",
        #         model=config["model"],
        #         rcm=config["rcm"],
        #         exp=config["scenario"])
                
# Rules #

include: "rules/prepare_spatial_data.py"
include: "rules/spinup_years.py"
include: "rules/prepare_spinup_climate.py"
include: "rules/prepare_spinup_soil.py"
include: "rules/prepare_spinup_species.py"
include: "rules/spinup.py"
include: "rules/summarise.py"
include: "rules/assemble.py"
include: "rules/plot.py"
