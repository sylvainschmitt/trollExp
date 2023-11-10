rule spinup:
    input:
        "results/spinup/{site}_climate.tsv",
        "results/data/{site}_species.tsv",
        "results/data/{site}_soil.tsv"
    output:
        directory("results/spinup/{site}")
    log:
        "results/logs/spinup_{site}.log"
    benchmark:
        "results/benchmarks/spinup_{site}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        site="{site}",
        verbose=config["verbose"],
        test=config["test"],
        test_years=config["test_years"]
    script:
        "../scripts/spinup.R"
