rule recover:
    input:
        "results/cycle_{cycle}/postlog/{scenario}_{duration}",
        "results/cycle_{cycle}/damage/{scenario}_{duration}.tsv"
    output:
        directory("results/cycle_{cycle}/recover/{scenario}_{duration}")
    log:
        "results/logs/recover_{cycle}_{scenario}_{duration}.log"
    benchmark:
        "results/benchmarks/recover_{cycle}_{scenario}_{duration}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        scenario="{scenario}",
        cycle="{cycle}",
        duration="{duration}",
        verbose=config["verbose"],
        test=config["test"],
        test_years=config["test_years"]
    script:
        "../scripts/recover.R"
