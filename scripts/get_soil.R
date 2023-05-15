# refs
# code from https://git.wur.nl/isric/soilgrids/soilgrids.notebooks/-/blob/master/markdown/webdav_from_R.md
# data description at https://maps.isric.org

# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
fileout <- snakemake@output[[1]]
figureout <- snakemake@output[[2]]
par <- as.character(snakemake@params$par)
depth <- as.character(snakemake@params$depth)
area <- as.character(snakemake@params$area)

# test
# fileout <- "results/data/soil/rasters/phh2o_0-5cm.tif"
# par <- "phh2o"
# depth <- "0-5cm"
# area <- "French Guiana"
  
# libs
library(tidyverse)
library(terra)
library(gdalUtilities)
library(osmdata)
library(leaflet)
library(sf)

# url
base_url="/vsicurl?max_retry=3&retry_delay=1&list_dir=no&url=https://files.isric.org/soilgrids/latest/data/"
url <- paste0(base_url, par, '/', par, '_', depth, '_mean.vrt')

# loc
fg <- getbb(area, format_out = "sf_polygon", limit = 1)$multipolygon
fg_bb <- unname(st_bbox(fg))[c(1,4,3,2)]
fg_proj <- st_crs(fg, parameters = T)$proj4string

gdal_translate(url,
               fileout,
               tr = c(250, 250),
               projwin = fg_bb,
               projwin_srs = fg_proj)

rst <- rast(fileout)

# plot
title <- switch (par,
                 "silt" = "proportion of silt",
                 "clay" = "proportion of clay",
                 "sand" = "proportion of sand",
                 "soc" = "soil organic content",
                 "bdod" = "dry bulk density",
                 "phh2o" = "hydrogen ion activity in water",
                 "cec" = "cation exchange capacity at ph 7"
)

g <- ggplot(fg) +
  tidyterra::geom_spatraster(data = rst, na.rm = TRUE) +
  geom_sf(fill = NA, col = "red", linewidth = 1) +
  theme_bw() +
  viridis::scale_fill_viridis(na.value = "white") +
  ggtitle(title, depth)

ggsave(g, filename = figureout)
