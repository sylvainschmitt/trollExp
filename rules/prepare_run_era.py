rule prepare_run_era:
    input:
        "data/ERA5land_Paracou.tsv"
    output:
        tab="results/run/GF-Guy-ERA5_climate.tsv",
        fig="results/run/GF-Guy-ERA5_climate.png"
    log:
        "results/logs/prepare_run_era.log"
    benchmark:
        "results/benchmarks/prepare_run_era.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        site="GF-Guy-ERA5"
    script:
        "../scripts/prepare_run_era.R"
        
