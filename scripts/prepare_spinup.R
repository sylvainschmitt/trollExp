# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
climate_file <- snakemake@input[[1]]
fileout <- snakemake@output[["tab"]]
figureout <- snakemake@output[["fig"]]
site <- as.character(snakemake@params$site)
spinup <- snakemake@params$spinup
seed <- snakemake@params$seed

# test
# climate_file <- "results/data/BR-Sa3_climate.tsv"
# site <- "BR-Sa3"
# spinup <- 600
# seed <- 42

# libraries
library(tidyverse)
library(vroom)
set.seed(seed)

# climate
climate <- vroom(climate_file) %>% 
  arrange(time) %>% 
  filter(paste0(month(time), "-", day(time)) != "02-29")

# years
years <- unique(year(climate$time))
ymax <- max(years)

if(spinup > length(years))
  sampled_years <- sample(years, spinup, replace = TRUE)
if(spinup <= length(years))
  sampled_years <- sample(years, spinup, replace = FALSE)
sampled_years <- data.frame(orig_year = sampled_years) %>% 
  mutate(sim_year = (ymax-spinup+1):ymax)

# spinup
spinup <- sampled_years %>% 
  left_join(mutate(climate, orig_year = year(time)),
            multiple = "all",
            by = join_by(orig_year)) %>% 
  mutate(months_diff = (sim_year - orig_year)*12) %>% 
  mutate(time = time %m+% months(months_diff)) %>% 
  select(-months_diff)

write_tsv(x = spinup, file = fileout)

# fig
g <- spinup %>%
  select(-orig_year, -sim_year) %>% 
  group_by(year = year(time)) %>%
  select(-time) %>%
  mutate(rainfall = sum(rainfall, na.rm = TRUE)) %>%
  summarise_all(mean, na.rm = TRUE) %>%
  gather(variable, value, -year) %>%
  ggplot(aes(year, value)) +
  geom_point(alpha = 0.5) +
  geom_smooth(se = FALSE, method = "lm") +
  facet_wrap(~ variable, scales = "free_y") +
  theme_bw() +
  xlab("") + ylab("")

ggsave(plot = g, filename = figureout, bg = "white", width = 8, height = 5)
