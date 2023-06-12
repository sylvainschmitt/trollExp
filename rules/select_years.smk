rule select_years:
    input:
        "results/data/climate/cordex.tsv"
    output:
        "results/data/climate/selected_years.tsv",
        "results/data/climate/selected_years.png"
    log:
        "results/logs/select_years.log"
    benchmark:
        "results/benchmarks/select_years.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        warmup=config["warmup"],
        seed=config["seed"]
    script:
        "../scripts/select_years.R"
