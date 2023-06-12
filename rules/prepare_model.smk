rule prepare_model:
    input:
        "results/data/climate/cordex.tsv"
    output:
        temp("results/data/climate/{model}_{rcm}.tsv")
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
        "../scripts/prepare_model.R"
        
