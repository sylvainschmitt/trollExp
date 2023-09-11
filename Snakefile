# configfile: "config/config_dag.yml"
configfile: "config/config.yml"

rule all:
   input:
        expand("results/spinup/SR{richness}_REP{rep}",
                richness=config["richness"],
                rep=config["repetitions"])
                 
# Rules #
include: "rules/sample_coms.py"
include: "rules/spinup.py"
