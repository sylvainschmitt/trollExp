# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
folderin <- snakemake@input[[1]]
rdataout <- snakemake@output[[1]]
scenario <- as.character(snakemake@params$scenario)
length <- as.numeric(snakemake@params$length)
number <- as.numeric(snakemake@params$number)

# test
# folderin <- "results/spinup/era"
# scenario <- "RIL2"
# duration <- 65
# cycle <- 1

# libraries
library(dplyr)
library(tidyr)
library(LoggingLab)
library(sf)
library(terra)

# prep
forest <- file.path(folderin, paste0(last(strsplit(folderin, "/")[[1]]), 
                                     "_0_final_pattern.txt")) %>% 
  read.delim(sep = "\t") %>% 
  as_tibble() %>% 
  filter(iter != -1)

Xref <- 286395+50
Yref <- 582936+50
prelog <- forest %>% 
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
dem <- DTMParacou
distv <- CreekDistances$distvert
disth <- CreekDistances$disthorz
values(dem) <- rep(20, length(values(dem)))
values(distv) <- rep(20, length(values(distv)))
values(disth) <- rep(200, length(values(disth)))
mask0 <- prelog_xy %>%
  st_buffer(5) %>%
  st_bbox() %>%
  st_as_sfc() %>%
  as_Spatial() %>%
  as("SpatialPolygonsDataFrame")
mask <- PlotMask
mask@polygons <- mask0@polygons
dem <- terra::crop(dem, prelog_xy %>% st_buffer(5))
distv <- terra::crop(distv, prelog_xy %>% st_buffer(5))
disth <- terra::crop(disth, prelog_xy %>% st_buffer(5))

# logging
logged <- loggingsimulation1(filter(prelog, DBH >= 1),
                             plotmask = mask, 
                             topography = dem,
                             creekverticaldistance = distv,
                             creekhorizontaldistance = disth,
                             speciescriteria = SpeciesCriteria,
                             volumeparameters = ForestZoneVolumeParametersTable,
                             scenario = scenario, objectivelax = TRUE,
                             crowndiameterparameters = ParamCrownDiameterAllometry,
                             advancedloggingparameters = loggingparameters(MinDBHValue = 1))
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
logged_forest <- forest %>% 
  mutate(idTree = as.integer(as.factor(paste(col, row)))) %>%
  filter(!(idTree %in% filter(prelog_xy, !is.na(death))$idTree)) %>% 
  select(-idTree)
save(logged, file = rdataout)
