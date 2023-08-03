# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
folderin <- snakemake@input[[1]]
filein <- snakemake@input[[2]]
folderout <- snakemake@output[[1]]
scenario <- as.character(snakemake@params$scenario)
length <- as.numeric(snakemake@params$duration)
number <- as.numeric(snakemake@params$cycle)
verbose <- snakemake@params$verbose
test <- snakemake@params$test
test_years <- snakemake@params$test_years

# test
# filein <- "results/cycle_1/damage/RIL2_65.tsv"
# folderin <- "results/cycle_1/postlog/RIL2_65"
# folderout <- "results/cycle_1/recover/RIL2_65"
# scenario <- "RIL2"
# length <- 65
# number <- 1
# verbose <- TRUE
# test <- TRUE
# test_years <- 0.1

# libraries
library(tidyverse)
library(rcontroll)
library(vroom)
library(sf)

# gaps
postlog <-  load_output(last(str_split_1(folderin, "/")), folderin)
inv <- vroom(file = filein)
postlog_dead <- postlog
postlog_dead@forest <- postlog_dead@forest %>% 
  mutate(ind = paste0(col, "-", row)) %>% 
  filter(!(ind %in% filter(inv, death == 1)$ind)) %>% 
  select(-ind)

# recovery
name <- paste0(scenario, "_", length)
path <- gsub(name, "", folderout)
n <- 365*(length-10)
if(test)
  n <- round(test_years*365)
sim <- troll(
  name = name,
  path = path,
  global = update_parameters(postlog_dead, nbiter = n),
  species = postlog_dead@inputs$species, 
  climate = postlog_dead@inputs$climate,
  daily = postlog_dead@inputs$daily,
  pedology = postlog_dead@inputs$pedology, 
  forest = get_forest(postlog_dead),
  soil = get_soil(postlog_dead), 
  load = FALSE,
  verbose = verbose,
  overwrite = TRUE
)

