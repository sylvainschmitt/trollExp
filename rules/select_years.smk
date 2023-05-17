rule select_years:
    input:
        "results/data/climate/guyaflux.tsv"
    output:
        "results/simulations/{type}/{period}/selected_years.tsv",
        "results/simulations/{type}/{period}/selected_years.png"
    log:
        "results/logs/select_years_{type}_{period}.log"
    benchmark:
        "results/benchmarks/select_years_{type}_{period}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        type="{type}",
        period="{period}",
        mature_years=config["mature_years"],
        data_path=config["data_path"],
        seed=config["seed"]
    script:
        "../scripts/select_years.R"
        
