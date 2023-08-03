rule damage:
    input:
        "results/cycle_{cycle}/log/{scenario}_{duration}.Rdata",
        "results/cycle_{cycle}/postlog/{scenario}_{duration}"
    output:
        "results/cycle_{cycle}/damage/{scenario}_{duration}.tsv"
    log:
        "results/logs/damage_{cycle}_{scenario}_{duration}.log"
    benchmark:
        "results/benchmarks/damage_{cycle}_{scenario}_{duration}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        scenario="{scenario}",
        cycle="{cycle}",
        duration="{duration}"
    script:
        "../scripts/damage.R"
