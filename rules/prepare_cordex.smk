rule prepare_cordex:
    output:
        "results/data/climate/cordex.tsv",
        "results/data/climate/cordex.png"
    log:
        "results/logs/prepare_cordex.log"
    benchmark:
        "results/benchmarks/prepare_cordex.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        data_path=config["data_path"]
    script:
        "../scripts/prepare_cordex.R"
        