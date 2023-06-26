rule troll:
    input:
        "results/simulations/{site}_climate.tsv"
    output:
        directory("results/simulations/{site}")
    log:
        "results/logs/troll_{site}.log"
    benchmark:
        "results/benchmarks/troll_{site}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        site="{site}",
        verbose=config["verbose"],
        test=config["test"],
        test_years=config["test_years"]
    script:
        "../scripts/troll.R"
