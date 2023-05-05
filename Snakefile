configfile: "config/config_test.yml"

rule all:
   input:
        # current
        expand("results/simulations/current/{period}/{climate}/historical/{repetition}",
                 climate=config["current_climate"],
                 period=config["current_period"],
                 repetition=config["current_repetitions"]),
        # projections
        expand("results/simulations/projections/{period}/{model}_{rcm}/{scenario}/{repetition}",
                 model=config["proj_model"],
                 rcm=config["proj_rcm"],
                 period=config["proj_period"],
                 scenario=config["proj_scenario"],
                 repetition=config["proj_repetitions"])
                
# Rules #
include: "rules/select_years.smk"
include: "rules/prepare_climate.smk"
include: "rules/troll_warm.smk"
include: "rules/troll_exp.smk"
