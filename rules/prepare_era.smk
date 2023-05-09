rule prepare_era:
    output:
        "results/data/climate/era.tsv"
    log:
        "results/logs/prepare_era.log"
    benchmark:
        "results/benchmarks/prepare_era.benchmark.txt"
    # singularity: 
    #     "https://github.com/sylvainschmitt/singularity-troll/releases/download/0.0.2/sylvainschmitt-singularity-troll.latest.sif"
    threads: 1
    params:
        data_path=config["data_path"]
    script:
        "../scripts/prepare_era.R"
        