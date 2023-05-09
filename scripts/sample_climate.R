# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
climatefile <- snakemake@input[[1]]
yearfile <- snakemake@input[[2]]
fileout <- snakemake@output[[1]]
figureout <- snakemake@output[[2]]
type <- as.character(snakemake@params$type)
period <- as.character(snakemake@params$period)
climate <- as.character(snakemake@params$climate)
data_path <- snakemake@params$data_path

# test
# filein <- "results/simulations/projections/full/selected_years.tsv"
# fileout <- "guyaflux_sampled.tsv"
# figureout <- "guyaflux_sampled.png"
# type <- "current"
# period <- "10-years"
# climate <- "MPI-M-MPI-ESM-MR_ICTP-RegCM4-7"
# data_path <- "/home/sschmitt/Documents/data/"

# libraries
suppressMessages(library(tidyverse)) 
library(vroom)

# folder
path <- gsub(paste0(climate, "_sampled.tsv"), "", fileout)
if(!dir.exists(path))
  dir.create(path, recursive = TRUE)

# climate
data <- vroom::vroom(climatefile)

climate <- read_tsv(yearfile) %>%
  rename(original_year = year) %>% 
  mutate(year = 1:n()) %>% 
  left_join(
    mutate(data, original_year = year(time)),
    by = "original_year", multiple = "all")

climate <- climate %>% 
  mutate(
    year = year + 1000, # stupid trick to be read back correctly
    month = month(time),
    day = day(time),
    hour = hour(time),
    minute = minute(time)
    ) %>% 
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

write_tsv(x = climate, file = fileout)

g <- climate %>% 
  group_by(year = year(time)) %>% 
  select(-time) %>% 
  mutate(rainfall = sum(rainfall, na.rm = TRUE)) %>% 
  summarise_all(mean, na.rm = TRUE) %>% 
  gather(variable, value, -year) %>% 
  ggplot(aes(year, value)) +
  geom_line(alpha = 0.5) +
  geom_smooth(col = "red") +
  facet_wrap(~ variable, scales = "free_y") +
  theme_bw() + 
  xlab("") + ylab("")

ggsave(plot = g, filename = figureout, bg = "white", width = 8, height = 5)
