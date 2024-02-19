rule run3:
    input:
        "results/run/{site}_climate.tsv",
        expand("results/run2/{site}_{a0}_{b0}_{delta}",
                a0=config["a0_f"],
                b0=config["b0_f"],
                delta=config["delta_f"], allow_missing=True)
    output:
        directory("results/run3/{site}_R{rep}")
    log:
        "results/logs/run3_{site}_R{rep}.log"
    benchmark:
        "results/benchmarks/run3_{site}_R{rep}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        site="{site}",
        rep="{rep}",
        a0=config["a0_f"],
        b0=config["b0_f"],
        delta=config["delta_f"],
        verbose=config["verbose"],
        test=config["test"],
        test_years=config["test_years"]
    script:
        "../scripts/run3.R"
