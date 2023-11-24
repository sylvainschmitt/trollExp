# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
clim_raw <- snakemake@input[[1]]
species_raw <- snakemake@input[[2]]
soil_raw <- snakemake@input[[3]]
climate <- snakemake@output[[1]]
species <- snakemake@output[[2]]
soil <- snakemake@output[[3]]
sit <- as.character(snakemake@params$site)

# test
# clim_raw <- "data/climate_raw.tsv"
# sit <- "Tapajos"

# libraries
library(tidyverse)
library(vroom)

vroom(clim_raw) %>% 
  filter(site == sit) %>% 
  filter(variable %in% c("rainfall", "snet", "temperature", "vpd", "ws")) %>% 
  pivot_wider(names_from = variable, values_from = observed) %>% 
  select(time, rainfall, snet, temperature, vpd, ws) %>% 
  vroom_write(climate)

vroom(species_raw) %>% 
  vroom_write(species)

vroom(soil_raw) %>% 
  vroom_write(soil)

