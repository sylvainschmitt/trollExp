# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
fileout <- snakemake@output[["tab"]]
figureout <- snakemake@output[["fig"]]
post_ref <- as.numeric(snakemake@params$post_ref)
post <-  as.numeric(snakemake@params$post)
seed <- snakemake@params$seed

# test
# post_ref <- 10
# post <- 100
# seed <- 42

# libraries
library(tidyverse)
library(vroom)
library(patchwork)

# code
set.seed(seed)

years <- 1970:2100
years <- tail(years, post_ref)

if(post > length(years))
  sampled_years <- sample(years, post, replace = TRUE)
if(post <= length(years))
  sampled_years <- sample(years, post, replace = FALSE)
sampled_years <- data.frame(projection_year = sampled_years) %>% 
  mutate(sim_year = (max(years)+1):(max(years)+post))
write_tsv(sampled_years, fileout)

g1 <- sampled_years %>% 
  ggplot(aes(sim_year, projection_year)) +
  geom_density_2d_filled(show.legend = FALSE) +
  geom_point() +
  theme_bw()
g2 <- ggplot(sampled_years, aes(projection_year)) +
  geom_histogram(col = NA) +
  theme_bw() +
  coord_flip()
g <- g1 + g2
ggsave(plot = g, filename = figureout, bg = "white")
