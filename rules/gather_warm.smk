rule gather_warm:
    input:
        expand("results/simulations/{plot}_{depth}/R{rep}",
                plot=config["exp_plots"],
                depth=config["exp_depth"],
                rep=config["repetitions"])
    output:
        trajectory_file="results/simulations/trajectory.tsv",
        species_file="results/simulations/species.tsv",
        forest_file="results/simulations/forest.tsv"
        # trajectory_plot="results/simulations/trajectory.png",
        # species_plot="results/simulations/species.png",
        # forest_plot="results/simulations/forest.png"
    log:
        "results/logs/gather_warm.log"
    benchmark:
        "results/benchmarks/gather_warm.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    script:
        "../scripts/gather_warm.R"
