rule gather_period_projections:
    input:
        trajectory_in=expand("results/tables/repetitions/projections_{period}/{model}_{rcm}_R{rep}_trajectory.tsv",
                             model=config["proj_model"], rcm=config["proj_rcm"], rep=config["proj_repetitions"], allow_missing=True),
        species_in=expand("results/tables/repetitions/projections_{period}/{model}_{rcm}_R{rep}_species.tsv",
                          model=config["proj_model"], rcm=config["proj_rcm"], rep=config["proj_repetitions"], allow_missing=True),
        forest_in=expand("results/tables/repetitions/projections_{period}/{model}_{rcm}_R{rep}_forest.tsv",
                         model=config["proj_model"], rcm=config["proj_rcm"], rep=config["proj_repetitions"], allow_missing=True)
    output:
        trajectory_file="results/tables/period/projections_{period}_trajectory.tsv",
        species_file="results/tables/period/projections_{period}_species.tsv",
        forest_file="results/tables/period/projections_{period}_forest.tsv",
        trajectory_plot="results/figures/period/projections_{period}_trajectory.png",
        species_plot="results/figures/period/projections_{period}_species.png",
        forest_plot="results/figures/period/projections_{period}_forest.png"
    log:
        "results/logs/gather_period_projections_{period}.log"
    benchmark:
        "results/benchmarks/gather_period_projections_{period}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        type="projections",
        period="{period}"
    script:
        "../scripts/gather_period.R"
        
