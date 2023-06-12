# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
era_path <- snakemake@input[["era"]]
fileout <- snakemake@output[["tab"]]
figureout <- snakemake@output[["fig"]]
historical <- as.numeric(snakemake@params$historical)
seed <- snakemake@params$seed

# test
# era_path <- "data/ERA5land_Paracou.tsv"
# seed <- 42
# historical <- c(1950, 2005)

# libraries
library(tidyverse)
library(vroom)
library(patchwork)

# code
set.seed(seed)

era <- vroom(era_path) %>% 
  mutate(experiment = "historical", 
         model = "ERA5-Land",
         rcm = "")

ymax <- max(year(era$time)) + 1

sampled_years <- data.frame(sim_year = ymax:2100,
                            era_year = sample(historical[1]:historical[2],
                                              2100-(ymax-1), 
                                              replace = TRUE))
write_tsv(sampled_years, fileout)

g1 <- sampled_years %>% 
  ggplot(aes(sim_year, era_year)) +
  geom_density_2d_filled(show.legend = FALSE) +
  geom_point() +
  theme_bw()
g2 <- ggplot(sampled_years, aes(era_year)) +
  geom_histogram(col = NA) +
  theme_bw() +
  coord_flip()
g <- g1 + g2
ggsave(plot = g, filename = figureout, bg = "white")
