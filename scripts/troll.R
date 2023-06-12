# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
filein <- snakemake@input[[1]]
folderout <- snakemake@output[[1]]
model <- as.character(snakemake@params$model)
rcm <- as.character(snakemake@params$rcm)
exp <- as.character(snakemake@params$exp)
verbose <- snakemake@params$verbose
test <- snakemake@params$test
test_years <- snakemake@params$test_years

# test
filein <- "results/simulations/NCC-NorESM1-M_REMO2015_rcp85_climate.tsv"
model <- "NCC-NorESM1-M"
rcm <- "REMO2015"
exp <- "rcp85"
verbose <- TRUE
test <- TRUE
test_years <- 0.1

# libraries
library(tidyverse)
library(rcontroll)
library(vroom)

# code
name <- paste0(model, "_", rcm, "_", exp)
path <- gsub(name, "", folderout)

data("TROLLv4_species")
data("TROLLv4_pedology")

data <- vroom(filein,
              col_types = list(rainfall = "numeric")) %>% 
  mutate(snet = ifelse(snet <= 1.1, 1.1, snet)) %>% 
  mutate(vpd = ifelse(vpd <= 0.011, 0.011, vpd)) %>% 
  mutate(ws = ifelse(ws <= 0.11, 0.11, ws))

clim <- generate_climate(data)
day <- generate_dailyvar(data)

n <- as.numeric(nrow(clim))
if(test)
  n <- round(test_years*365)

sim <- troll(
  name = name,
  path = path,
  global = generate_parameters(nbiter = n),
  species = TROLLv4_species,
  climate = clim,
  daily = day,
  pedology = TROLLv4_pedology,
  load = FALSE,
  verbose = verbose,
  overwrite = TRUE
)
