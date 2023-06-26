rule prepare_climate:
    input:
        met="results/data/{site}_FLUXNET2015_Met.nc",
        flux="results/data/{site}_FLUXNET2015_Flux.nc"
    output:
        tab="results/simulations/{site}_climate.tsv",
        fig="results/simulations/{site}_climate.png"
    log:
        "results/logs/prepare_climate_{site}.log"
    benchmark:
        "results/benchmarks/prepare_climate_{site}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        spinup=config["spinup"],
        seed=config["seed"],
        site="{site}"
    script:
        "../scripts/prepare_climate.R"
        
