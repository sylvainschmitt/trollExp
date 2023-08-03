configfile: "config/config_dag.yml"

rule all:
   input:
        expand("results/cycle_{cycle}/recover/{scenario}_{duration}",
                cycle=config["cycles"],
                scenario=config["scenarios"],
                duration=config["durations"])
                
# Rules #

include: "rules/spinup_years.py"
include: "rules/prepare_spinup.py"
include: "rules/spinup.py"
include: "rules/log.py"
include: "rules/postlog.py"
include: "rules/damage.py"
include: "rules/recover.py"
