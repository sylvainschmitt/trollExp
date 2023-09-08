rule format:
    input:
        "results/data/{site}_raw.csv",
    output:
        "results/data/{site}_climate.tsv"
    log:
        "results/logs/format_{site}.log"
    benchmark:
        "results/benchmarks/format_{site}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        site="{site}"
    script:
        "../scripts/format.R"
        
