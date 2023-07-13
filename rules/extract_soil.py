rule extract_soil:
    input:
        guyafor="data/guyafor.tsv",
        clay="data/clay.tif",
        sand="data/sand.tif",
        silt="data/silt.tif"
    output:
        "results/soil/soil.tsv",
        "results/soil/soil_tern.png"
    log:
        "results/logs/extract_soil.log"
    benchmark:
        "results/benchmarks/extract_soil.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    script:
        "../scripts/extract_soil.R"
