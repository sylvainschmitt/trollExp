rule prepare_spinup_raw:
    input:
        "data/guyaflux_filled.tsv"
    output:
        tab="results/spinup/GF-Guy-Raw_climate.tsv",
        fig="results/spinup/GF-Guy-Raw_climate.png"
    log:
        "results/logs/prepare_spinup_raw.log"
    benchmark:
        "results/benchmarks/prepare_spinup_raw.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        spinup=config["spinup"],
        seed=config["seed"],
        site="GF-Guy-ERA5"
    script:
        "../scripts/prepare_spinup_raw.R"
        
