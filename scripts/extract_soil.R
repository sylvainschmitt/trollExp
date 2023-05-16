# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
filesin <- snakemake@input
fileout <- snakemake@output[[1]]
figure_plot <- snakemake@output[[2]]
figure_cor <- snakemake@output[[3]]
figure_tern <- snakemake@output[[4]]
plots <- as.character(snakemake@params$plots)


# test
# filesin <- c(
#   "results/soil/rasters/silt_0-5cm.tif",
#   "results/soil/rasters/silt_5-15cm.tif",
#   "results/soil/rasters/clay_0-5cm.tif",
#   "results/soil/rasters/clay_5-15cm.tif",
#   "results/soil/rasters/sand_0-5cm.tif",
#   "results/soil/rasters/sand_5-15cm.tif"
# )
# plots <- c(
#   "5.267241344232334, -52.92436802555797",
#   "Réserve naturelle des nouragues, 97301, Régina"
# )

# libs
library(tidyverse)
library(terra)
library(sf)
library(nominatimlite)
library(corrplot)
library(ggtern)

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
res <- terra::extract(layers, plots, bind = TRUE) %>% 
  as.data.frame() %>% 
  select(-query) %>% 
  separate(address, "address", ",") %>% 
  gather(variable, value, -address) %>% 
  separate(variable, c("variable", "depth"), "_")

# save
write_tsv(res, fileout)

# plot
g_plots <- res %>%
  mutate(address = gsub(" ", "\n", address)) %>% 
  ggplot(aes(address, value, fill = depth)) +
  geom_col(position = "dodge") +
  theme_bw() +
  facet_wrap(~ variable, scales = "free") +
  theme(legend.position = "bottom", axis.title = element_blank()) +
  scale_fill_viridis_d() +
  coord_flip()

ggsave(g_plots, filename = figure_plot)

png(figure_cor)
layers %>% 
  as.data.frame() %>% 
  select(contains("0-5cm")) %>% 
  cor(use = "pairwise.complete.obs") %>% 
  corrplot.mixed(tl.pos	= "lt")
dev.off()

g_tern <- res %>% 
  filter(variable %in% c("sand", "clay", "silt")) %>% 
  pivot_wider(names_from = variable, values_from = value) %>% 
  ggplot(aes(x = sand, y = clay, z = silt, 
             shape = address, col = depth)) +
  ggtern::coord_tern(L = "x", T = "y", R = "z") +
  geom_point(size = 3) +
  theme_bw() +
  scale_color_viridis_d() +
  labs(
    yarrow = "Clay (%)",
    zarrow = "Silt (%)",
    xarrow = "Sand (%)"
  ) +
  ggtern::theme_showarrows() +
  ggtern::theme_hidetitles()+
  ggtern::theme_clockwise()
ggsave(g_tern, filename = figure_tern)
