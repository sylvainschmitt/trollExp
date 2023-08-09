rule prepare_spinup_climate:
    input:
        climate="results/data/climate.tsv",
        years="results/data/spinup_years.tsv"
    output:
        "results/spinup/cell_{cell}/climate.tsv"
    log:
        "results/logs/prepare_spinup_climate_{cell}.log"
    benchmark:
        "results/benchmarks/prepare_spinup_climate_{cell}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        cell="{cell}"
    script:
        "../scripts/prepare_spinup_climate.R"
