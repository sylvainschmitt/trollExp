# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
filein <- snakemake@input[[1]]
folderout <- snakemake@output[[1]]
type <- as.character(snakemake@params$type)
period <- as.character(snakemake@params$period)
climate <- as.character(snakemake@params$climate)
rep <- as.character(snakemake@params$rep)
verbose <- snakemake@params$verbose

# test
filein <- "results/simulations/current/10-years/MPI-M-MPI-ESM-MR_ICTP-RegCM4-7/MPI-M-MPI-ESM-MR_ICTP-RegCM4-7_sampled.tsv"
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
dir.create(path,
           recursive = TRUE)

data("TROLLv4_species")
data("TROLLv4_pedology")

data <- vroom(filein,
              col_types = list(rainfall = "numeric"))

# stop("We seem to have an issue with climate data.")
clim <- generate_climate(data)
# summary(clim)

day <- generate_dailyvar(data) %>% 
  mutate(Snet = ifelse(Snet < 0, 0, Snet)) # weird
# summary(day)

n <- as.numeric(nrow(clim))

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

# load_output("2004:2005", "results/simulations/mature/guyaflux/2004:2005/") %>%
#   rcontroll::autoplot()
# Like a charm !!
