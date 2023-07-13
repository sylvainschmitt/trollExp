rule spinup:
    input:
        "results/spinup/era_climate.tsv"
    output:
        directory("results/spinup/era")
    log:
        "results/logs/spinup.log"
    benchmark:
        "results/benchmarks/spinup.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        verbose=config["verbose"],
        test=config["test"],
        test_years=config["test_years"]
    script:
        "../scripts/spinup.R"
