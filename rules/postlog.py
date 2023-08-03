rule postlog:
    input:
        log_input,
        "results/cycle_{cycle}/log/{scenario}_{duration}.Rdata"
    output:
        directory("results/cycle_{cycle}/postlog/{scenario}_{duration}")
    log:
        "results/logs/postlog_{cycle}_{scenario}_{duration}.log"
    benchmark:
        "results/benchmarks/postlog_{cycle}_{scenario}_{duration}.benchmark.txt"
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
        "../scripts/postlog.R"
