# refs
# code from https://git.wur.nl/isric/soilgrids/soilgrids.notebooks/-/blob/master/markdown/webdav_from_R.md
# data description at https://maps.isric.org

# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
filesin <- snakemake@input
fileout <- snakemake@output[[1]]
figureout <- snakemake@output[[2]]
plots <- as.character(snakemake@params$plots)

# libs
library(tidyverse)
library(terra)
library(gdalUtilities)
library(osmdata)
library(leaflet)
library(sf)
library(nominatimlite)

# rasters
layers <- filesin %>% 
  lapply(rast) %>% 
  rast()

# plots
plots <- data.frame(plots = plots) %>% 
  mutate(plots = geo_lite_sf(plots)) %>% 
  unnest() %>% 
  st_as_sf() %>% 
  st_transform(crs = crs(layers))

# extract
res <- terra::extract(layers, plots, bind = TRUE)

# save
write_tsv(as.data.frame(res), fileout)

# plot
g <- as.data.frame(res) %>% 
  select(-query) %>% 
  gather(variable, value, -address) %>% 
  separate(address, "address", ",") %>% 
  ggplot(aes(address, value, fill = address)) +
  geom_col(position = "dodge") +
  theme_bw() +
  facet_wrap(~ variable, scales = "free") +
  theme(legend.position = "bottom", axis.title = element_blank(),
        axis.text.x = element_blank(), axis.ticks.x = element_blank())

ggsave(g, filename = figureout)
