configfile: "config/config.yml"

ruleorder: troll_warm > troll_exp

rule all:
   input:
        # current
        # expand("results/simulations/current/{period}/{climate}/historical/R{repetition}",
        #          climate=config["current_climate"],
        #          period=config["current_period"],
        #          repetition=config["current_repetitions"]),
        expand("results/tables/period/current_{period}_{output}.tsv",
                 period=config["current_period"],
                 output=["trajectory", "species", "forest"]),
        # projections
        # expand("results/simulations/projections/{period}/{model}_{rcm}/{scenario}/R{repetition}",
        #          model=config["proj_model"],
        #          rcm=config["proj_rcm"],
        #          period=config["proj_period"],
        #          scenario=config["proj_scenario"],
        #          repetition=config["proj_repetitions"]),
        expand("results/tables/period/projections_{period}_{output}.tsv",
                 period=config["proj_period"],
                 output=["trajectory", "species", "forest"])
                
# Rules #

## Prepare climate ##
include: "rules/prepare_guyaflux.smk"
include: "rules/prepare_era.smk"
include: "rules/prepare_cordex.smk"

## Prepare TROLL inputs ##
include: "rules/select_years.smk"
include: "rules/sample_climate.smk"

## Run TROLL ##
include: "rules/troll_warm.smk"
include: "rules/troll_exp.smk"

## TROLL outputs ##
include: "rules/gather_repetition_current.smk"
include: "rules/gather_repetition_projections.smk"
include: "rules/gather_period_current.smk"
include: "rules/gather_period_projections.smk"
