# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
era_path <- snakemake@input[["era"]]
climate_path <- snakemake@input[["climate"]]
years_path <- snakemake@input[["years"]]
fileout <- snakemake@output[["tab"]]
figureout <- snakemake@output[["fig"]]
model <- as.character(snakemake@params$model)
rcm <- as.character(snakemake@params$rcm)
exp <- as.character(snakemake@params$exp)

# test
# era_path <- "data/ERA5land_Paracou.tsv"
# climate_path <- "results/climate/projection/NCC-NorESM1-M_REMO2015_rcp85.tsv"
# years_path <- "results/climate/spinup_years.tsv"
# model <- "NCC-NorESM1-M"
# rcm <- "REMO2015"
# exp <- "rcp85"

# libraries
library(tidyverse)
library(vroom)

# code
spinup_years <- vroom(years_path)
era <- vroom(era_path) 
era_adj <- vroom(climate_path)

spinup <- spinup_years %>% 
  left_join(mutate(era, era_year = year(time)),
            multiple = "all",
            by = join_by(era_year)) %>% 
  mutate(months_diff = (sim_year - era_year)*12) %>% 
  mutate(time = time %m+% months(months_diff)) %>% 
  select(-months_diff) %>% 
  mutate(stage = "spinup")

historical <- era %>% 
  mutate(era_year = year(time), sim_year = year(time)) %>% 
  mutate(stage = "historical")
  
projection <- era_adj %>% 
  select(-experiment, -model, -rcm) %>% 
  mutate(stage = "projection")

climate <- bind_rows(spinup, 
                     historical,
                     projection) %>% 
  arrange(time) %>% 
  filter(paste0(month(time), "-", day(time)) != "02-29")

write_tsv(x = climate, file = fileout)

g <- climate %>%
  select(-era_year, -sim_year) %>% 
  group_by(stage, year = year(time)) %>%
  select(-time) %>%
  mutate(rainfall = sum(rainfall, na.rm = TRUE)) %>%
  summarise_all(mean, na.rm = TRUE) %>%
  gather(variable, value, -year, -stage) %>%
  ggplot(aes(year, value)) +
  geom_smooth(se = FALSE, col = "black", alpha = 0.5) +
  geom_line(aes(col = stage)) +
  facet_wrap(~ variable, scales = "free_y") +
  theme_bw() +
  xlab("") + ylab("") +
  theme(legend.position = c(0.8, 0.2))
  ggtitle(paste("ERA5-Land", exp),
          paste("Based on model", model, "with RCM", rcm))

ggsave(plot = g, filename = figureout, bg = "white", width = 8, height = 5)
