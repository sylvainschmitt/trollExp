rule prepare_run:
    input:
        climate="data/cordex_adjusted.tsv"
    output:
        tab="results/run/{model}_{rcm}_{exp}_climate.tsv",
        fig="results/run/{model}_{rcm}_{exp}_climate.png"
    log:
        "results/logs/prepare_run_{model}_{rcm}_{exp}.log"
    benchmark:
        "results/benchmarks/prepare_run_{model}_{rcm}_{exp}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        model="{model}",
        rcm="{rcm}",
        exp="{exp}"
    script:
        "../scripts/prepare_run.R"
        
