# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
fileout <- snakemake@output[[1]]
figureout <- snakemake@output[[2]]
type <- as.character(snakemake@params$type)
period <- as.character(snakemake@params$period)
mature_years <- as.numeric(snakemake@params$mature_years)
verbose <- snakemake@params$verbose
data_path <- snakemake@params$data_path
seed <- snakemake@params$seed

# test
# fileout <- "results/simulations/current/10-years/selected_years.tsv"
# type <- "current"
# period <- "10-years"
# verbose <- TRUE
# data_path <- "/home/sschmitt/Documents/data/"
# seed <- 42

# libraries
suppressMessages(library(tidyverse)) 
suppressMessages(library(datatrollr)) 

# folder
path <- gsub("selected_years.tsv", "", fileout)
if(!dir.exists(path))
  dir.create(path, recursive = TRUE)

# period
absent <- TRUE

if(period == "10-years") {
  absent <- FALSE
  data <- get_guyaflux(path = data_path)
}

if(period == "full") {
  absent <- FALSE
  data <- get_cordex(path = data_path, scenario = "historical")
}

if(absent)
  stop(paste0("The period ", period, " was not programmed."))

years <- unique(year(data$time))
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
