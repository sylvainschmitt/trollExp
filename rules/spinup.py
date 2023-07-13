rule spinup:
    input:
        "results/spinup/{model}_{rcm}_climate.tsv"
    output:
        directory("results/spinup/{model}_{rcm}")
    log:
        "results/logs/spinup_{model}_{rcm}.log"
    benchmark:
        "results/benchmarks/spinup_{model}_{rcm}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        model="{model}",
        rcm="{rcm}",
        verbose=config["verbose"],
        test=config["test"],
        test_years=config["test_years"]
    script:
        "../scripts/spinup.R"
