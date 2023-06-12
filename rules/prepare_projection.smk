rule prepare_projection:
    input:
        cordex="results/climate/cordex_adjusted/{model}_{rcm}.tsv",
        era=config["era"],
        years="results/climate/projection_years.tsv"
    output:
        tab="results/climate/projection/{model}_{rcm}_{exp}.tsv",
        fig="results/climate/projection/{model}_{rcm}_{exp}.png"
    log:
        "results/logs/prepare_proj_{model}_{rcm}_{exp}.log"
    benchmark:
        "results/benchmarks/prepare_proj__{model}_{rcm}_{exp}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        model="{model}",
        rcm="{rcm}",
        exp="{exp}"
    script:
        "../scripts/prepare_projection.R"
        