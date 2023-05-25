# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
sims_path <- snakemake@input
trajectory_file <- snakemake@output[["trajectory_file"]]
species_file <- snakemake@output[["species_file"]]
forest_file <- snakemake@output[["forest_file"]]
# trajectory_plot <- snakemake@output[["trajectory_plot"]]
# species_plot <- snakemake@output[["species_plot"]]
# forest_plot <- snakemake@output[["forest_plot"]]

# test
# sims_path <- c("results/simulations/Paracou_0-5cm/R1",
#                "results/simulations/Paracou_all/R1")

# libraries
library(tidyverse)
library(rcontroll)
library(ggfortify)

# function
get_trajectory <- function(simulation, table, row)
  simulation@ecosystem %>% 
  select(-iter) %>% 
  mutate(plot = table$plot[row],
         depth = table$depth[row],
         repetition = table$repetition[row],
         path = table$path[row]) %>% 
  gather(variable, value, -plot, -depth, -repetition, -path, -date)

get_species <- function(simulation, table, row)
  simulation@species %>% 
  select(-iter) %>% 
  mutate(plot = table$plot[row],
         depth = table$depth[row],
         repetition = table$repetition[row],
         path = table$path[row]) %>% 
  gather(variable, value, -plot, -depth, -repetition, -path, -date, -species)

get_forest <- function(simulation, table, row) {
  p <- table$plot[row]
  d <- table$depth[row]
  r <- table$repetition[row]
  pa <- table$path[row]
  simulation@forest %>% 
    filter(iter == max(iter)) %>% 
    mutate(date = max(simulation@ecosystem$date)) %>% 
    select(-from_Data, -site, -CrownDisplacement, -iter) %>% 
    mutate(plot = p,
           depth = d,
           repetition = r,
           path = pa) %>% 
    gather(variable, value, -plot, -depth, -repetition, -path, -date, -col, -row)
}

# code

sims_tab <- data.frame(path = unlist(sims_path)) %>% 
  separate(path, c("results", "simulations", "type", "repetition"),
           sep = "/", remove = FALSE) %>% 
  select(-results, -simulations) %>% 
  separate(type, c("plot", "depth"), "_")

sims <- lapply(1:nrow(sims_tab), function(i)
  load_output(sims_tab$repetition[i],
              sims_tab$path[i]))

sims <- lapply(sims, date_sim, "1000-01-01")

trajectory <- lapply(1:nrow(sims_tab), function(i) 
  get_trajectory(sims[[i]], sims_tab, i)) %>% 
  bind_rows()

species <- lapply(1:nrow(sims_tab), function(i) 
  get_species(sims[[i]], sims_tab, i)) %>% 
  bind_rows()

forest <- lapply(1:nrow(sims_tab), function(i) 
  get_forest(sims[[i]], sims_tab, i)) %>% 
  bind_rows()

rm(sims) ; gc()

# save

write_tsv(trajectory, trajectory_file)
write_tsv(species, species_file)
write_tsv(forest, forest_file)

# plots
# g_traj <- trajectory %>% 
#   filter(variable == "agb") %>% 
#   group_by(plot, depth,
#            repetition, path, variable,
#            date = floor_date(date, "month")) %>% 
#   summarise(value = mean(value)) %>% 
#   mutate(experiment = paste(plot, depth)) %>% 
#   ggplot(aes(date, value, col = experiment)) +
#   geom_line() +
#   theme_bw()
# 
# g_sp <- species %>% 
#   filter(species %in% c("Cecropia_obtusa",
#                         "Dicorynia_guianensis")) %>% 
#   filter(variable == "agb") %>% 
#   group_by(plot, depth,
#            repetition, path, variable, species,
#            date = floor_date(date, "year")) %>% 
#   summarise(value = mean(value)) %>% 
#   mutate(experiment = paste(plot, depth)) %>% 
#   ggplot(aes(date, value, 
#              col = species, linetype = experiment)) +
#   geom_line() +
#   theme_bw()
# 
# gdat <- filter(forest, variable %in% c("Pmass", "Nmass", "wsg", "LMA", "ah", "dbhmax", "hmax")) %>% 
#   mutate(experiment = paste(plot, depth)) %>% 
#   select(date, experiment, variable, value) %>% 
#   pivot_wider(names_from = variable, values_from = value) %>% 
#   unnest() %>% 
#   mutate_at(c("Pmass", "Nmass", "wsg", "LMA", "ah", "dbhmax", "hmax"), as.numeric)
# 
# pca <- princomp(select(gdat, -date, -experiment), cor = TRUE)
# 
# g_for <- autoplot(pca, 
#                   data = gdat,
#                   colour = "experiment", alpha = 0.25,
#                   loadings.label.size = 6,
#                   loadings.label.colour = 'black', loadings.label.vjust = 1.1,
#                   loadings = T, loadings.label = T, loadings.colour = 'black') +
#   coord_equal() +
#   geom_hline(aes(yintercept = 0), col = 'black', linetype = "dotted") +
#   geom_vline(aes(xintercept = 0), col = 'black', linetype = "dotted") +
#   theme_bw() +
#   stat_ellipse(aes(colour = experiment))
# 
# ggsave(trajectory_plot, g_traj, bg = "white")
# ggsave(species_plot, g_sp, bg = "white")
# ggsave(forest_plot, g_for, bg = "white")
