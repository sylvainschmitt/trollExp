def log_input(wc):
    if int(wc.cycle) == 1:
        return "results/spinup/era"
    if int(wc.cycle) > 1:
        prev = int(wc.cycle)-1
        return "results/cycle_" + str(prev) +"/recover/{scenario}_{duration}"

rule log:
    input:
        log_input
    output:
        "results/cycle_{cycle}/log/{scenario}_{duration}.Rdata"
    log:
        "results/logs/log_{cycle}_{scenario}_{duration}.log"
    benchmark:
        "results/benchmarks/log_{cycle}_{scenario}_{duration}.benchmark.txt"
    singularity:
        config["logginglab"]
    threads: 1
    params:
        scenario="{scenario}",
        cycle="{cycle}",
        duration="{duration}"
    script:
        "../scripts/log.R"
