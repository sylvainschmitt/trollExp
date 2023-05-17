rule prepare_era:
    output:
        "results/data/climate/era.tsv",
        "results/data/climate/era.png"
    log:
        "results/logs/prepare_era.log"
    benchmark:
        "results/benchmarks/prepare_era.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        data_path=config["data_path"]
    script:
        "../scripts/prepare_era.R"
        