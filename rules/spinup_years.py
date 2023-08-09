rule spinup_years:
    output:
        tab="results/data/spinup_years.tsv",
        fig="results/data/spinup_years.png"
    log:
        "results/logs/select_years.log"
    benchmark:
        "results/benchmarks/select_years.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        historical=config["historical"],
        spinup=config["spinup"],
        seed=config["seed"]
    script:
        "../scripts/spinup_years.R"
