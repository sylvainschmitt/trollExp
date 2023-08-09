rule summarise:
    input:
        "results/spinup/cell_{cell}/troll"
    output:
        "results/spinup/cell_{cell}/troll_summary.tsv"
    log:
        "results/logs/summarise_{cell}.log"
    benchmark:
        "results/benchmarks/summarise_{cell}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        cell="{cell}"
    script:
        "../scripts/summarise.R"
