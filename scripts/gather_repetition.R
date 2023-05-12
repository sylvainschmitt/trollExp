# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
exp_path <- snakemake@input[["exp_path"]]
warm_path <- snakemake@input[["warm_path"]]
type <- as.character(snakemake@params$type)
period <- as.character(snakemake@params$period)
climate <- as.character(snakemake@params$climate)
rep <- as.character(snakemake@params$rep)
trajectory_file <- snakemake@output[["trajectory_file"]]
species_file <- snakemake@output[["species_file"]]
forest_file <- snakemake@output[["forest_file"]]
trajectory_plot <- snakemake@output[["trajectory_plot"]]
species_plot <- snakemake@output[["species_plot"]]
forest_plot <- snakemake@output[["forest_plot"]]

# test
# exp_path <- c("results/simulations/projections/full/MPI-M-MPI-ESM-MR_ICTP-RegCM4-7/historical/R1",
#               "results/simulations/projections/full/MPI-M-MPI-ESM-MR_ICTP-RegCM4-7/rcp26/R1",
#               "results/simulations/projections/full/MPI-M-MPI-ESM-MR_ICTP-RegCM4-7/rcp85/R1")
# warm_path <- "results/simulations/projections/full/MPI-M-MPI-ESM-MR_ICTP-RegCM4-7/warmup/R1"
# rep <- "R1"
# climate <- "MPI-M-MPI-ESM-MR_ICTP-RegCM4-7"
# period <- "full"
# type <- "projections"

# libraries
suppressMessages(library(tidyverse)) 
suppressMessages(library(rcontroll)) 
library(ggfortify)

# function
get_trajectory <- function(simulation, table, row)
  simulation@ecosystem %>% 
  select(-iter) %>% 
  mutate(type = table$type[row],
         period = table$period[row],
         climate = table$climate[row],
         experiment = table$experiment[row],
         repetition = table$repetition[row],
         path = table$path[row]) %>% 
  gather(variable, value, -type, -period, -climate,
         -experiment, -repetition, -path, -date) %>% 
  select(type, period, climate,
         experiment, repetition, path,
         date, variable, value)

get_species <- function(simulation, table, row)
  simulation@species %>% 
  select(-iter) %>% 
  mutate(type = table$type[row],
         period = table$period[row],
         climate = table$climate[row],
         experiment = table$experiment[row],
         repetition = table$repetition[row],
         path = table$path[row]) %>% 
  gather(variable, value, -type, -period, -climate,
         -experiment, -repetition, -path, -date, -species) %>% 
  select(type, period, climate,
         experiment, repetition, path,
         date, species, variable, value)

get_forest <- function(simulation, table, row) {
  t <- table$type[row]
  pe <- table$period[row]
  c <- table$climate[row]
  e <- table$experiment[row]
  r <- table$repetition[row]
  pa <- table$path[row]
  simulation@forest %>% 
    filter(iter == max(iter)) %>% 
    mutate(date = max(simulation@ecosystem$date)) %>% 
    select(-from_Data, -site, -CrownDisplacement, -iter) %>% 
    mutate(type = t,
           period = pe,
           climate = c,
           experiment = e,
           repetition = r,
           path = pa) %>% 
    gather(variable, value, -type, -period, -climate,
           -experiment, -repetition, -path, -date, -col, -row) %>% 
    select(type, period, climate,
           experiment, repetition, path,
           date, col, row, variable, value)
}
  


# warmup
sims_warm <- data.frame(path = warm_path) %>% 
  separate(path, c("results", "simulations", "type", 
                   "period", "climate",
                   "experiment", "repetition"),
           sep = "/", remove = FALSE) %>% 
  select(-results, -simulations)
warmup <- load_output(sims_warm$repetition[1],
                      sims_warm$path[1])
warmup <- date_sim(warmup, "1000-01-01")
trajectory_warm <- get_trajectory(warmup, sims_warm, 1)
species_warm <- get_species(warmup, sims_warm, 1)
forest_warm <- get_forest(warmup, sims_warm, 1)

# experiments
sims_exp <- data.frame(path = exp_path) %>% 
  separate(path, c("results", "simulations", "type", 
                   "period", "climate",
                   "experiment", "repetition"),
           sep = "/", remove = FALSE) %>% 
  select(-results, -simulations)
sims <- lapply(1:nrow(sims_exp), function(i)
  load_output(sims_exp$repetition[i],
              sims_exp$path[i]))
sims <- lapply(sims, date_sim, max(warmup@ecosystem$date)+1)
trajectory_exp <- lapply(1:nrow(sims_exp), function(i) 
  get_trajectory(sims[[i]], sims_exp, i)) %>% 
  bind_rows()
species_exp <- lapply(1:nrow(sims_exp), function(i) 
  get_species(sims[[i]], sims_exp, i)) %>% 
  bind_rows()
forest_exp <- lapply(1:nrow(sims_exp), function(i) 
  get_forest(sims[[i]], sims_exp, i)) %>% 
  bind_rows()
rm(warmup, sims) ; invisible(gc())

# bindings

trajectory <- bind_rows(
  trajectory_warm,
  trajectory_exp
)

species <- bind_rows(
  species_warm,
  species_exp
)

forest <- bind_rows(
  forest_warm,
  forest_exp
)

rm(trajectory_exp, trajectory_warm, 
   species_exp, species_warm,
   forest_exp, forest_warm)
invisible(gc)

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
  ggplot(aes(date, value, col = experiment)) +
  geom_line() +
  theme_bw() +
  ggtitle(paste(trajectory$climate, trajectory$repetition),
          paste(trajectory$type, trajectory$period))

g_sp <- species %>% 
  filter(species %in% c("Cecropia_obtusa",
                        "Dicorynia_guianensis")) %>% 
  filter(variable == "agb") %>% 
  group_by(type, period, climate, experiment,
           repetition, path, variable, species,
           date = floor_date(date, "year")) %>% 
  summarise(value = mean(value)) %>% 
  ggplot(aes(date, value, 
             col = species, linetype = experiment)) +
  geom_line() +
  theme_bw() +
  ggtitle(paste(trajectory$climate, trajectory$repetition),
          paste(trajectory$type, trajectory$period))

gdat <- filter(forest, variable %in% c("Pmass", "Nmass", "wsg", "LMA", "ah", "dbhmax", "hmax")) %>% 
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
  ggtitle(paste(trajectory$climate, trajectory$repetition),
          paste(trajectory$type, trajectory$period))

ggsave(trajectory_plot, g_traj, bg = "white")
ggsave(species_plot, g_sp, bg = "white")
ggsave(forest_plot, g_for, bg = "white")

