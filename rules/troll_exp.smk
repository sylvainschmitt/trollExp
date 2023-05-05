rule troll_exp:
    input:
        "results/simulations/{type}/{period}/{climate}/warmup/{rep}"
    output:
        directory("results/simulations/{type}/{period}/{climate}/{exp}/{rep}")
    log:
        "results/logs/troll_exp_{type}_{period}_{climate}_{exp}_{rep}.log"
    benchmark:
        "results/benchmarks/troll_exp_{type}_{period}_{climate}_{exp}_{rep}.benchmark.txt"
    singularity: 
        "https://github.com/sylvainschmitt/singularity-troll/releases/download/0.0.2/sylvainschmitt-singularity-troll.latest.sif"
    threads: 1
    params:
        type="{type}",
        period="{period}",
        climate="{climate}",
        exp="{exp}",
        rep="{rep}",
        verbose=config["verbose"]
    script:
        "../scripts/troll_exp.R"
        