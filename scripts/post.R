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
# filein <- "results/post/NCC-NorESM1-M_REMO2015_rcp85_climate.tsv"
# verbose <- TRUE
# test <- TRUE
# test_years <- 0.1

# libraries
library(tidyverse)
library(rcontroll)
library(vroom)

# code
name <- paste0("SR", sr, "_REP", rep, "_", model, "_", rcm, "_", exp)
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

run <-  load_output(name = name,
                       path = folderin)

sim <- troll(
  name = name,
  path = path,
  global = update_parameters(run, nbiter = n),
  species = run@inputs$species, 
  climate = clim,
  daily = day,
  pedology = run@inputs$pedology, 
  forest = get_forest(run),
  soil = get_soil(run), 
  load = FALSE,
  verbose = verbose,
  overwrite = TRUE
)
