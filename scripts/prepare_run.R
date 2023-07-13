# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
climate_path <- snakemake@input[["climate"]]
years_path <- snakemake@input[["years"]]
fileout <- snakemake@output[["tab"]]
figureout <- snakemake@output[["fig"]]
mod <- as.character(snakemake@params$model)
rc <- as.character(snakemake@params$rcm)
exp <- as.character(snakemake@params$exp)

# test
# climate_path <- "data/cordex_adjusted.tsv"
# mod <- "NCC-NorESM1-M"
# rc <- "REMO2015"
# exp <- "rcp85"

# libraries
library(tidyverse)
library(vroom)

# code
climate <- vroom(climate_path) %>% 
  filter(model == mod, rcm == rc, experiment == exp) %>% 
  filter(paste0(month(time), "-", day(time)) != "02-29") %>% 
  select(-path, -file, -model, -rcm, -experiment)

write_tsv(x = climate, file = fileout)

g <- climate %>%
  group_by(year = year(time)) %>%
  select(-time) %>%
  mutate(rainfall = sum(rainfall, na.rm = TRUE)) %>%
  summarise_all(mean, na.rm = TRUE) %>%
  gather(variable, value, -year) %>%
  ggplot(aes(year, value)) +
  geom_smooth(se = FALSE, col = "black", alpha = 0.5) +
  geom_line(alpha = 0.25) +
  facet_wrap(~ variable, scales = "free_y") +
  theme_bw() +
  xlab("") + ylab("") +
  ggtitle(paste(mod, rc, exp))

ggsave(plot = g, filename = figureout, bg = "white", width = 8, height = 5)
