rule prepare_run:
    input:
        met="results/data/{site}_FLUXNET2015_Met.nc",
        flux="results/data/{site}_FLUXNET2015_Flux.nc"
    output:
        tab="results/run/{site}_climate.tsv",
        fig="results/run/{site}_climate.png"
    log:
        "results/logs/prepare_run_{site}.log"
    benchmark:
        "results/benchmarks/prepare_run_{site}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        site="{site}"
    script:
        "../scripts/prepare_run.R"
        
