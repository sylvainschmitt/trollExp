rule run:
    input:
        "results/run/{model}_{rcm}_{exp}_climate.tsv",
        "results/spinup/SR{richness}_REP{rep}_era"
    output:
        directory("results/run/SR{richness}_REP{rep}_{model}_{rcm}_{exp}")
    log:
        "results/logs/run_SR{richness}_REP{rep}_{model}_{rcm}_{exp}.log"
    benchmark:
        "results/benchmarks/run_SR{richness}_REP{rep}_{model}_{rcm}_{exp}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        richness="{richness}",
        rep="{rep}",
        model="{model}",
        rcm="{rcm}",
        exp="{exp}",
        verbose=config["verbose"],
        test=config["test"],
        test_years=config["test_years"]
    script:
        "../scripts/run.R"
