# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
fileout <- snakemake@output[["tab"]]
figureout <- snakemake@output[["fig"]]
historical <- as.numeric(snakemake@params$historical)
spinup <-  as.numeric(snakemake@params$spinup)
seed <- snakemake@params$seed

# test
# spinup <- 600
# seed <- 42
# historical <- c(1970, 2005)

# libraries
library(tidyverse)
library(vroom)
library(patchwork)

# code
set.seed(seed)

years <- historical[1]:historical[2]
ymax <- (historical[1]-1)

if(spinup > length(years))
  sampled_years <- sample(years, spinup, replace = TRUE)
if(spinup <= length(years))
  sampled_years <- sample(years, spinup, replace = FALSE)
sampled_years <- data.frame(climate_year = sampled_years) %>% 
  mutate(sim_year = (ymax-spinup+1):ymax)
write_tsv(sampled_years, fileout)

g1 <- sampled_years %>% 
  ggplot(aes(sim_year, climate_year)) +
  geom_density_2d_filled(show.legend = FALSE) +
  geom_point() +
  theme_bw()
g2 <- ggplot(sampled_years, aes(climate_year)) +
  geom_histogram(col = NA) +
  theme_bw() +
  coord_flip()
g <- g1 + g2
ggsave(plot = g, filename = figureout, bg = "white")
