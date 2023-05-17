rule gather_period_current:
    input:
        trajectory_in=expand("results/tables/repetitions/current_{period}/{climate}_R{rep}_trajectory.tsv",
                             climate=config["current_climate"], rep=config["current_repetitions"], allow_missing=True),
        species_in=expand("results/tables/repetitions/current_{period}/{climate}_R{rep}_species.tsv",
                          climate=config["current_climate"], rep=config["current_repetitions"], allow_missing=True),
        forest_in=expand("results/tables/repetitions/current_{period}/{climate}_R{rep}_forest.tsv",
                         climate=config["current_climate"], rep=config["current_repetitions"], allow_missing=True)
    output:
        trajectory_file="results/tables/period/current_{period}_trajectory.tsv",
        species_file="results/tables/period/current_{period}_species.tsv",
        forest_file="results/tables/period/current_{period}_forest.tsv",
        trajectory_plot="results/figures/period/current_{period}_trajectory.png",
        species_plot="results/figures/period/current_{period}_species.png",
        forest_plot="results/figures/period/current_{period}_forest.png"
    log:
        "results/logs/gather_period_current_{period}.log"
    benchmark:
        "results/benchmarks/gather_period_current_{period}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        type="current",
        period="{period}"
    script:
        "../scripts/gather_period.R"
        
