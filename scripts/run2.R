# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
filein <- snakemake@input[[1]]
folderin <- snakemake@input[[2]]
folderout <- snakemake@output[[1]]
site <- as.character(snakemake@params$site)
a0 <- as.numeric(snakemake@params$a0)
b0 <- as.numeric(snakemake@params$b0)
delta <- as.numeric(snakemake@params$delta)
verbose <- snakemake@params$verbose
test <- snakemake@params$test
test_years <- snakemake@params$test_years

# test
# filein <- "results/run/GF-Guy_2004-2014_climate.tsv"
# folderout <- "results/spinup//GF-Guy_2004-2014"
# folderout <- "results/run/GF-Guy_2004-2014"
# site <- "GF-Guy_2004-2014"
# verbose <- TRUE
# test <- TRUE
# test_years <- 0.1

# libraries
library(tidyverse)
library(rcontroll)
library(vroom)

# code
name <- paste0(site, "_", a0, "_", b0, "_", delta)
path <- gsub(name, "", folderout)

data("TROLLv4_species")
data("TROLLv4_pedology")

data <- vroom(filein,
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

n <- as.numeric(nrow(clim))
if(test)
  n <- round(test_years*365)

spinup <-  load_output(name = name,
                       path = folderin)

sim <- troll(
  name = name,
  path = path,
  global = update_parameters(spinup, nbiter = n,
                             pheno_a0 = a0, 
                             pheno_b0 = b0, 
                             pheno_delta = delta),
  species = spinup@inputs$species, 
  climate = clim,
  daily = day,
  pedology = spinup@inputs$pedology, 
  forest = get_forest(spinup),
  soil = get_soil(spinup), 
  load = FALSE,
  verbose = verbose,
  overwrite = TRUE
)
