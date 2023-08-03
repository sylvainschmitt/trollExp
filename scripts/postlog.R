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
# folderin <- "results/spinup/era"
# filein <- "results/cycle_1/log/RIL2_65.tsv"
# folderout <- "results/cycle_1/postlog/RIL2_65"
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
library(terra)

# code
logged_sim <- load_output(last(str_split_1(folderin, "/")), folderin)
load(filein)
Xref <- 286395+50
Yref <- 582936+50
prelog <- logged_sim@forest %>% 
  mutate(idTree = as.integer(as.factor(paste(col, row)))) %>%
  mutate(DBH = dbh*100) %>% 
  mutate(Especes = s_name) %>% 
  mutate(Xfield = col, Yfield = row) %>%
  select(idTree, Xfield, Yfield, DBH, Especes) %>% 
  mutate(Forest = "Paracou") %>%
  mutate(Plot = "6") %>%
  mutate(CensusYear = 2022) %>%
  mutate(PlotArea = 4) %>%
  mutate(CodeAlive = TRUE) %>%
  mutate(VernName = NA_character_) %>%
  mutate(Circ = DBH*pi, CircCorr = DBH*pi) %>%
  mutate(Xutm = Xref + Xfield, 
         Yutm = Yref + Yfield, 
         UTMZone = as.integer(22)) %>%
  separate(Especes, c("Genus","Species"), '_') %>% 
  mutate(Lat = Xutm, Lon = Yutm) %>% 
  mutate(Family  = NA_character_)
prelog_xy <- prelog %>% st_as_sf(coords = c("Xutm", "Yutm"),
                                 crs = '+proj=utm +zone=22 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0')
cut <- filter(logged$inventory, !is.na(TreePolygon))$TreePolygon %>% 
  st_as_sfc(crs = '+proj=utm +zone=22 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0')
trails <- st_as_sf(logged$SmoothedTrails)
prelog_xy <- prelog_xy %>% 
  mutate(death = ifelse(idTree %in% st_intersection(prelog_xy, trails)$idTree,
                        "trail", NA)) %>% 
  mutate(death = ifelse(idTree %in% st_intersection(prelog_xy, cut)$idTree & DBH < 1,
                        "treefall", death)) %>% 
  mutate(death = ifelse(idTree %in% filter(logged$inventory, DeathCause == "treefall2nd")$idTree,
                        "treefall", death)) %>% 
  mutate(death = ifelse(idTree %in% filter(logged$inventory, DeathCause == "cutted")$idTree,
                        "cut", death))
logged_sim@forest <- logged_sim@forest %>% 
  mutate(idTree = as.integer(as.factor(paste(col, row)))) %>%
  filter(!(idTree %in% filter(prelog_xy, !is.na(death))$idTree)) %>% 
  select(-idTree)

# sim
name <- paste0(scenario, "_", length)
path <- gsub(name, "", folderout)
n <- 365*10
if(test)
  n <- round(test_years*365)
sim <- troll(
  name = name,
  path = path,
  global = update_parameters(logged_sim, nbiter = n),
  species = logged_sim@inputs$species, 
  climate = logged_sim@inputs$climate,
  daily = logged_sim@inputs$daily,
  pedology = logged_sim@inputs$pedology, 
  forest = get_forest(logged_sim),
  soil = get_soil(logged_sim), 
  load = FALSE,
  verbose = verbose,
  overwrite = TRUE
)
