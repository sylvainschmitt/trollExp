rule spinup:
    input:
        climate="results/spinup/cell_{cell}/climate.tsv",
        soil="results/spinup/cell_{cell}/soil.tsv",
        species="results/spinup/cell_{cell}/species.tsv"
    output:
        directory("results/spinup/cell_{cell}/troll")
    log:
        "results/logs/spinup_{cell}.log"
    benchmark:
        "results/benchmarks/spinup_{cell}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        cell="{cell}",
        verbose=config["verbose"],
        test=config["test"],
        test_years=config["test_years"]
    script:
        "../scripts/spinup.R"
