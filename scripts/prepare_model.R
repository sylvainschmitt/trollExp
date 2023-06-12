# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
filein <- snakemake@input[[1]]
fileout <- snakemake@output[[1]]
model <- as.character(snakemake@params$model)
rcm <- as.character(snakemake@params$rcm)

# test
# filein <- "results/data/climate/cordex.tsv"
# model <- "MPI-M-MPI-ESM"
# rcm <- "ICTP-RegCM4-7"

# libraries
library(tidyverse)
library(vroom)

# code
m <- model
r <- rcm
climate <- vroom(filein) %>% 
  filter(model == m) %>% 
  filter(rcm == r) %>% 
  select(-path, -file, -model, -rcm)

write_tsv(x = climate, file = fileout)
