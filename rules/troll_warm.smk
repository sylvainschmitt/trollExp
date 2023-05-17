rule troll_warm:
    input:
        "results/soil/soil.tsv"
    output:
        directory("results/simulations/{plot}_{depth}/R{rep}"),
        "results/simulations/{plot}_{depth}/R{rep}.png"
    log:
        "results/logs/troll_warm_{plot}_{depth}_R{rep}.log"
    benchmark:
        "results/benchmarks/troll_warm_{plot}_{depth}_R{rep}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        plot="{plot}",
        depth="{depth}",
        rep="R{rep}",
        n_layers=config["n_layers"],
        layer_thickness=config["layer_thickness"],
        verbose=config["verbose"],
        mature_years=config["mature_years"],
        test=config["test"],
        test_years=config["test_years"]
    script:
        "../scripts/troll_warm.R"
