rule prepare_climate:
    input:
        era=config["era"],
        climate="results/climate/projection/{model}_{rcm}_{exp}.tsv",
        years="results/climate/spinup_years.tsv"
    output:
        tab="results/simulations/{model}_{rcm}_{exp}_climate.tsv",
        fig="results/simulations/{model}_{rcm}_{exp}_climate.png"
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
        exp="{exp}"
    script:
        "../scripts/prepare_climate.R"
        