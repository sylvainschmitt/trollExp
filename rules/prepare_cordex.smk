rule prepare_cordex:
    input:
        cordex=config["cordex"],
        era=config["era"]
    output:
        tab="results/climate/cordex_adjusted/{model}_{rcm}.tsv",
        fig="results/climate/cordex_adjusted/{model}_{rcm}.png"
    log:
        "results/logs/prepare_{model}_{rcm}.log"
    benchmark:
        "results/benchmarks/prepare_{model}_{rcm}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        model="{model}",
        rcm="{rcm}"
    script:
        "../scripts/prepare_cordex.R"
        