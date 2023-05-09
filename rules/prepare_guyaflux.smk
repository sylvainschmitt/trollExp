rule prepare_guyaflux:
    output:
        "results/data/climate/guyaflux.tsv",
        "results/data/climate/guyaflux.png"
    log:
        "results/logs/prepare_guyaflux.log"
    benchmark:
        "results/benchmarks/prepare_guyaflux.benchmark.txt"
    # singularity: 
    #     "https://github.com/sylvainschmitt/singularity-troll/releases/download/0.0.2/sylvainschmitt-singularity-troll.latest.sif"
    threads: 1
    params:
        data_path=config["data_path"]
    script:
        "../scripts/prepare_guyaflux.R"
        