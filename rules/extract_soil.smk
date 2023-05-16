rule extract_soil:
    input:
        expand("results/soil/rasters/{par}_{depth}.tif", 
                par=config["soil_pars"], depth=config["depth"])
    output:
        "results/soil/soil_{area}.tsv",
        "results/soil/soil_{area}_all.png",
        "results/soil/soil_{area}_cor.png",
        "results/soil/soil_{area}_tern.png"
    log:
        "results/logs/extract_soil_{area}.log"
    benchmark:
        "results/benchmarks/extract_soil_{area}.benchmark.txt"
    # singularity: 
    #     config["troll"]
    threads: 1
    params:
        plots=config["plots"]
    script:
        "../scripts/extract_soil.R"
