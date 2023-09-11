rule post_years:
    output:
        tab="results/post/post_years.tsv",
        fig="results/post/post_years.png"
    log:
        "results/logs/post_years.log"
    benchmark:
        "results/benchmarks/post_years.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        historical=config["historical"],
        post_ref=config["post_ref"],
        post=config["post"],
        seed=config["seed"]
    script:
        "../scripts/post_years.R"
