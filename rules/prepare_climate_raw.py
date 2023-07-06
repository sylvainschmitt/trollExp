rule prepare_climate_raw:
    input:
        "data/guyaflux_filled.tsv"
    output:
        tab="results/simulations/GF-Guy-Raw_climate.tsv",
        fig="results/simulations/GF-Guy-Raw_climate.png"
    log:
        "results/logs/prepare_climate_raw.log"
    benchmark:
        "results/benchmarks/prepare_climate_raw.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        spinup=config["spinup"],
        seed=config["seed"],
        site="GF-Guy-ERA5"
    script:
        "../scripts/prepare_climate_raw.R"
        
