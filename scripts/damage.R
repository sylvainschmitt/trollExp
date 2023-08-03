# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
rdatain <- snakemake@input[[1]]
folderin <- snakemake@input[[2]]
fileout <- snakemake@output[[1]]
scenario <- as.character(snakemake@params$scenario)
length <- as.numeric(snakemake@params$duration)
number <- as.numeric(snakemake@params$cycle)

# test
# rdatain <- "results/cycle_1/log/RIL2_65.Rdata"
# folderin <- "results/cycle_1/postlog/RIL2_65"
# fileout <- "results/cycle_1/damage/RIL2_65.tsv"
# scenario <- "RIL1"
# length <- 65
# number <- 1

# libraries
library(tidyverse)
library(rcontroll)
library(vroom)
library(sf)

# code
postlog <-  load_output(last(str_split_1(folderin, "/")), folderin)
load(rdatain)
cut <- filter(logged$inventory, !is.na(TreePolygon))$TreePolygon %>% 
  st_as_sfc(crs = '+proj=utm +zone=22 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0')
trails <- st_as_sf(logged$SmoothedTrails)
gaps <- cut %>% 
  st_buffer(0) %>% 
  st_union(trails) %>% 
  st_combine()
Xref <- 286395+50
Yref <- 582936+50
inv <- postlog@forest %>% 
  filter(dbh > 10/100) %>% 
  filter(iter != -1) %>% 
  mutate(ind = paste0(col, "-", row)) %>% 
  mutate(Xutm = Xref + col, 
         Yutm = Yref + row, 
         UTMZone = as.integer(22)) %>%
  st_as_sf(coords = c("Xutm", "Yutm"),
           crs = '+proj=utm +zone=22 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0')
inv$dist <- as.numeric(st_distance(inv, gaps))
inv <- inv %>% 
  mutate(odd_death = -4.441 + 0.762*exp(0.064*sqrt(dist))) %>% 
  mutate(proba_death =  exp(odd_death) / (1 + exp(odd_death))) %>% 
  mutate(death = as.numeric(proba_death > runif(n())))
write_tsv(inv, file = fileout)

