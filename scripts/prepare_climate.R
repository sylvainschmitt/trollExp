# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
climatefile <- snakemake@input[["climate"]]
yearfile <- snakemake@input[["years"]]
fileout <- snakemake@output[[1]]
figureout <- snakemake@output[[2]]
model <- as.character(snakemake@params$model)
rcm <- as.character(snakemake@params$rcm)
exp <- as.character(snakemake@params$exp)
warmup <- as.numeric(snakemake@params$warmup)

# test
# climatefile <- "results/data/climate/MOHC-HadGEM2-ES_REMO2015.tsv"
# yearfile <- "results/data/climate/selected_years.tsv"
# model <- "MOHC-HadGEM2-ES"
# rcm <- "REMO2015"
# exp <- "rcp85"
# warmup <- 600

# libraries
library(tidyverse)
library(vroom)

# code
data <- vroom::vroom(climatefile)

## historical
data_hist <- filter(data, experiment == "historical") %>% 
  mutate(experiment = "historical") %>% 
  rename(period = experiment) %>% 
  filter(paste0(month(time), "-", day(time)) != "02-29") %>% 
  filter(year(time) %in% 1970:2005) %>% 
  arrange(time)

## experiment
data_exp <- filter(data, experiment == exp) %>% 
  mutate(experiment = "experiment") %>% 
  rename(period = experiment) %>% 
  filter(paste0(month(time), "-", day(time)) != "02-29") %>% 
  filter(year(time) %in% 2006:2100) %>% 
  arrange(time)


rm(data)
gc()

## warmup
data_warm <- read_tsv(yearfile) %>%
  rename(original_year = year) %>% 
  mutate(year = (1970-warmup):1969) %>% 
  left_join(
    mutate(data_hist, original_year = year(time), period = "warmup"),
    by = "original_year", multiple = "all") %>% 
  mutate(
    month = month(time),
    day = day(time),
    hour = hour(time),
    minute = minute(time)
  ) %>% 
  mutate(
    monthday = paste0(sprintf("%02d", month),
                      "-", 
                      sprintf("%02d", day))
  ) %>% 
  filter(monthday != "02-29") %>% 
  select(-monthday) %>% 
  mutate(time = as_datetime(paste0(
    sprintf("%04d", year), 
    "-", 
    sprintf("%02d", month),
    "-", 
    sprintf("%02d", day),
    " ",
    sprintf("%02d", hour),
    ":", 
    sprintf("%02d", minute),
    ":00" 
  ))) %>% select(-original_year, -year, -month, -day,
                 -hour, -minute)

climate <- bind_rows(data_warm, data_hist, data_exp) %>% 
  arrange(time)

rm(data_warm, data_hist, data_exp)
gc()

write_tsv(x = climate, file = fileout)

g <- climate %>%
  filter(year(time) > 1800) %>% 
  group_by(period, year = year(time)) %>%
  select(-time) %>%
  mutate(rainfall = sum(rainfall, na.rm = TRUE)) %>%
  summarise_all(mean, na.rm = TRUE) %>%
  gather(variable, value, -year, -period) %>%
  ggplot(aes(year, value)) +
  geom_smooth(se = FALSE, col = "black", alpha = 0.5) +
  geom_line(aes(col = period)) +
  facet_wrap(~ variable, scales = "free_y") +
  theme_bw() +
  xlab("") + ylab("") +
  theme(legend.position = c(0.8, 0.2))

ggsave(plot = g, filename = figureout, bg = "white", width = 8, height = 5)
