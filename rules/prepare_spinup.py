rule prepare_spinup:
    input:
        "results/data/{site}_climate.tsv",
    output:
        tab="results/spinup/{site}_climate.tsv",
        fig="results/spinup/{site}_climate.png"
    log:
        "results/logs/prepare_spinup_{site}.log"
    benchmark:
        "results/benchmarks/prepare_spinup_{site}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        spinup=config["spinup"],
        seed=config["seed"],
        site="{site}"
    script:
        "../scripts/prepare_spinup.R"
        
