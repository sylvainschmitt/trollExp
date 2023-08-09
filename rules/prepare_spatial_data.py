rule prepare_spatial_data:
    input:
        climate="data/climate/ERA5land.nc",
        clay="data/soil/clay.tif",
        sand="data/soil/sand.tif",
        silt="data/soil/silt.tif"
    output:
        climate="results/data/climate.tsv",
        soil="results/data/soil.tsv"
    log:
        "results/logs/prepare_spatial_data.log"
    benchmark:
        "results/benchmarks/prepare_spatial_data.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        res=config["spatial_res_km"]
    script:
        "../scripts/prepare_spatial_data.R"
