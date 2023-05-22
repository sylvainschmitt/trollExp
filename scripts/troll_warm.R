# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
filein <- snakemake@input[[1]]
folderout <- snakemake@output[[1]]
# figureout <- snakemake@output[[2]]
type <- as.character(snakemake@params$type)
period <- as.character(snakemake@params$period)
climate <- as.character(snakemake@params$climate)
rep <- as.character(snakemake@params$rep)
verbose <- snakemake@params$verbose
test <- snakemake@params$test
test_years <- snakemake@params$test_years

# test
# filein <- "results/simulations/current/10-years/MPI-M-MPI-ESM-MR_ICTP-RegCM4-7/MPI-M-MPI-ESM-MR_ICTP-RegCM4-7_sampled.tsv"
# folderout <- "results/simulations/current/10-years/era/warmup/1"
# type <- "current"
# period <- "10-years"
# climate <- "guyaflux"
# verbose <- TRUE

# libraries
suppressMessages(library(tidyverse)) 
suppressMessages(library(rcontroll)) 
suppressMessages(library(vroom)) 

# code
path <- gsub(rep, "", folderout)
# dir.create(path,
#            recursive = TRUE)

data("TROLLv4_species")
data("TROLLv4_pedology")

data <- vroom(filein,
              col_types = list(rainfall = "numeric"))

clim <- generate_climate(data)
day <- generate_dailyvar(data)

n <- as.numeric(nrow(clim))
if(test)
  n <- round(test_years*365)

sim <- troll(
  name = rep,
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

# g <- rcontroll::autoplot(sim)
# 
# ggsave(plot = g, filename = figureout, bg = "white", width = 20, height = 10)
