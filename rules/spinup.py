rule spinup:
    input:
        "results/soil/soil.tsv"
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
        spinup=config["spinup"],
        seed=config["seed"],
        verbose=config["verbose"],
        test=config["test"],
        test_years=config["test_years"]
    script:
        "../scripts/spinup.R"
