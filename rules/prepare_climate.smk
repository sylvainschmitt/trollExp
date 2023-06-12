rule prepare_climate:
    input:
        climate="results/data/climate/{model}_{rcm}.tsv",
        years="results/data/climate/selected_years.tsv"
    output:
        "results/simulations/{model}_{rcm}_{exp}_climate.tsv",
        "results/simulations/{model}_{rcm}_{exp}_climate.png"
    log:
        "results/logs/prepare_climate_{model}_{rcm}_{exp}.log"
    benchmark:
        "results/benchmarks/prepare_climate_{model}_{rcm}_{exp}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        model="{model}",
        rcm="{rcm}",
        exp="{exp}",
        warmup=config["warmup"]
    script:
        "../scripts/prepare_climate.R"
        
