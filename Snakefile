configfile: "config/config_calib.yml"

ruleorder: prepare_spinup > spinup
ruleorder: prepare_run > run

reps = list(range(1, config["rep"]+1))

rule all:
   input:
        # calibration
        # expand("results/run2/{site}_{a0}_{b0}_{delta}",
        #         site=config["sites"],
        #         a0=config["a0"],
        #         b0=config["b0"],
        #         delta=config["delta"]),
        # validation
        expand("results/run3/{site}_R{reps}",
                site=config["sites"],
                reps=reps),
        # gather
        "results/calib/"
                
# Rules #
include: "rules/rename.py"
include: "rules/format.py"
include: "rules/prepare_spinup.py"
include: "rules/spinup.py"
include: "rules/prepare_run.py"
include: "rules/run.py"
include: "rules/run2.py"
include: "rules/run3.py"
include: "rules/calib.py"
