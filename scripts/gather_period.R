# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
trajectory_in <- snakemake@input[["trajectory_in"]]
species_in <- snakemake@input[["species_in"]]
forest_in <- snakemake@input[["forest_in"]]
type <- as.character(snakemake@params$type)
period <- as.character(snakemake@params$period)
trajectory_file <- snakemake@output[["trajectory_file"]]
species_file <- snakemake@output[["species_file"]]
forest_file <- snakemake@output[["forest_file"]]
trajectory_plot <- snakemake@output[["trajectory_plot"]]
species_plot <- snakemake@output[["species_plot"]]
forest_plot <- snakemake@output[["forest_plot"]]

# test
# trajectory_in <- c("results/tables/repetitions/current_10-years/guyaflux_R1_trajectory.tsv", 
#                    "results/tables/repetitions/current_10-years/era_R1_trajectory.tsv", 
#                    "results/tables/repetitions/current_10-years/MPI-M-MPI-ESM-MR_ICTP-RegCM4-7_R1_trajectory.tsv")
# species_in <- c("results/tables/repetitions/current_10-years/guyaflux_R1_species.tsv", 
#                 "results/tables/repetitions/current_10-years/era_R1_species.tsv", 
#                 "results/tables/repetitions/current_10-years/MPI-M-MPI-ESM-MR_ICTP-RegCM4-7_R1_species.tsv")
# forest_in <- c("results/tables/repetitions/current_10-years/guyaflux_R1_forest.tsv", 
#                "results/tables/repetitions/current_10-years/era_R1_forest.tsv", 
#                "results/tables/repetitions/current_10-years/MPI-M-MPI-ESM-MR_ICTP-RegCM4-7_R1_forest.tsv")
# type <- "current"
# period <- "10-years"

# libraries
suppressMessages(library(tidyverse)) 
library(vroom)
library(ggfortify)

# bindings
trajectory <- trajectory_in %>% 
  lapply(vroom) %>% 
  bind_rows()

species <- species_in %>% 
  lapply(vroom) %>% 
  bind_rows()

forest <- forest_in %>% 
  lapply(vroom) %>% 
  bind_rows()

# save

write_tsv(trajectory, trajectory_file)
write_tsv(species, species_file)
write_tsv(forest, forest_file)

# plots
g_traj <- trajectory %>% 
  filter(variable == "agb") %>% 
  group_by(type, period, climate, experiment,
           repetition, path, variable,
           date = floor_date(date, "month")) %>% 
  summarise(value = mean(value)) %>% 
  ggplot(aes(date, value, 
             col = climate,
             group = paste(climate, repetition))) +
  geom_line() +
  theme_bw() +
  ggtitle(paste(unique(trajectory$type), 
                unique(trajectory$period)))

g_sp <- species %>% 
  filter(species %in% c("Cecropia_obtusa",
                        "Dicorynia_guianensis")) %>% 
  filter(variable == "agb") %>% 
  group_by(type, period, climate, experiment,
           repetition, path, variable, species,
           date = floor_date(date, "year")) %>% 
  summarise(value = mean(value)) %>% 
  ggplot(aes(date, value, 
             col = species, 
             linetype = experiment)) +
  geom_line() +
  theme_bw() +
  facet_wrap(~climate) +
  ggtitle(paste(unique(trajectory$type), 
                unique(trajectory$period)))

gdat <- filter(forest, variable %in% c("Pmass", "Nmass", "wsg", "LMA", "ah", "dbhmax", "hmax")) %>% 
  mutate(experiment = paste(climate, experiment)) %>% 
  select(date, experiment, variable, value) %>% 
  pivot_wider(names_from = variable, values_from = value) %>% 
  unnest() %>% 
  mutate_at(c("Pmass", "Nmass", "wsg", "LMA", "ah", "dbhmax", "hmax"), as.numeric)

pca <- princomp(select(gdat, -date, -experiment), cor = TRUE)

g_for <- autoplot(pca, 
         data = gdat,
         colour = "experiment", alpha = 0.1,
         loadings.label.size = 6,
         loadings.label.colour = 'black', loadings.label.vjust = 1.1,
         loadings = T, loadings.label = T, loadings.colour = 'black') +
  coord_equal() +
  geom_hline(aes(yintercept = 0), col = 'black', linetype = "dotted") +
  geom_vline(aes(xintercept = 0), col = 'black', linetype = "dotted") +
  theme_bw() +
  stat_ellipse(aes(colour = experiment)) +
  ggtitle(paste(unique(trajectory$type), 
                unique(trajectory$period)))

ggsave(trajectory_plot, g_traj, bg = "white")
ggsave(species_plot, g_sp, bg = "white")
ggsave(forest_plot, g_for, bg = "white")

