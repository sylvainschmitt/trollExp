# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
filein <- snakemake@input[[1]]
folderin <- snakemake@input[[2]]
folderout <- snakemake@output[[1]]
sr <- as.numeric(snakemake@params$richness)
rep <- as.numeric(snakemake@params$rep)
model <- as.character(snakemake@params$model)
rcm <- as.character(snakemake@params$rcm)
exp <- as.character(snakemake@params$exp)
verbose <- snakemake@params$verbose
test <- snakemake@params$test
test_years <- snakemake@params$test_years

# test
# filein <- "results/simulations/NCC-NorESM1-M_REMO2015_rcp85_climate.tsv"
# verbose <- TRUE
# test <- TRUE
# test_years <- 0.1

# libraries
library(tidyverse)
library(rcontroll)
library(vroom)

# code
sp_name <- paste0("SR", sr, "_REP", rep)
clim_name <- paste0(model, "_", rcm, "_", exp)
name <- paste0(sp_name, "_", clim_name)
path <- gsub(name, "", folderout)

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

spinup <-  load_output(name = paste0(sp_name, "_era"),
                       path = folderin)

sim <- troll(
  name = name,
  path = path,
  global = update_parameters(spinup, nbiter = n),
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
