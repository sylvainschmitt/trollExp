rule post:
    input:
        "results/post/{model}_{rcm}_{exp}_climate.tsv",
        "results/run/SR{richness}_REP{rep}_{model}_{rcm}_{exp}"
    output:
        directory("results/post/SR{richness}_REP{rep}_{model}_{rcm}_{exp}")
    log:
        "results/logs/post_SR{richness}_REP{rep}_{model}_{rcm}_{exp}.log"
    benchmark:
        "results/benchmarks/post_SR{richness}_REP{rep}_{model}_{rcm}_{exp}.benchmark.txt"
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
        "../scripts/post.R"
