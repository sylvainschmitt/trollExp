rule run2:
    input:
        "results/run/{site}_climate.tsv",
        "results/run/{site}_{tau}_{delta}"
    output:
        directory("results/run2/{site}_{tau}_{delta}")
    log:
        "results/logs/run2_{site}_{tau}_{delta}.log"
    benchmark:
        "results/benchmarks/run2_{site}_{tau}_{delta}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        site="{site}",
        tau="{tau}",
        delta="{delta}",
        verbose=config["verbose"],
        test=config["test"],
        test_years=config["test_years"]
    script:
        "../scripts/run2.R"
