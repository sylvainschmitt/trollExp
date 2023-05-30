rule gather_repetition_projections:
    input:
        warm_path="results/simulations/projections/{period}/{climate}/warmup/R{rep}",
        exp_path=expand("results/simulations/projections/{period}/{climate}/{exp}/R{rep}", exp=config["proj_scenario"], allow_missing=True)
    output:
        trajectory_file="results/tables/repetitions/projections_{period}/{climate}_R{rep}_trajectory.tsv",
        species_file="results/tables/repetitions/projections_{period}/{climate}_R{rep}_species.tsv",
        forest_file="results/tables/repetitions/projections_{period}/{climate}_R{rep}_forest.tsv"
        # trajectory_plot="results/figures/repetitions/projections_{period}/{climate}_R{rep}_trajectory.png",
        # species_plot="results/figures/repetitions/projections_{period}/{climate}_R{rep}_species.png",
        # forest_plot="results/figures/repetitions/projections_{period}/{climate}_R{rep}_forest.png"
    log:
        "results/logs/gather_repetition_projections_{period}_{climate}_R{rep}.log"
    benchmark:
        "results/benchmarks/gather_repetition_projections_{period}_{climate}_R{rep}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        type="projections",
        period="{period}",
        climate="{climate}",
        rep="R{rep}"
    script:
        "../scripts/gather_repetition.R"
        
