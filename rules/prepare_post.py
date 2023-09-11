rule prepare_post:
    input:
        climate="data/cordex_adjusted.tsv",
        years="results/post/post_years.tsv"
    output:
        tab="results/post/{model}_{rcm}_{exp}_climate.tsv",
        fig="results/post/{model}_{rcm}_{exp}_climate.png"
    log:
        "results/logs/prepare_post_{model}_{rcm}_{exp}.log"
    benchmark:
        "results/benchmarks/prepare_post_{model}_{rcm}_{exp}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        model="{model}",
        rcm="{rcm}",
        exp="{exp}"
    script:
        "../scripts/prepare_post.R"
        
