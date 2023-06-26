rule get_data:
    output:
        "results/data/{site}_FLUXNET2015_{type}.nc"
    log:
        "results/logs/get_fluxes_{site}_{type}.log"
    benchmark:
        "results/benchmarks/get_fluxes_{site}_{type}.benchmark.txt"
    singularity:
        config["troll"]
    threads: 1
    params:
        adress=config["adress"],
        site="{site}",
        type="{type}"
    shell:
        "wget {params.adress}/{params.type}/{params.site}_FLUXNET2015_{params.type}.nc -O {output} -o {log}"
        
