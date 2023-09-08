rule rename:
    input:
        "data/FLX_BR-Sa1_FLUXNET2015_SUBSET_2002-2011_1-4/FLX_BR-Sa1_FLUXNET2015_SUBSET_HR_2002-2011_1-4.csv",
        "data/FLX_BR-Sa3_FLUXNET2015_SUBSET_2000-2004_1-4/FLX_BR-Sa3_FLUXNET2015_SUBSET_HH_2000-2004_1-4.csv",
        "data/FLX_GF-Guy_FLUXNET2015_SUBSET_2004-2014_2-4/FLX_GF-Guy_FLUXNET2015_SUBSET_HH_2004-2014_2-4.csv"
    output:
        temp("results/data/BR-Sa1_raw.csv"),
        temp("results/data/BR-Sa3_raw.csv"),
        temp("results/data/GF-Guy_raw.csv")
    log:
        "results/logs/rename.log"
    benchmark:
        "results/benchmarks/rename.benchmark.txt"
    threads: 1
    shell:
        "cp {input[0]} {output[0]} ; "
        "cp {input[1]} {output[1]} ; "
        "cp {input[2]} {output[2]} ; "
