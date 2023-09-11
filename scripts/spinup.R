# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
filein <- snakemake@input[["species"]]
folderout <- snakemake@output[[1]]
sr <- as.numeric(snakemake@params$richness)
rep <- as.numeric(snakemake@params$rep)
verbose <- snakemake@params$verbose
spinup <- snakemake@params$spinup
test <- snakemake@params$test
test_years <- snakemake@params$test_years

# test
# filein <- "results/spinup/coms.tsv"
# folderout <- "results/simulations/SR500_REP1"
# sr <- 500
# rep <- 1
# verbose <- TRUE
# spinup <- 600
# test <- TRUE
# test_years <- 0.1

# libraries
library(tidyverse) 
library(rcontroll)
library(vroom)

# code
name <- paste0("SR", sr, "_REP", rep)
path <- gsub(name, "", folderout)

data("TROLLv4_climate")
data("TROLLv4_dailyvar")
data("TROLLv4_pedology")

species <- vroom(filein) %>% 
  filter(richness == sr, repetition == rep) %>% 
  select(-richness, -repetition) %>% 
  mutate(s_regionalfreq = 1/n())

n <- as.numeric(spinup)*365
if(test)
  n <- round(test_years*365)

sim <- troll(
  name = name,
  path = path,
  global = generate_parameters(nbiter = n),
  species = species,
  climate = TROLLv4_climate,
  daily = TROLLv4_dailyvar,
  pedology = TROLLv4_pedology,
  load = FALSE,
  verbose = verbose,
  overwrite = TRUE
)
