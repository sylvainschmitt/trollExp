rule sample_coms:
    input:
        species="data/troll_species.tsv"
    output:
        tab="results/spinup/coms.tsv",
        fig="results/spinup/coms.png"
    log:
        "results/logs/sample_coms.log"
    benchmark:
        "results/benchmarks/sample_coms.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        richness=config["richness"],
        repetitions=config["repetitions"]
    script:
        "../scripts/sample_coms.R"
