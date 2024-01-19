rule run2:
    input:
        "results/run/{site}_climate.tsv",
        "results/run/{site}_{a0}_{b0}_{delta}"
    output:
        directory("results/run2/{site}_{a0}_{b0}_{delta}")
    log:
        "results/logs/run2_{site}_{a0}_{b0}_{delta}.log"
    benchmark:
        "results/benchmarks/run2_{site}_{a0}_{b0}_{delta}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        site="{site}",
        a0="{a0}",
        b0="{b0}",
        delta="{delta}",
        verbose=config["verbose"],
        test=config["test"],
        test_years=config["test_years"]
    script:
        "../scripts/run2.R"
