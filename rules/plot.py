rule plot:
    input:
        "results/spinup/projection.nc"
    output:
        fig="results/spinup/projection.png",
        anim="results/spinup/projection.gif"
    log:
        "results/logs/plot.log"
    benchmark:
        "results/benchmarks/plot.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    script:
        "../scripts/plot.R"
