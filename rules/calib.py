rule calib:
    input:
        expand("results/run2/{site}_{a0}_{b0}_{delta}",
                site=config["sites"],
                a0=config["a0"],
                b0=config["b0"],
                delta=config["delta"])
    output:
        directory("results/calib")
    log:
        "results/logs/calib.log"
    benchmark:
        "results/benchmarks/calib.benchmark.txt"
    params:
        files = lambda wildcards, input: [x + "/*_sumstats.txt" for x in input]
    shell:
        "mkdir {output} ; "
        "cp {params.files} {output}"
