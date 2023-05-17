rule prepare_guyaflux:
    output:
        "results/data/climate/guyaflux.tsv",
        "results/data/climate/guyaflux.png"
    log:
        "results/logs/prepare_guyaflux.log"
    benchmark:
        "results/benchmarks/prepare_guyaflux.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        data_path=config["data_path"]
    script:
        "../scripts/prepare_guyaflux.R"
        