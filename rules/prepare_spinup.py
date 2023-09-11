rule prepare_spinup:
    input:
        climate="data/ERA5land_Paracou.tsv",
        years="results/spinup/spinup_years.tsv"
    output:
        tab="results/spinup/era_climate.tsv",
        fig="results/spinup/era_climate.png"
    log:
        "results/logs/prepare_spinup.log"
    benchmark:
        "results/benchmarks/prepare_spinup.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    script:
        "../scripts/prepare_spinup.R"
        
