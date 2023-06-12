rule troll:
    input:
        "results/simulations/{model}_{rcm}_{exp}_climate.tsv"
    output:
        directory("results/simulations/{model}_{rcm}_{exp}")
    log:
        "results/logs/troll_{model}_{rcm}_{exp}.log"
    benchmark:
        "results/benchmarks/troll_{model}_{rcm}_{exp}.benchmark.txt"
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
        "../scripts/troll.R"
