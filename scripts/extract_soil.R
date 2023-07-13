# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
guyaforfile <- snakemake@input[["guyafor"]]
clayfile <- snakemake@input[["clay"]]
sandfile <- snakemake@input[["sand"]]
siltfile <- snakemake@input[["silt"]]
fileout <- snakemake@output[[1]]
figure_tern <- snakemake@output[[2]]

# test
guyaforfile <- "data/guyafor.tsv"
clayfile <- "data/clay.tif"
sandfile <- "data/sand.tif"
siltfile <- "data/silt.tif"

# libs
library(vroom)
library(tidyverse)
library(terra)
library(sf)
library(ggtern)

# rasters
soil <- list(clayfile,
               sandfile,
               siltfile) %>% 
  lapply(rast) %>% 
  rast()
names(soil) <- c("clay", "sand", "silt")

gf_xy <- vroom(guyaforfile) %>%
  select(Forest, Xutm, Yutm) %>% 
  group_by(Forest) %>% 
  summarise_all(mean, na.rm = TRUE) %>% 
  na.omit() %>% 
  st_as_sf(coords = c("Xutm", "Yutm"),
           crs = '+proj=utm +zone=22 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0')
gf_xy <- gf_xy %>%
  bind_cols(terra::extract(soil, gf_xy))

# save
write_tsv(as.data.frame(gf_xy), fileout)

# plot
g_tern <- gf_xy %>%
  group_by(Forest, geometry, ID) %>%
  summarise_all(median) %>%
  ggplot(aes(x = sand, y = clay, z = silt)) +
  ggtern::coord_tern(L = "x", T = "y", R = "z") +
  geom_text(aes(label = Forest), size = 3) +
  theme_bw() +
  labs(
    yarrow = "Clay (%)",
    zarrow = "Silt (%)",
    xarrow = "Sand (%)"
  ) +
  ggtern::theme_showarrows() +
  ggtern::theme_hidetitles() +
  ggtern::theme_clockwise()
ggsave(g_tern, filename = figure_tern)
