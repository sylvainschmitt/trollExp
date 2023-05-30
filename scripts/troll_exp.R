# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
filein <- snakemake@input[[1]]
folderin <- snakemake@input[[2]]
folderout <- snakemake@output[[1]]
# figureout <- snakemake@output[[2]]
type <- as.character(snakemake@params$type)
period <- as.character(snakemake@params$period)
climate <- as.character(snakemake@params$climate)
exp <- as.character(snakemake@params$exp)
rep <- as.character(snakemake@params$rep)
verbose <- snakemake@params$verbose
test <- snakemake@params$test
test_years <- snakemake@params$test_years

# test
# filein <- "results/data/climate/MPI-M-MPI-ESM_ICTP-RegCM4-7.tsv"
# folderin <- "results/simulations/projections/full/MPI-M-MPI-ESM_ICTP-RegCM4-7/warmup/R1"
# type <- "projection"
# period <- "full"
# climate <- "MPI-M-MPI-ESM_ICTP-RegCM4-7"
# exp <- "rcp85"
# rep <- "R1"
# verbose <- TRUE
# test <- TRUE
# test_years <- 0.1

# libraries
suppressMessages(library(tidyverse)) 
suppressMessages(library(rcontroll)) 
suppressMessages(library(vroom)) 

# code
path <- gsub(rep, "", folderout)
# dir.create(path,
#            recursive = TRUE)

# climate
data <- vroom::vroom(filein)
e <- exp
if("exp" %in% names(data)) # for cordex
  data <- filter(data, exp == e) %>% 
  mutate(month = month(time), day = day(time)) %>% 
  mutate(monthday = paste0(month, "-", day)) %>% 
  filter(monthday != "2-29") %>% 
  select(-exp, -month, -day, -monthday)

clim <- generate_climate(data)
day <- generate_dailyvar(data)

# other data
n <- as.numeric(nrow(clim))*2
if(test)
  n <- round(test_years*365)
global_pars <- vroom(file.path(folderin, paste0(rep, "_input_global.txt"))) %>% 
  mutate(value = ifelse(param == "nbiter", n, value))
species_pars <- vroom(file.path(folderin, paste0(rep, "_input_species.txt")))
pedo_pars <- vroom(file.path(folderin, paste0(rep, "_input_pedology.txt")))
forest_pars <- vroom(file.path(folderin, paste0(rep, "_0_final_pattern.txt"))) %>% 
  as.data.frame()
soil_pars <- vroom(file.path(folderin, paste0(rep, "_0_final_SWC3D.txt")), 
                   col_names = F) %>% 
  as.data.frame()

sim <- troll(
  name = rep,
  path = path,
  global = global_pars,
  species = species_pars,
  climate = clim,
  daily = day,
  pedology = pedo_pars,
  forest = forest_pars,
  soil = soil_pars,
  load = FALSE,
  verbose = verbose,
  overwrite = TRUE
)

# g <- rcontroll::autoplot(sim)
# 
# ggsave(plot = g, filename = figureout, bg = "white", width = 20, height = 10)
