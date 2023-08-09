rule prepare_spinup_species:
    input:
        "data/species/troll_species.tsv"
    output:
        "results/spinup/cell_{cell}/species.tsv"
    log:
        "results/logs/prepare_spinup_species_{cell}.log"
    benchmark:
        "results/benchmarks/prepare_spinup_species_{cell}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        cell="{cell}"
    script:
        "../scripts/prepare_spinup_species.R"
