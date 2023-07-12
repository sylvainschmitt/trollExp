rule run:
    input:
        "results/run/{site}_climate.tsv",
        "results/spinup/{site}"
    output:
        directory("results/run/{site}")
    log:
        "results/logs/run_{site}.log"
    benchmark:
        "results/benchmarks/run_{site}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        site="{site}",
        verbose=config["verbose"],
        test=config["test"],
        test_years=config["test_years"]
    script:
        "../scripts/run.R"
