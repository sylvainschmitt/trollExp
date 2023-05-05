rule troll_warm:
    input:
        "results/simulations/{type}/{period}/{climate}/{climate}_sampled.tsv"
    output:
        directory("results/simulations/{type}/{period}/{climate}/warmup/R{rep}")
    log:
        "results/logs/troll_warm_{type}_{period}_{climate}_R{rep}.log"
    benchmark:
        "results/benchmarks/troll_warm_{type}_{period}_{climate}_R{rep}.benchmark.txt"
    singularity: 
        "https://github.com/sylvainschmitt/singularity-troll/releases/download/0.0.2/sylvainschmitt-singularity-troll.latest.sif"
    threads: 1
    params:
        type="{type}",
        period="{period}",
        climate="{climate}",
        rep="R{rep}",
        verbose=config["verbose"]
    script:
        "../scripts/troll_warm.R"
        