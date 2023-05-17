rule extract_soil:
    input:
        expand("results/soil/rasters/{par}_{depth}.tif", 
                par=config["soil_pars"], depth=config["soil_depth"])
    output:
        "results/soil/soil.tsv",
        "results/soil/soil_all.png",
        "results/soil/soil_cor.png",
        "results/soil/soil_tern.png"
    log:
        "results/logs/extract_soil.log"
    benchmark:
        "results/benchmarks/extract_soil.benchmark.txt"
    # singularity:
    #     config["troll"]
    threads: 1
    params:
        plots=config["plots"]
    script:
        "../scripts/extract_soil.R"
