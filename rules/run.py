rule run:
    input:
        "results/run/{model}_{rcm}_{exp}_climate.tsv",
        "results/spinup/era"
    output:
        directory("results/run/{model}_{rcm}_{exp}")
    log:
        "results/logs/run_{model}_{rcm}_{exp}.log"
    benchmark:
        "results/benchmarks/run_{model}_{rcm}_{exp}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        model="{model}",
        rcm="{rcm}",
        exp="{exp}",
        verbose=config["verbose"],
        test=config["test"],
        test_years=config["test_years"]
    script:
        "../scripts/run.R"
