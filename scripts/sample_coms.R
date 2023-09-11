# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
species_file <- snakemake@input[["species"]]
fileout <- snakemake@output[["tab"]]
figureout <- snakemake@output[["fig"]]
richness <- as.numeric(snakemake@params$richness)
repetitions <- as.numeric(snakemake@params$repetitions)

# test
# species_file <- "data/troll_species.tsv"
# richness <- 500
# repetitions <- 1

# libs
library(vroom)
library(tidyverse)
library(ggfortify)

species <- vroom(species_file)

communities <- lapply(richness, function(sr){
  lapply(repetitions, function(r){
    sample_n(species, sr) %>% 
      mutate(richness = sr, repetition = r)
  })
}) %>% bind_rows()

write_tsv(communities, fileout)

g <- autoplot(princomp(select(communities, -repetition, -s_name, -richness,
                         -s_regionalfreq, -s_seedmass), cor = TRUE),
         data = communities,
         alpha = 1, loadings = F, loadings.label = F) +
  coord_equal() +
  geom_hline(aes(yintercept = 0), col = 'black', linetype = "dotted") +
  geom_vline(aes(xintercept = 0), col = 'black', linetype = "dotted") +
  theme_bw() +
  geom_density_2d_filled(alpha = 0.75) +
  facet_grid(richness ~ repetition) +
  theme(legend.position = "none")

ggsave(g, filename = figureout)
