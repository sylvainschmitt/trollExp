rule select_years:
    output:
        "results/simulations/{type}/{period}/selected_years.tsv"
    log:
        "results/logs/select_years_{type}_{period}.log"
    benchmark:
        "results/benchmarks/select_years_{type}_{period}.benchmark.txt"
    singularity: 
        "https://github.com/sylvainschmitt/singularity-troll/releases/download/0.0.2/sylvainschmitt-singularity-troll.latest.sif"
    threads: 1
    params:
        type="{type}",
        period="{period}",
        verbose=config["verbose"]
    script:
        "../scripts/select_years.R"
        