# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
filein <- snakemake@input[[1]]
folderout <- snakemake@output[[1]]
site <- as.character(snakemake@params$site)
verbose <- snakemake@params$verbose
mature_years <- snakemake@params$mature_years
test <- snakemake@params$test
test_years <- snakemake@params$test_years

# test
# filein <- "results/soil/soil.tsv"
# folderout <- "results/simulations/Acarouany"
# site <- "Acarouany"
# verbose <- TRUE
# mature_years <- 600
# test <- TRUE
# test_years <- 0.1

# libraries
library(tidyverse) 
library(rcontroll)
library(vroom)

# code
path <- gsub(site, "", folderout)

data("TROLLv4_species")
data("TROLLv4_climate")
data("TROLLv4_dailyvar")
data("TROLLv4_pedology")

pedo <- TROLLv4_pedology %>% 
  select(layer_thickness, proportion_Silt,
         proportion_Clay, proportion_Sand)

if(site != "default"){
  data <- vroom(filein) %>% 
    filter(Forest == site)
  pedo <- pedo %>% 
    mutate(proportion_Silt = data$silt,
           proportion_Clay = data$clay, 
           proportion_Sand = data$sand)
}

n <- as.numeric(mature_years)*365
if(test)
  n <- round(test_years*365)

sim <- troll(
  name = site,
  path = path,
  global = generate_parameters(nbiter = n, WATER_RETENTION_CURVE = 0),
  species = TROLLv4_species,
  climate = TROLLv4_climate,
  daily = TROLLv4_dailyvar,
  pedology = pedo,
  load = FALSE,
  verbose = verbose,
  overwrite = TRUE
)
