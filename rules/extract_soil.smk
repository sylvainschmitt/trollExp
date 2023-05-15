rule extract_soil:
    input:
        expand("results/soil/rasters/{par}_{depth}.tif", 
                par=config["soil_pars"], allow_missing=True)
    output:
        "results/soil/tables/soil_{depth}.tsv",
        "results/soil/figures/soil_{depth}.png"
    log:
        "results/logs/extract_soil_{depth}.log"
    benchmark:
        "results/benchmarks/extract_soil_{depth}.benchmark.txt"
    # singularity: 
    #     config["troll"]
    threads: 1
    params:
        plots=config["plots"]
    script:
        "../scripts/extract_soil.R"
