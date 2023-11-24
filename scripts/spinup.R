# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
climate <- snakemake@input[[1]]
species <- snakemake@input[[2]]
soil <- snakemake@input[[3]]
folderout <- snakemake@output[[1]]
site <- as.character(snakemake@params$site)
verbose <- snakemake@params$verbose
test <- snakemake@params$test
test_years <- snakemake@params$test_years

# test
# filein <- "results/simulations/GF-Guy_2004-2014_climate.tsv"
# folderout <- "results/simulations/GF-Guy_2004-2014"
# site <- "GF-Guy_2004-2014"
# verbose <- TRUE
# test <- TRUE
# test_years <- 0.1

# libraries
library(tidyverse)
library(rcontroll)
library(vroom)

# code
name <- site
path <- gsub(name, "", folderout)

data <- vroom(climate,
              col_types = list(rainfall = "numeric")) %>% 
  mutate(snet = ifelse(snet <= 1.1, 1.1, snet)) %>% 
  mutate(vpd = ifelse(vpd <= 0.011, 0.011, vpd)) %>% 
  mutate(ws = ifelse(ws <= 0.11, 0.11, ws))

# currently hardcoded should be put in config.yml
dstart = if_else(site == "Tapajos", 6, 7)
dend = if_else(site == "Tapajos", 18, 19)

clim <- generate_climate(data, 
                         daytime_start = dstart, 
                         daytime_end = dend)
day <- generate_dailyvar(data, 
                         daytime_start = dstart, 
                         daytime_end = dend)

species <- vroom(species)
soil <- vroom(soil)

n <- as.numeric(nrow(clim))
if(test)
  n <- round(test_years*365)

sim <- troll(
  name = name,
  path = path,
  global = generate_parameters(nbiter = n),
  species = species,
  climate = clim,
  daily = day,
  pedology = soil,
  load = FALSE,
  verbose = verbose,
  overwrite = TRUE
)
