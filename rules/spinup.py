rule spinup:
    input:
        species="results/spinup/coms.tsv"
    output:
        directory("results/spinup/SR{richness}_REP{rep}")
    log:
        "results/logs/spinup_SR{richness}_REP{rep}.log"
    benchmark:
        "results/benchmarks/spinup_SR{richness}_REP{rep}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        richness="{richness}",
        rep="{rep}",
        spinup=config["spinup"],
        seed=config["seed"],
        verbose=config["verbose"],
        test=config["test"],
        test_years=config["test_years"]
    script:
        "../scripts/spinup.R"
