rule spinup_years:
    output:
        tab="results/spinup/spinup_years.tsv",
        fig="results/spinup/spinup_years.png"
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
