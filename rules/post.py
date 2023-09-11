rule post:
    input:
        "results/post/{model}_{rcm}_{exp}_climate.tsv",
        "results/run/{model}_{rcm}_{exp}"
    output:
        directory("results/post/{model}_{rcm}_{exp}")
    log:
        "results/logs/post_{model}_{rcm}_{exp}.log"
    benchmark:
        "results/benchmarks/post_{model}_{rcm}_{exp}.benchmark.txt"
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
        "../scripts/post.R"
