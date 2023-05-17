rule gather_repetition_current:
    input:
        warm_path="results/simulations/current/{period}/{climate}/warmup/R{rep}",
        exp_path="results/simulations/current/{period}/{climate}/historical/R{rep}"
    output:
        trajectory_file="results/tables/repetitions/current_{period}/{climate}_R{rep}_trajectory.tsv",
        species_file="results/tables/repetitions/current_{period}/{climate}_R{rep}_species.tsv",
        forest_file="results/tables/repetitions/current_{period}/{climate}_R{rep}_forest.tsv",
        trajectory_plot="results/figures/repetitions/current_{period}/{climate}_R{rep}_trajectory.png",
        species_plot="results/figures/repetitions/current_{period}/{climate}_R{rep}_species.png",
        forest_plot="results/figures/repetitions/current_{period}/{climate}_R{rep}_forest.png"
    log:
        "results/logs/gather_repetition_current_{period}_{climate}_R{rep}.log"
    benchmark:
        "results/benchmarks/gather_repetition_current_{period}_{climate}_R{rep}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        type="current",
        period="{period}",
        climate="{climate}",
        rep="R{rep}"
    script:
        "../scripts/gather_repetition.R"
        
