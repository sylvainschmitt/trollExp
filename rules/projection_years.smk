rule projection_years:
    input:
        era=config["era"]
    output:
        tab="results/climate/projection_years.tsv",
        fig="results/climate/projection_years.png"
    log:
        "results/logs/projection_years.log"
    benchmark:
        "results/benchmarks/projection_years.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        historical=config["historical"],
        seed=config["seed"]
    script:
        "../scripts/projection_years.R"
