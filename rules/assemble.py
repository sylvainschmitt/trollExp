rule assemble:
    input:
        expand("results/spinup/cell_{cell}/troll_summary.tsv", cell=cells)
    output:
        "results/spinup/projection.nc"
    log:
        "results/logs/assemble.log"
    benchmark:
        "results/benchmarks/assemble.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    script:
        "../scripts/assemble.R"
