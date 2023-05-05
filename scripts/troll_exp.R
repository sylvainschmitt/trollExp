# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
folderout <- snakemake@output[[1]]
type <- as.character(snakemake@params$type)
climate <- as.character(snakemake@params$climate)
simulation <- as.character(snakemake@params$simulation)
mature_years <- as.numeric(snakemake@params$mature_years)
verbose <- snakemake@params$verbose
cores <- as.numeric(snakemake@threads)

# test
# folderout <- "results/simulations/mature/guyaflux"
# type <- "mature"
# climate <- "guyaflux"
# simulation <- "2004:2005"
# mature_years <- 1
# cores <- 1
# verbose <- TRUE

# libraries
suppressMessages(library(tidyverse)) 
suppressMessages(library(rcontroll)) 

# code

stop("Dev needed.")

dir.create(folderout, recursive = TRUE)
data("TROLLv4_species")
data("TROLLv4_climate")
data("TROLLv4_dailyvar")
data("TROLLv4_pedology")
sim <- troll(
  name = simulation,
  path = gsub(simulation, "", folderout),
  global = generate_parameters(nbiter = round(mature_years*365)),
  species = TROLLv4_species,
  climate = TROLLv4_climate, # to replace with the simulation
  daily = TROLLv4_dailyvar,
  pedology = TROLLv4_pedology,
  load = FALSE,
  verbose = verbose,
  overwrite = TRUE
)

# load_output("2004:2005", "results/simulations/mature/guyaflux/2004:2005/") %>%
#   rcontroll::autoplot()
# Like a charm !!
