rule prepare_spinup:
    input:
        met="results/data/{site}_FLUXNET2015_Met.nc",
        flux="results/data/{site}_FLUXNET2015_Flux.nc"
    output:
        tab="results/spinup/{site}_climate.tsv",
        fig="results/spinup/{site}_climate.png"
    log:
        "results/logs/prepare_spinup_{site}.log"
    benchmark:
        "results/benchmarks/prepare_spinup_{site}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        spinup=config["spinup"],
        seed=config["seed"],
        site="{site}"
    script:
        "../scripts/prepare_spinup.R"
        
