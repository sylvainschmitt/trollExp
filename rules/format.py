rule format:
    input:
        "data/climate_raw.tsv",
        "data/{site}_species_raw.tsv",
        "data/{site}_soil_raw.tsv"
    output:
        "results/data/{site}_climate.tsv",
        "results/data/{site}_species.tsv",
        "results/data/{site}_soil.tsv"
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
        
