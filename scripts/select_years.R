# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
guyaflux <- snakemake@input[[1]]
fileout <- snakemake@output[[1]]
figureout <- snakemake@output[[2]]
type <- as.character(snakemake@params$type)
period <- as.character(snakemake@params$period)
mature_years <- as.numeric(snakemake@params$mature_years)
verbose <- snakemake@params$verbose
data_path <- snakemake@params$data_path
seed <- snakemake@params$seed

# test
# fileout <- "results/simulations/projection/full/selected_years.tsv"
# type <- "projection"
# period <- "full"
# verbose <- TRUE
# mature_years <- 1
# data_path <- "data"
# seed <- 42

# libraries
suppressMessages(library(tidyverse)) 
library(vroom)

# folder
path <- gsub("selected_years.tsv", "", fileout)
# if(!dir.exists(path))
#   dir.create(path, recursive = TRUE)

# period
absent <- TRUE

if(period == "10-years") {
  absent <- FALSE
  data <- vroom(guyaflux)
  years <- unique(year(data$time))
}

if(period == "full") {
  absent <- FALSE
  years <- 1970:2005 # hardcoded assuming this is the case for all cordex
}

if(absent)
  stop(paste0("The period ", period, " was not programmed."))

if(mature_years > length(years))
  sampled_years <- sample(years, mature_years, replace = TRUE)
if(mature_years <= length(years))
  sampled_years <- sample(years, mature_years, replace = FALSE)

years <- data.frame(year = sampled_years)
write_tsv(years, fileout)
g <- ggplot(years, aes(year)) +
  geom_histogram() +
  theme_bw()
ggsave(plot = g, filename = figureout, bg = "white")
