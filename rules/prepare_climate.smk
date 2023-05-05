rule prepare_climate:
    input:
        "results/simulations/{type}/{period}/selected_years.tsv"
    output:
        "results/simulations/{type}/{period}/{climate}/{climate}_sampled.tsv",
        "results/simulations/{type}/{period}/{climate}/{climate}_sampled.png"
    log:
        "results/logs/prepare_climate_{type}_{period}_{climate}.log"
    benchmark:
        "results/benchmarks/prepare_climate_{type}_{period}_{climate}.benchmark.txt"
    singularity: 
        "https://github.com/sylvainschmitt/singularity-troll/releases/download/0.0.2/sylvainschmitt-singularity-troll.latest.sif"
    threads: 1
    params:
        type="{type}",
        period="{period}",
        climate="{climate}",
        data_path=config["data_path"]
    script:
        "../scripts/prepare_climate.R"
        
