rule sample_climate:
    input:
        "results/data/climate/{climate}.tsv",
        "results/simulations/{type}/{period}/selected_years.tsv"
    output:
        "results/simulations/{type}/{period}/{climate}/{climate}_sampled.tsv",
        "results/simulations/{type}/{period}/{climate}/{climate}_sampled.png"
    log:
        "results/logs/sample_climate_{type}_{period}_{climate}.log"
    benchmark:
        "results/benchmarks/sample_climate_{type}_{period}_{climate}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        type="{type}",
        period="{period}",
        climate="{climate}",
        data_path=config["data_path"]
    script:
        "../scripts/sample_climate.R"
        
