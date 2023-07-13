rule prepare_spinup:
    input:
        climate="data/cordex_adjusted.tsv",
        years="results/climate/spinup_years.tsv"
    output:
        tab="results/spinup/{model}_{rcm}_climate.tsv",
        fig="results/spinup/{model}_{rcm}_climate.png"
    log:
        "results/logs/prepare_spinup_{model}_{rcm}.log"
    benchmark:
        "results/benchmarks/prepare_spinup_{model}_{rcm}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        model="{model}",
        rcm="{rcm}"
    script:
        "../scripts/prepare_spinup.R"
        
