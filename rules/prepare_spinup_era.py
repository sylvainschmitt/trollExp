rule prepare_spinup_era:
    input:
        "data/ERA5land_Paracou.tsv"
    output:
        tab="results/spinup/GF-Guy-ERA5_climate.tsv",
        fig="results/spinup/GF-Guy-ERA5_climate.png"
    log:
        "results/logs/prepare_spinup_era.log"
    benchmark:
        "results/benchmarks/prepare_spinup_era.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        spinup=config["spinup"],
        seed=config["seed"],
        site="GF-Guy-ERA5"
    script:
        "../scripts/prepare_spinup_era.R"
        
