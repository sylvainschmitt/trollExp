# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
filein <- snakemake@input[[1]]
fileout <- snakemake@output[[1]]
figureout <- snakemake@output[[2]]
warmup <- as.numeric(snakemake@params$warmup)
seed <- snakemake@params$seed

# test
# filein <- "results/data/climate/cordex.tsv"
# mature_years <- 600
# seed <- 42

# libraries
library(tidyverse)
library(vroom)
library(patchwork)

# code
set.seed(seed)
climate <- vroom(filein) %>% 
  filter(experiment == "historical")
years <- 1970:2005
if(warmup > length(years))
  sampled_years <- sample(years, warmup, replace = TRUE)
if(warmup <= length(years))
  sampled_years <- sample(years, warmup, replace = FALSE)
sampled_years <- data.frame(year = sampled_years)
write_tsv(sampled_years, fileout)
g <- ggplot(sampled_years, aes(year)) +
  geom_histogram() +
  theme_bw()
g1 <- sampled_years %>% 
  mutate(sim_year = 1:n()) %>% 
  ggplot(aes(sim_year, year)) +
  geom_density_2d_filled(show.legend = FALSE) +
  geom_point() +
  theme_bw() +
  xlab("warmup year") +
  ylab("real year")
g2 <- ggplot(sampled_years, aes(year)) +
  geom_histogram(col = NA) +
  theme_bw() +
  coord_flip() +
  xlab("real year")
g <- g1 + g2
ggsave(plot = g, filename = figureout, bg = "white")
