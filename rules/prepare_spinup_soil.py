rule prepare_spinup_soil:
    input:
        "results/data/soil.tsv"
    output:
        "results/spinup/cell_{cell}/soil.tsv"
    log:
        "results/logs/prepare_spinup_soil_{cell}.log"
    benchmark:
        "results/benchmarks/prepare_spinup_soil_{cell}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        cell="{cell}"
    script:
        "../scripts/prepare_spinup_soil.R"
