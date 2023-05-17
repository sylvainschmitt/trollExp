rule prepare_cordex:
    output:
        "results/data/climate/{model}_{rcm}.tsv",
        "results/data/climate/{model}_{rcm}.png"
    log:
        "results/logs/prepare_cordex_{model}_{rcm}.log"
    benchmark:
        "results/benchmarks/prepare_cordex_{model}_{rcm}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        model="{model}",
        rcm="{rcm}",
        data_path=config["data_path"]
    script:
        "../scripts/prepare_cordex.R"
        