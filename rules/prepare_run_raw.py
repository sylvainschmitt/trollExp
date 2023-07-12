rule prepare_run_raw:
    input:
        "data/guyaflux_filled.tsv"
    output:
        tab="results/run/GF-Guy-Raw_climate.tsv",
        fig="results/run/GF-Guy-Raw_climate.png"
    log:
        "results/logs/prepare_run_raw.log"
    benchmark:
        "results/benchmarks/prepare_run_raw.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        site="GF-Guy-ERA5"
    script:
        "../scripts/prepare_run_raw.R"
        
