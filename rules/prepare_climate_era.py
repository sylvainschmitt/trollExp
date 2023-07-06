rule prepare_climate_era:
    input:
        "data/ERA5land_Paracou.tsv"
    output:
        tab="results/simulations/GF-Guy-ERA5_climate.tsv",
        fig="results/simulations/GF-Guy-ERA5_climate.png"
    log:
        "results/logs/prepare_climate_era.log"
    benchmark:
        "results/benchmarks/prepare_climate_era.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        spinup=config["spinup"],
        seed=config["seed"],
        site="GF-Guy-ERA5"
    script:
        "../scripts/prepare_climate_era.R"
        
