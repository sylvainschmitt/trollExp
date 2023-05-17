rule get_soil:
    output:
        "results/soil/rasters/{par}_{depth}.tif",
        "results/soil/images/{par}_{depth}.png"
    log:
        "results/logs/get_soil_{par}_{depth}.log"
    benchmark:
        "results/benchmarks/get_soil_{par}_{depth}.benchmark.txt"
    # singularity:
    #     config["troll"]
    threads: 1
    params:
        par="{par}",
        depth="{depth}",
        area=config["area"]
    script:
        "../scripts/get_soil.R"
